//
//  GGMapView.swift
//  MMY
//
//  Created by Blue R&D on 2/27/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import GoogleMaps
import SnapKit
import NVActivityIndicatorView

class GGMapView: UIView {
    let centerPointSize: CGFloat = 20
    var mapView: GMSMapView
    var circleView: UIView
//    var centerPoint: NVActivityIndicatorView
    var mappingMarkers: [(marker: GMSMarker, post: PostModel)] = []
    var myLocation = UIButton(type: .custom)
    var locationManager = CLLocationManager()
    var lastLocation: CLLocation?
    var lastZoomLevel: Float = 0
    
    weak var delegate: GMSMapViewDelegate?{
        get {
            return mapView.delegate
        }
        set {
            mapView.delegate = newValue
        }
    }
    
    let pinViewSize = CGSize(width: 35, height: 35)
    lazy var pinView: UIImageView = { [unowned self] in
        let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        v.image = UIImage(named: "map_pin", in: Bundle(for: MapViewController.self), compatibleWith: nil)
        v.image = v.image?.withRenderingMode(.alwaysTemplate)
        v.tintColor = UIColor.red
        v.backgroundColor = .clear
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = false
        return v
        }()
    
    let width: CGFloat = 10.0
    let height: CGFloat = 5.0
    
    lazy var ellipse: UIBezierPath = { [unowned self] in
        let ellipse = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        return ellipse
        }()
    
    lazy var ellipsisLayer: CAShapeLayer = { [unowned self] in
        let layer = CAShapeLayer()
        layer.bounds = CGRect(x: 0, y: -10, width: self.width, height: self.height)
        layer.path = self.ellipse.cgPath
        layer.fillColor = UIColor.gray.cgColor
        layer.fillRule = kCAFillRuleNonZero
        layer.lineCap = kCALineCapButt
        layer.lineDashPattern = nil
        layer.lineDashPhase = 0.0
        layer.lineJoin = kCALineJoinMiter
        layer.lineWidth = 1.0
        layer.miterLimit = 10.0
        layer.strokeColor = UIColor.gray.cgColor
        return layer
        }()
    
    override init(frame: CGRect) {
        let locationCoordinate = CLLocationCoordinate2D(latitude: 10.799430, longitude: 106.680948)
        let camera = GMSCameraPosition.camera(withTarget: locationCoordinate, zoom: 15)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = false
        mapView.isMyLocationEnabled = true
        
        
        circleView = UIView(frame: frame)
        circleView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.1)
        circleView.isHidden = true
        circleView.isUserInteractionEnabled = false
        
//        centerPoint = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: centerPointSize, height: centerPointSize), type: .ballScaleMultiple , color: UIColor.appColor, padding: 0.0)
//        centerPoint.isUserInteractionEnabled = false
//        centerPoint.startAnimating()
        
        super.init(frame: frame)
        self.addSubview(mapView)
        mapView.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
        }
        
        self.addSubview(circleView)
        circleView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(self.snp.width)
            
        }
        
        self.addSubview(pinView)
//        self.layer.insertSublayer(ellipsisLayer, below: pinView.layer)
        pinView.snp.makeConstraints { (make) in
            make.centerX.equalTo(mapView)
            make.centerY.equalTo(mapView).offset(-(pinViewSize.height/2))
            make.height.equalTo(pinViewSize.height)
            make.width.equalTo(pinViewSize.width)
        }
//        var center = mapView.convert(mapView.center, to: pinView)
//        center.y = center.y - (pinView.bounds.height)
//        pinView.center = CGPoint(x: center.x, y: center.y - (pinView.bounds.height/2))
//        ellipsisLayer.position = center
        
//        self.addSubview(centerPoint)
//        centerPoint.snp.makeConstraints { (make) in
//            make.center.equalTo(self)
//        }
        
        createMyLocationButton()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showCircleView(){
        circleView.isHidden = false
        circleView.layer.cornerRadius = circleView.frame.width / 2
    }
    
    func createMyLocationButton() {
        addSubview(myLocation)
        myLocation.backgroundColor = .white
        myLocation.layer.cornerRadius = 5
        let insets = CGFloat(10).fixWidth()
        myLocation.imageEdgeInsets = UIEdgeInsets(top:insets, left: insets, bottom: insets, right: insets)
        myLocation.setImage(UIImage(named: "ic_my_location"), for: .normal)
        myLocation.addTarget(self, action: #selector(showMyLocation), for: .touchUpInside)
        myLocation.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.bottom.equalTo(self).offset(-30)
            make.left.equalTo(self).offset(10)
        }
    }
    
    func showMyLocation() {
        guard let myLocation = mapView.myLocation else {
            return
        }
        let camera = GMSCameraPosition.camera(withLatitude: myLocation.coordinate.latitude, longitude: myLocation.coordinate.longitude, zoom: mapView.camera.zoom)
        self.mapView.animate(to: camera)
    }
    
    func calculateRadius() -> (location: CLLocation, radius: CGFloat){
        let centerCoordinate = mapView.projection.coordinate(for: mapView.center)
        let borderCoordinate = mapView.projection.coordinate(for: CGPoint(x: 0, y: mapView.frame.height / 2))
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        let borderLocation = CLLocation(latitude: borderCoordinate.latitude, longitude: borderCoordinate.longitude)
        return (location: centerLocation, radius: CGFloat(centerLocation.distance(from: borderLocation)))
    }
    
    func addMarkerWithFeed(_ post: PostModel){
        guard let location = post.location else {
            return
        }
        
        let imageName = Authenticator.shareInstance.getPostType() == PostType.findPeople ? "ic_maker_green":  "ic_maker_red"
        let markerFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let marker = GMSMarker(position: location.coordinate)
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: -0.05)
        if Authenticator.shareInstance.getPostType() == PostType.findPeople {
            marker.iconView = CustomMarker(frame: markerFrame, avatar: post.thumbnail, imageName: imageName)
        }
        else {
            marker.iconView = CustomMarker(frame: markerFrame, avatar: post.userModel?.avatarURL, imageName: imageName)
        }
        marker.zIndex = Int32(mappingMarkers.count)
        marker.map = self.mapView
        mappingMarkers.safeAppend((marker: marker, post: post))
    }
    
    
    func clearAllMarker(){
        mapView.clear()
        mappingMarkers.removeAll()
    }
    
    func getPostWith(_ marker: GMSMarker) -> PostModel?{
        for mappingMarker in mappingMarkers{
            if mappingMarker.marker == marker{
                return mappingMarker.post
            }
        }
        return nil
    }
    
    var isChangeZoomLevel: Bool{
        get{
            if lastZoomLevel != mapView.camera.zoom{
                lastZoomLevel = mapView.camera.zoom
                return true
            }
            
            return false
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension GGMapView: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.animate(to: GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0))
            locationManager.stopUpdatingLocation()
        }
    }
}

extension GGMapView {
    class CustomMarker: UIView {
        
        var markerImageView = UIImageView()
        var avatarImageView = UIImageView()
        let iconSize: CGFloat = 30
        let avatarSize: CGFloat = 100
        var markerImageName = "ic_map_marker"
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        convenience init(frame: CGRect, avatar: String?, imageName: String = "ic_map_marker") {
            self.init(frame: frame)
            markerImageName = imageName
            initView()
            if let avatarURL = avatar {
                avatarImageView.kf.setImage(with: URL(string: getThumbnailURL(from: avatarURL)), placeholder: UIImage(named: "no_image_available"))
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func initView() {
            addSubview(markerImageView)
            markerImageView.image = UIImage(named: markerImageName)
            markerImageView.contentMode = .scaleAspectFit
            markerImageView.snp.makeConstraints { (make) in
                make.left.equalTo(self)
                make.right.equalTo(self)
                make.top.equalTo(self)
                make.bottom.equalTo(self)
            }
            
            addSubview(avatarImageView)
            avatarImageView.snp.makeConstraints { (make) in
                make.top.equalTo(self).offset(3)
                make.centerX.equalTo(self)
                make.width.equalTo(iconSize)
                make.height.equalTo(iconSize)
            }
            avatarImageView.backgroundColor = UIColor.clear
            avatarImageView.layer.cornerRadius = iconSize/2
            avatarImageView.clipsToBounds = true
            avatarImageView.image = UIImage(named: "no_image_available")
            avatarImageView.contentMode = .scaleAspectFill
        }
        
        func getThumbnailURL(from url: String) -> String {
             return url + "?w=\(avatarSize)&h=\(avatarSize)"
        }
    }
}
