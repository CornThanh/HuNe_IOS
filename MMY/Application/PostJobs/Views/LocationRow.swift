//
//  LocationRow.swift
//  MMY
//
//  Created by Blue R&D on 2/21/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import CoreLocation
import Eureka
import GoogleMaps

//MARK: LocationRow

public final class LocationRow : SelectorRow<PushSelectorCell<CLLocation>, MapViewController>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback { return MapViewController(){ _ in } },
                                 onDismiss: { vc in _ = vc.navigationController?.popViewController(animated: true) })
        
        displayValueFor = {
            guard let location = $0 else { return "" }
            let fmt = NumberFormatter()
            fmt.maximumFractionDigits = 4
            fmt.minimumFractionDigits = 4
            let latitude = fmt.string(from: NSNumber(value: location.coordinate.latitude))!
            let longitude = fmt.string(from: NSNumber(value: location.coordinate.longitude))!
            return  "\(latitude), \(longitude)"
        }
    }
}

public class MapViewController : UIViewController, TypedRowControllerType, GMSMapViewDelegate {
    
    
    //MARK: - Properties
    public var row: RowOf<CLLocation>!
    public var onDismissCallback: ((UIViewController) -> ())?
    
    lazy var mapView : GMSMapView = { [unowned self] in
        let locationCoordinate = CLLocationCoordinate2D(latitude: 10.8010, longitude: 106.6823)
        let camera = GMSCameraPosition.camera(withTarget: locationCoordinate, zoom: 15)
        let v = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
        v.settings.compassButton = true
        v.settings.myLocationButton = true
        v.isMyLocationEnabled = true
        v.delegate = self
        v.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleHeight)
        return v
        }()
    
    lazy var pinView: UIImageView = { [unowned self] in
        let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        v.image = UIImage(named: "map_pin", in: Bundle(for: MapViewController.self), compatibleWith: nil)
        v.image = v.image?.withRenderingMode(.alwaysTemplate)
        v.tintColor = self.view.tintColor
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
    
    
    //MARK: - Methods
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience public init(_ callback: ((UIViewController) -> ())?){
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        mapView.addSubview(pinView)
        mapView.layer.insertSublayer(ellipsisLayer, below: pinView.layer)
        let button = UIBarButtonItem(image: UIImage(named: "ic_done"), style: .done, target: self, action: #selector(MapViewController.tappedDone(_:)))
        navigationItem.rightBarButtonItem = button
        let backButton = UIBarButtonItem(image: UIImage(named: "ic_back"), style: .plain, target: self, action: #selector(backToPreviousController))
        navigationItem.leftBarButtonItem = backButton
        var coordinate: CLLocationCoordinate2D
        if let value = row.value {
            coordinate = value.coordinate
        } else{
            coordinate = mapView.myLocation != nil ? (mapView.myLocation?.coordinate)! : CLLocationCoordinate2D(latitude: 10.8010, longitude: 106.6823)
        }
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15)
        mapView.camera = camera
        updateTitle()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var center = mapView.convert(mapView.center, to: pinView)
        center.y = center.y - (pinView.bounds.height)
        pinView.center = CGPoint(x: center.x, y: center.y - (pinView.bounds.height/2))
        ellipsisLayer.position = center
    }
    
    
    func tappedDone(_ sender: UIBarButtonItem){
        let target = mapView.projection.coordinate(for: ellipsisLayer.position)
        row.value = CLLocation(latitude: target.latitude, longitude: target.longitude)
        onDismissCallback?(self)
    }
    
    func backToPreviousController () {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func updateTitle(){
        let fmt = NumberFormatter()
        fmt.maximumFractionDigits = 4
        fmt.minimumFractionDigits = 4
        let latitude = fmt.string(from: NSNumber(value: mapView.camera.target.latitude))!
        let longitude = fmt.string(from: NSNumber(value: mapView.camera.target.longitude))!
        title = "\(latitude), \(longitude)"
    }
    
    public func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        ellipsisLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pinView.center = CGPoint(x: self!.pinView.center.x, y: self!.pinView.center.y - 10)
        })
    }
    
    public func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        ellipsisLayer.transform = CATransform3DIdentity
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pinView.center = CGPoint(x: self!.pinView.center.x, y: self!.pinView.center.y + 10)
        })
        updateTitle()
    }
}
