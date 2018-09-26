

import UIKit
import GoogleMaps

class RecruitmentViewController: BaseViewController {
    
    //MARK: - Properties
    var categoryView: CategoryView?
    var adsView: UIView?
    var mapView: GGMapView?
    var createButton: UIButton?
    var segmentControl: UISegmentedControl?
    var filterModel = FilterModel()
    var postType: PostType?
    var pagingModel: PagingModel?
    let maxPosts = 30
    var uuid = UUID()
    var backGroundColor: UIColor?
    var posts: [PostModel]?
    var currentPost: PostModel?
    var viewMessage: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        setAds()
        setupView()
        
        addTargetTitle(typePost: postType!)
        
        // create view message if map empty
        self.viewMessage = self.createBanerMapEmpty()
        view.addSubview(viewMessage!)
        viewMessage?.snp.makeConstraints { (make) in
            make.bottom.equalTo((mapView?.snp.bottom)!).offset(-140)
            make.centerX.equalTo(view).offset(-((viewMessage?.frame.size.width)!/2))
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ShareData.typeManager = ""
        if let postType = postType {
            filterModel.postType = postType
        }
        getPost(id: uuid, filter: filterModel, page: 0)
        
        if postType == PostType.findJob {
            backGroundColor = UIColor(hexString: "#CC3333") ?? .appColor
        }
        else {
            backGroundColor = UIColor(hexString: "#33CCFF") ?? .appColor
        }
        navigationController?.navigationBar.barTintColor = backGroundColor
        
    }
    
    override func updateViewConstraints() {
        mapView?.snp.remakeConstraints { (make) in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            _ = categoryView != nil ? make.bottom.equalTo((categoryView?.snp.top)!) : make.bottom.equalTo(view)
        }
        super.updateViewConstraints()
        view.backgroundColor = UIColor.lightGray
    }
    
    
    func setupView(){
        setupMenuButton()
        setupAdView()
        createGoogleMaps()
        getCategoryFromServer()
    }
    
    //MARK: - Methods
    
    func setAds(){
        AdsManager.sharedInstance.addProvider(provider: AdsGoogleProvider())
        AdsManager.sharedInstance.loadAllAds(in: self)
    }
    
    func displayUserInfo() {
        if Authenticator.shareInstance.loginType == .guest{
            Authenticator.shareInstance.popupAuthSignInViewCtl(in: self)
        }
        else {
            let profileVC = MMYProfileViewController(nibName: "MMYProfileViewController", bundle: nil)
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    func displayNotification() {
        if Authenticator.shareInstance.loginType == .guest{
            Authenticator.shareInstance.popupAuthSignInViewCtl(in: self)
        }
        else {
            let notificationVC = MMYNotificationViewController(nibName: "MMYNotificationViewController", bundle: nil)
            self.navigationController?.pushViewController(notificationVC, animated: true)
        }
    }
    
}

//MARK: - Setup views
extension RecruitmentViewController {
    func setupMenuButton() {
        navigationItem.backBarButtonItem?.title = ""
        //cuong
        
        navigationController?.navigationBar.isTranslucent = false
        let leftMenuButton = UIBarButtonItem(image: UIImage(named: "icon_person"), style: .plain, target: self, action: #selector(displayUserInfo))
        navigationItem.leftBarButtonItem = leftMenuButton
        leftMenuButton.image = UIImage(named: "icon_person")?.withRenderingMode(.alwaysTemplate)
        leftMenuButton.tintColor = .white
        let rightMenuButton = UIBarButtonItem(image: UIImage(named: "ic_left_notification"), style: .done, target: self, action: #selector(displayNotification))
        rightMenuButton.image = UIImage(named: "ic_left_notification")?.withRenderingMode(.alwaysTemplate)
        rightMenuButton.tintColor = .white
        navigationItem.rightBarButtonItem = rightMenuButton
        
        let storeMenuButton = UIBarButtonItem(image: UIImage(named: "icHuneStore"), style: .done, target: self, action: #selector(displayHuneStore))
        storeMenuButton.image = UIImage(named: "icHuneStore")?.withRenderingMode(.alwaysTemplate)
        storeMenuButton.tintColor = .white
        
        let martButton = UIBarButtonItem(image: UIImage(named: "icon_manage_store"), style: .done, target: self, action: #selector(displayMart))
        martButton.image = UIImage(named: "icon_manage_store")?.withRenderingMode(.alwaysTemplate)
        martButton.tintColor = .white
        
        navigationItem.rightBarButtonItems = [rightMenuButton, storeMenuButton, martButton]
    }
    
    func displayMart() {
        self.navigationController?.pushViewController(ProductMartViewController(), animated: true)
    }
    
    func displayHuneStore() {
        let vc = HuneStoreViewController.loadFromNib()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func createGoogleMaps() {
        mapView = GGMapView(frame: CGRect.zero)
        view.safeAddSubview(mapView)
        mapView?.delegate = self
        mapView?.snp.remakeConstraints { (make) in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            _ = categoryView != nil ? make.bottom.equalTo((categoryView?.snp.top)!) : make.bottom.equalTo(view)
        }
    }
    
    func setupAdView(){
        adsView = UIView()
        view.safeAddSubview(adsView)
        adsView?.snp.makeConstraints { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(0)
        }
        AdsManager.sharedInstance.showAds(customType: .adGGSmartTopView, inView: adsView)
        AdsManager.sharedInstance.availableHandler = { [weak self] (customType, isAvailable) -> Void in
            guard customType == .adGGSmartTopView else {
                return
            }
            let height = isAvailable ? 50 : 0
            self?.adsView?.snp.updateConstraints({ (make) in
                make.height.equalTo(height)
            })
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    self?.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func setupCreateButton() {
        createButton = UIButton(type: .custom)
        
        if postType == PostType.findJob {
            createButton?.setTitle("Recruit".localized(), for: .normal)
        }
        else {
            createButton?.setTitle("Booking".localized(), for: .normal)
        }
        createButton?.backgroundColor = backGroundColor
        createButton?.setTitleColor(UIColor.white, for: .normal)
        
        createButton?.addTarget(self, action: #selector(createNewPost), for: .touchUpInside)
        createButton?.alpha = 1
        createButton?.isHidden = false
        view.safeAddSubview(createButton)
        createButton?.snp.makeConstraints({ (make) in
            make.height.equalTo(40)
            let buttonWidth = createButton != nil ?  (createButton?.intrinsicContentSize.width)! : 100
            make.width.equalTo(buttonWidth + 50)
            make.centerX.equalTo(view)
            _ = categoryView != nil ? make.bottom.equalTo((categoryView?.snp.top)!).offset(-10) : make.bottom.equalTo(view).offset(-50)
        })
        createButton?.layer.cornerRadius = 20
        
    }
    
    func setupMappEmpty(_ check: Bool) {
        if check == true {
            viewMessage?.isHidden = false
        } else {
            viewMessage?.isHidden = true
        }
    }
    
    func toggleCreateButton(_ enable: Bool) {
        if Authenticator.shareInstance.loginType == .guest{
            return
        }
        createButton?.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.createButton?.alpha = enable ? 1 : 0
        }) { (isFinished) in
            self.createButton?.isHidden = !enable
        }
    }
    
    func pushToPostViewController(with model: TempPostModel? = nil) {
        var categories = CategoryModel.copy(from: categoryView?.items)
        if model == nil {
            categories = CategoryModel.clearSelection(of: categories)
        }
        categories = categories != nil ? categories : [CategoryModel]()
        let postVC = ControllerFactory.shared.makeController(type: .post, with: ["categories": categories as Any,
                                                                                 "postModel" : model as Any])
        navigationController?.pushViewController(postVC, animated: true)
    }
    
    func createNewPost() {
        if Authenticator.shareInstance.loginType == .guest{
            Authenticator.shareInstance.popupAuthSignInViewCtl(in: self)
        }
        else {
            if Authenticator.shareInstance.getPostType() == PostType.findPeople {
                ShareData.typeManager = "2"
                let postJobViewController = PostJobViewController(nibName: "PostJobViewController", bundle: nil)
                navigationController?.pushViewController(postJobViewController, animated: true)
            }
            else {
                if CLLocationManager.locationServicesEnabled() {
                    switch(CLLocationManager.authorizationStatus()) {
                    case .notDetermined, .restricted, .denied:
                        UIAlertController.showSimpleAlertView(in: self, title: "Không tìm thấy địa điểm", message: "Vui lòng cho ứng dụng sử dụng vị trí của bạn", buttonTitle: "OK", action: { (action) in
                            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                                return
                            }
                            
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                        print("Settings opened: \(success)") // Prints true
                                    })
                                } else {
                                    // Fallback on earlier versions
                                }
                            }
                        })
                        print("No access")
                    case .authorizedAlways, .authorizedWhenInUse:
                        ShareData.typeManager = "1"
                        let findJobViewController = DefaultFindJobViewController(nibName: "DefaultFindJobViewController", bundle: nil)
                        navigationController?.pushViewController(findJobViewController, animated: true)
                        print("Access")
                        
                        
                        
                    }
                } else {
                    UIAlertController.showSimpleAlertView(in: self, title: "Không tìm thấy địa điểm", message: "Vui lòng cho ứng dụng sử dụng vị trí của bạn", buttonTitle: "OK", action: { (action) in
                        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    print("Settings opened: \(success)") // Prints true
                                })
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    })
                    print("Location services are not enabled")
                }
            }
        }
    }
    
    // cr
    func createBanerMapEmpty() -> UIView {
        
        let inforViewWidth: CGFloat = 230
        let inforView = UIView()
        inforView.frame = CGRect(x: 0, y: 0, width: inforViewWidth, height: 70 )
        inforView.backgroundColor = UIColor.white
        inforView.layer.cornerRadius = 5
        inforView.clipsToBounds = true
        
        let lbMessage = UILabel()
        lbMessage.font = UIFont(name: "Lato-Bold", size: 12)
        lbMessage.textAlignment = .center
        lbMessage.numberOfLines = 0
        inforView.addSubview(lbMessage)
        lbMessage.snp.makeConstraints { (make) in
            make.left.equalTo(inforView.snp.left).offset(3)
            make.right.equalTo(inforView.snp.right).offset(-3)
            make.top.equalTo(inforView.snp.top).offset(3)
        }
        
        if postType == PostType.findJob {
            lbMessage.text = "MessageMapEmptyRed".localized()
        }
        else {
            lbMessage.text = "MessageMapEmptyBlue".localized()
        }
        
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: inforViewWidth, height: 78 ))
        containerView.addSubview(inforView)
        containerView.backgroundColor = UIColor.clear
        
        let triangle = TriangleView(frame: CGRect(x: (inforViewWidth - 8)/2, y: 70, width: 8  , height: 8))
        triangle.backgroundColor = UIColor.clear
        containerView.addSubview(triangle)
        
        return containerView
    }
    
    func setupCategoryView(with items: [CategoryModel]) {
        categoryView = CategoryView(frame: CGRect.zero, and: items, _selectionCallback: {[weak self] selectedCategories in
            guard let weakSelf = self else {
                return
            }
            weakSelf.filterModel.categories = selectedCategories
            weakSelf.filterModel.isSubCategory = false
            weakSelf.filterModelDidChange(to: weakSelf.filterModel)
            }, _selectionCallbackSubcategory: {[weak self] selectedCategories in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.filterModel.categories = selectedCategories
                weakSelf.filterModel.isSubCategory = true
                weakSelf.filterModelDidChange(to: weakSelf.filterModel)
        })
        categoryView?.backgroundColor = backGroundColor
        
        view.safeAddSubview(categoryView)
        categoryView?.snp.makeConstraints({ (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(0)
            _ = adsView != nil ? make.bottom.equalTo((adsView?.snp.top)!) : make.bottom.equalTo(view)
        })
        
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.categoryView?.snp.updateConstraints({ (make) in
                    make.height.equalTo((self.categoryView?.cellSize)!)
                })
                self.view.layoutIfNeeded()
            })
        }
        setupCreateButton()
    }
    
    //MARK: - Get data from server
    func getCategoryFromServer() {
        ServiceManager.category.getCategory { (result) in
            switch result {
            case let .success(categories, _):
                Authenticator.shareInstance.setCategoryList(categoryList:categories)
                DispatchQueue.main.async {
                    self.setupCategoryView(with: categories)
                    self.view.setNeedsUpdateConstraints()
                    self.mapView?.showCircleView()
                }
            case let .failure(error):
                Authenticator.shareInstance.setCategoryList(categoryList: nil)
                self.getCategoryFromServer()
                log.debug(error.errorMessage)
            }
        }
    }
    
    func filterModelDidChange(to newFilterModel: FilterModel, isLocationChanged: Bool = false) {
        guard let isChangeZoomLevel = mapView?.isChangeZoomLevel,
            let calculate = self.mapView?.calculateRadius(),
            filterModel.categories != nil else {
                return
        }
        
        if !isChangeZoomLevel && isLocationChanged &&
            !(mapView?.lastLocation == nil || ((mapView?.lastLocation?.distance(from: calculate.location))! > Double(calculate.radius)/3)) {
            return
        }
        newFilterModel.geoLocation = calculate.location
        newFilterModel.radius = calculate.radius
        mapView?.lastLocation = calculate.location
        self.mapView?.clearAllMarker()
        
        uuid = UUID()
        
        getPost(id: uuid, filter: newFilterModel, page: 0)
    }
    
    func getPost(id: UUID, filter: FilterModel, paging: PagingModel? = nil, page: Int) {
        ServiceManager.post.getPosts(filterModel: filter, pagingModel: paging) { (result, paging) in
            switch result{
            case let .success(posts, _):
                if id == self.uuid{
                    self.updateMap(id: id, filter: filter, posts: posts, paging: paging, page: page)
                    self.posts = posts
                    print(posts)
                    // check posts and show view message map empty
                    if posts.count != 0 {
                        self.setupMappEmpty(false)
                    } else {
                        self.setupMappEmpty(true)
                    }
                }
            case let .failure(error):
                log.debug("error: \(String(describing: error.errorMessage))")
            }
        }
    }
    
    func updateMap(id: UUID, filter: FilterModel, posts: [PostModel], paging: PagingModel?, page: Int) {
        for post in posts {
            self.mapView?.addMarkerWithFeed(post)
        }
        mapView?.mapView.selectedMarker = mapView?.mappingMarkers.first?.marker
    }
}


//MARK: - GMSMapViewDelegate
extension RecruitmentViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let coordinate = position.target
        filterModel.geoLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        Authenticator.shareInstance.setLocation(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        filterModelDidChange(to: filterModel, isLocationChanged: true)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if Authenticator.shareInstance.loginType == .guest{
            Authenticator.shareInstance.popupAuthSignInViewCtl(in: self)
        }
        else if let postModel = self.mapView?.getPostWith(marker) {
            if Authenticator.shareInstance.getPostType() == PostType.findPeople {
                let candidateDetailViewController = CandidateDetailViewController(nibName: "CandidateDetailViewController", bundle: nil)
                candidateDetailViewController.postModel = postModel
                navigationController?.pushViewController(candidateDetailViewController, animated: true)
            }
            else {
                let jobDetailViewController = JobDetailViewController(nibName: "JobDetailViewController", bundle: nil)
                jobDetailViewController.postModel = postModel
                navigationController?.pushViewController(jobDetailViewController, animated: true)
            }
        }
        mapView.selectedMarker = marker
        return true
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if Authenticator.shareInstance.getPostType() == PostType.findPeople {
            if let postModel = self.mapView?.getPostWith(marker) {
                self.currentPost = postModel
                let descriptionLBHeight : CGFloat = 0
                let inforViewWidth: CGFloat = 160
                let inforView = UIView()
                inforView.frame = CGRect(x: 0, y: 0, width: inforViewWidth, height: 70 + descriptionLBHeight)
                let padding: CGFloat = 10.0
                let padingRating: CGFloat = inforView.frame.size.width/2 - 20.0
                inforView.backgroundColor = UIColor.white
                inforView.layer.cornerRadius = 5
                inforView.clipsToBounds = true
        
                let titleLB = UILabel()
                inforView.addSubview(titleLB)
                titleLB.snp.makeConstraints({ (make) in
                    make.top.equalTo(inforView.snp.top).offset(3)
                    make.left.equalTo(inforView.snp.left).offset(padding)
                    make.width.equalTo(inforViewWidth - 2*padding)
                })
                titleLB.numberOfLines = 0
                if let nameWork = postModel.category![0].name_vi {
                    titleLB.text = postModel.full_name! + " - " + "\(String(describing: nameWork))"
                }

                titleLB.font = UIFont(name: "Lato-Bold", size: 12)
                inforView.addSubview(titleLB)
                
                let ratingView = TPFloatRatingView()
                inforView.addSubview(ratingView)
                ratingView.snp.makeConstraints({ (make) in
                    make.top.equalTo(titleLB.snp.bottom).offset(5 )
                    make.left.equalTo(inforView.snp.left).offset(padingRating)
                    make.width.equalTo(50)
                    make.height.equalTo(8.0)
                })
                ratingView.emptySelectedImage = UIImage(named: "star_empty")
                ratingView.fullSelectedImage = UIImage(named:"star_full")
                ratingView.contentMode =  .scaleAspectFit
                ratingView.maxRating = 5
                ratingView.minRating = 1
                ratingView.halfRatings = false
                ratingView.floatRatings = false
                if let rating = postModel.rating {
                    ratingView.rating = rating
                }
                else {
                    ratingView.rating = 1
                }
                ratingView.editable = false
                inforView.addSubview(ratingView)
                
                let lbLevel = UILabel()
                if ratingView.rating >= 0 && ratingView.rating <= 1 {
                    lbLevel.text = "Level".localized() + ": " + "Copper".localized()
                } else if ratingView.rating > 1 && ratingView.rating <= 2   {
                    lbLevel.text = "Level".localized() + ": " + "Silver".localized()
                } else if ratingView.rating > 2  && ratingView.rating <= 3 {
                    lbLevel.text = "Level".localized() + ": " + "Gold".localized()
                } else if ratingView.rating > 3  && ratingView.rating <= 4 {
                    lbLevel.text = "Level".localized() + ": " + "Platinum".localized()
                } else {
                    lbLevel.text = "Level".localized() + ": " + "Diamond".localized()
                }
                lbLevel.font = UIFont(name: "Lato-Bold", size: 12)
                inforView.addSubview(lbLevel)
                lbLevel.snp.makeConstraints({ (make) in
                    make.top.equalTo(ratingView.snp.bottom).offset(5)
                    make.centerX.equalTo(inforView)
                })
                lbLevel.sizeToFit()
                
                let containerView = UIView(frame: CGRect(x: 0, y: 0, width: inforViewWidth, height: 78 + descriptionLBHeight))
                containerView.addSubview(inforView)
                containerView.backgroundColor = UIColor.clear
                
                let triangle = TriangleView(frame: CGRect(x: (inforViewWidth - 8)/2, y: 70 , width: 8  , height: 8))
                triangle.backgroundColor = UIColor.clear
                containerView.addSubview(triangle)
                
                return containerView
                
            }
            else {
                return nil
            }
        } else {
            if let postModel = self.mapView?.getPostWith(marker) {
                self.currentPost = postModel
                let descriptionLBHeight : CGFloat = 0
                let inforViewWidth: CGFloat = 160
                let inforView = UIView()
                inforView.frame = CGRect(x: 0, y: 0, width: inforViewWidth, height: 85 + descriptionLBHeight)
                let padding: CGFloat = 10.0
                let padingRating: CGFloat = inforView.frame.size.width/2 - 20.0
                inforView.backgroundColor = UIColor.white
                inforView.layer.cornerRadius = 5
                inforView.clipsToBounds = true
                
                let titleLB = UILabel()
                inforView.addSubview(titleLB)
                titleLB.snp.makeConstraints({ (make) in
                    make.top.equalTo(inforView.snp.top).offset(3)
                    make.left.equalTo(inforView.snp.left).offset(padding)
                    make.width.equalTo(inforViewWidth - 2*padding)
                })
                titleLB.numberOfLines = 0
                if let count = postModel.quantity , let category_title = postModel.category_title {
                    titleLB.text = postModel.full_name! + "Need".localized() + " \(String(describing: count)) " + "\(String(describing: category_title).lowercased())"
                }
                titleLB.font = UIFont(name: "Lato-Bold", size: 12)
                inforView.addSubview(titleLB)
                
                let ratingView = TPFloatRatingView()
                inforView.addSubview(ratingView)
                ratingView.snp.makeConstraints({ (make) in
                    make.top.equalTo(titleLB.snp.bottom).offset(5 )
                    make.left.equalTo(inforView.snp.left).offset(padingRating)
                    make.width.equalTo(50)
                    make.height.equalTo(8.0)
                })
                
                ratingView.emptySelectedImage = UIImage(named: "star_empty")
                ratingView.fullSelectedImage = UIImage(named:"star_full")
                ratingView.contentMode =  .scaleAspectFit
                ratingView.maxRating = 5
                ratingView.minRating = 1
                ratingView.halfRatings = false
                ratingView.floatRatings = false
                if let rating = postModel.rating {
                    ratingView.rating = rating
                }
                else {
                    ratingView.rating = 1
                }
                ratingView.editable = false
                inforView.addSubview(ratingView)
                
                let lbLevel = UILabel()
                if ratingView.rating > 2  && ratingView.rating <= 3 {
                    lbLevel.text = "Reputation".localized() + ": " + "Gold".localized()
                } else if ratingView.rating > 3  && ratingView.rating <= 4 {
                    lbLevel.text = "Reputation".localized() + ": " + "Platinum".localized()
                } else {
                    lbLevel.text = "Reputation".localized() + ": " + "Diamond".localized()
                }
                lbLevel.font = UIFont(name: "Lato-Bold", size: 12)
                inforView.addSubview(lbLevel)
                lbLevel.snp.makeConstraints({ (make) in
                    make.top.equalTo(ratingView.snp.bottom).offset(5)
                    make.centerX.equalTo(inforView)
                })
                lbLevel.sizeToFit()
                
                let containerView = UIView(frame: CGRect(x: 0, y: 0, width: inforViewWidth, height: 93 + descriptionLBHeight))
                containerView.addSubview(inforView)
                containerView.backgroundColor = UIColor.clear
                
                let triangle = TriangleView(frame: CGRect(x: (inforViewWidth - 8)/2, y: 85, width: 8  , height: 8))
                triangle.backgroundColor = UIColor.clear
                containerView.addSubview(triangle)
                
                return containerView
                
            }
            else {
                return nil
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if Authenticator.shareInstance.loginType == .guest{
            Authenticator.shareInstance.popupAuthSignInViewCtl(in: self)
        }
        else if let postModel = self.currentPost {
            if Authenticator.shareInstance.getPostType() == PostType.findPeople {
                let candidateDetailViewController = CandidateDetailViewController(nibName: "CandidateDetailViewController", bundle: nil)
                candidateDetailViewController.postModel = postModel
                navigationController?.pushViewController(candidateDetailViewController, animated: true)
            }
            else {
                let jobDetailViewController = JobDetailViewController(nibName: "JobDetailViewController", bundle: nil)
                jobDetailViewController.postModel = postModel
                navigationController?.pushViewController(jobDetailViewController, animated: true)
            }
        }
    }
}

class TriangleView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.maxY))
        context.closePath()
        context.setFillColor(UIColor.white.cgColor)
        context.fillPath()
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
