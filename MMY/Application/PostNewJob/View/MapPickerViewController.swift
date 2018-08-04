
import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

class MapPickerViewController: UIViewController, GMSMapViewDelegate, LocateOnTheMap, UISearchBarDelegate, GMSAutocompleteFetcherDelegate {

    //MARK: - Properties
    public var onDismissCallback: ((CLLocation?) -> ())?
    var location: CLLocation?
    
    // For SearchViewController
    var searchResultController: SearchResultsController!
    var resultsArray = [String]()
    var gmsFetcher: GMSAutocompleteFetcher!
    
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
//        v.tintColor = self.view.tintColor
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
    
    
    //MARK: - Methods
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience public init(_ callback: ((CLLocation?) -> ())?){
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        mapView.addSubview(pinView)
        mapView.layer.insertSublayer(ellipsisLayer, below: pinView.layer)
        
        // Add left bar button
        let leftButton = UIButton.init(type: .custom)
        leftButton.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        leftButton.addTarget(self, action:#selector(backToPreviousController), for: UIControlEvents.touchUpInside)
        leftButton.frame = CGRect.init(x: 0, y: 0, width: 10, height: 20)
        leftButton.tintColor = .white
        leftButton.backgroundColor = .clear
        let leftBarButton = UIBarButtonItem.init(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
//        let button = UIBarButtonItem(image: UIImage(named: "ic_done"), style: .done, target: self, action: #selector(tappedDone(_:)))
//        navigationItem.rightBarButtonItem = button
        
        let doneBtn = UIButton(type: .custom)
        doneBtn.setImage(UIImage(named: "ic_done_white"), for: .normal)
        doneBtn.addTarget(self, action: #selector(tappedDone(_:)), for: .touchUpInside)
        self.view.addSubview(doneBtn)
        doneBtn.snp.makeConstraints { (make) in
            make.height.equalTo(60)
            make.width.equalTo(60)
            make.bottom.equalTo(view.snp.bottom).offset(-80)
            make.right.equalTo(view.snp.right).offset(-10)
        }
        doneBtn.backgroundColor = Authenticator.shareInstance.getPostType()?.color()
        doneBtn.layer.cornerRadius = 30
        doneBtn.clipsToBounds = true
        
//        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(tappedSearch(_:)))
//        searchButton.tintColor = UIColor.white
//        navigationItem.rightBarButtonItem = searchButton

        var coordinate: CLLocationCoordinate2D
        if let location = location {
            coordinate = location.coordinate
        } else{
            coordinate = mapView.myLocation != nil ? (mapView.myLocation?.coordinate)! : CLLocationCoordinate2D(latitude: 10.8010, longitude: 106.6823)
        }
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15)
        mapView.camera = camera
        updateTitle()
        
        searchResultController = SearchResultsController()
        searchResultController.delegate = self
        
        gmsFetcher = GMSAutocompleteFetcher()
        gmsFetcher.delegate = self
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var center = mapView.convert(mapView.center, to: pinView)
        center.y = center.y - (pinView.bounds.height)
        pinView.center = CGPoint(x: center.x, y: center.y - (pinView.bounds.height/2))
        ellipsisLayer.position = center
    }
    
    func tappedDone(_ sender: UIBarButtonItem){
//        let target = mapView.projection.coordinate(for: ellipsisLayer.position)
        let target = mapView.camera.target
        onDismissCallback?(CLLocation(latitude: target.latitude, longitude: target.longitude))
        navigationController?.popViewController(animated: true)
    }
    
    func tappedSearch(_ sender: UIBarButtonItem){
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        self.present(searchController, animated:true, completion: nil)
    }
    
    func backToPreviousController () {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func updateTitle(){
//        let fmt = NumberFormatter()
//        fmt.maximumFractionDigits = 4
//        fmt.minimumFractionDigits = 4
//        let latitude = fmt.string(from: NSNumber(value: mapView.camera.target.latitude))!
//        let longitude = fmt.string(from: NSNumber(value: mapView.camera.target.longitude))!
//        title = "\(latitude), \(longitude)"
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
    

    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        DispatchQueue.main.async { () -> Void in
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 15)
            self.mapView.camera = camera
            self.title = title
        }
    }
    
    
    /**
     Searchbar when text change
     
     - parameter searchBar:  searchbar UI
     - parameter searchText: searchtext description
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //        let placeClient = GMSPlacesClient()
        //
        //
        //        placeClient.autocompleteQuery(searchText, bounds: nil, filter: nil)  {(results, error: Error?) -> Void in
        //           // NSError myerr = Error;
        //            print("Error @%",Error.self)
        //
        //            self.resultsArray.removeAll()
        //            if results == nil {
        //                return
        //            }
        //
        //            for result in results! {
        //                if let result = result as? GMSAutocompletePrediction {
        //                    self.resultsArray.append(result.attributedFullText.string)
        //                }
        //            }
        //
        //            self.searchResultController.reloadDataWithArray(self.resultsArray)
        //
        //        }
        
        
        self.resultsArray.removeAll()
        gmsFetcher?.sourceTextHasChanged(searchText)
        
    }
    
    //MARK: - GMSAutocompleteFetcherDelegate
    /**
     * Called when autocomplete predictions are available.
     * @param predictions an array of GMSAutocompletePrediction objects.
     */
    public func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        //self.resultsArray.count + 1
        
        for prediction in predictions {
            
            if let prediction = prediction as GMSAutocompletePrediction!{
                self.resultsArray.append(prediction.attributedFullText.string)
            }
        }
        self.searchResultController.reloadDataWithArray(self.resultsArray)
        //   self.searchResultsTable.reloadDataWithArray(self.resultsArray)
        print(resultsArray)
    }
    
    /**
     * Called when an autocomplete request returns an error.
     * @param error the error that was received.
     */
    public func didFailAutocompleteWithError(_ error: Error) {
        //        resultText?.text = error.localizedDescription
    }
}
