
import UIKit
import CoreLocation
import GoogleMaps
import NVActivityIndicatorView
import DropDown

class PostJobViewController: UIViewController {
    
	var postModel: PostModel? {
		didSet {
			postID = postModel?.postID
		}
	}
	var postID: String!
    var linkBanner: String = ""

    @IBOutlet weak var constraintHeightBanner: NSLayoutConstraint!
    @IBOutlet weak var lbHuneAds: UILabel!
    @IBOutlet weak var imgBannerAds: UIImageView!
    @IBOutlet weak var typeBtn: UIButton!
    @IBOutlet weak var typeLB: UILabel! {
        didSet {
            typeLB.text = "Type".localized()
        }
    }

    @IBOutlet weak var lbType: UILabel! {
        didSet {
            lbType.text = "Type".localized()
        }
    }

    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var lbJob: UILabel! {
        didSet {
            lbJob.text = "Job".localized()
        }
    }
    @IBOutlet weak var jobBtn: UIButton! {
        didSet {
            doneBtn.setTitle("Done".localized().uppercased(), for: .normal)
        }
    }
    @IBOutlet weak var jobLB: UILabel! {
        didSet {
            jobLB.text = "SelectJob".localized()
        }
    }
    @IBOutlet weak var jobImage: UIImageView!
    let typeDropDown = DropDown()
    let jobDropDown = DropDown()

    @IBOutlet weak var lbStandard: UILabel!{
        didSet {
            lbStandard.text = "Standard".localized()
        }
    }
    @IBOutlet weak var ratingView: TPFloatRatingView!


    @IBOutlet weak var lbQuality: UILabel! {
        didSet {
            lbQuality.text = "Quality".localized()
        }
    }
    @IBOutlet weak var quantityBtn: UIButton!
    @IBOutlet weak var quantityLB: UILabel!
    @IBOutlet weak var quantityImage: UIImageView!
    
    @IBOutlet weak var lbWorkPlace: UILabel! {
        didSet {
            lbWorkPlace.text = "WorkPlace".localized()
        }
    }
    @IBOutlet weak var choosePlaceBtn: UIButton!
    @IBOutlet weak var choosePlaceLB: UILabel!
    @IBOutlet weak var chooseMapBtn: UIButton! {
        didSet {
            chooseMapBtn.setTitle("SelectMap".localized(), for: .normal)
        }
    }
    
    @IBOutlet weak var lbSalary: UILabel! {
        didSet {
            lbSalary.text = "Salary".localized()
        }
    }
    @IBOutlet weak var salaryTF: UITextField! {
        didSet {
            salaryTF.placeholder = "InputSalary".localized()
        }
    }

    @IBOutlet weak var forTimeLB: UILabel!
    @IBOutlet weak var forTimeBtn: UIButton!
    @IBOutlet weak var forTimeImage: UIImageView!
    
    @IBOutlet weak var lbEndTime: UILabel! {
        didSet {
            lbEndTime.text = "EndTime".localized()
        }
    }
    @IBOutlet weak var endBtn: UIButton!
    @IBOutlet weak var endImage: UIImageView!
    @IBOutlet weak var endLB: UILabel! {
        didSet {
            endLB.text = "EndDate".localized()
        }
    }
    
    @IBOutlet weak var descriptionView: UIView!
    
    @IBOutlet weak var lbDescription: UILabel! {
        didSet {
            lbDescription.text = "Description".localized()
        }
    }
    @IBOutlet weak var descriptionTF: UITextView!
    @IBOutlet weak var doneBtn: UIButton!
    var backGroundColor = UIColor(hexString: "#33CCFF")
    
    private let pickerView = UIPickerView()
    private let datePickerView = UIDatePicker()
    private let contentPickerView = UIView()
    private let overLapView = UIView()
    fileprivate var typePicker: Int = 1 // 1: quality, 2: date start, 3: date end, 4: Period
    
    fileprivate var quality: Int = 1
    private var rating: CGFloat = 0
    private var placeString: String?
    private var location: CLLocation?
    private var salaryString: String?
    fileprivate var paymentPeriod = TempPostModel.PaymentPeriod.hour
    fileprivate var startDate: Date?
    fileprivate var endDate: Date?
    private var jobDescription: String?
    private var selectedCategories: [CategoryModel]?
    
    private let geoCoder = GMSGeocoder()
    let dateFormatter = DateFormatter()
    
    var activityIndicator: NVActivityIndicatorView?
    var isModifying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configNavigaton()
        self.lbHuneAds.isHidden = true
        constraintHeightBanner.constant = 0.0
        self.showBannerPromotionDetail(position: "1", image: imgBannerAds, constrain: constraintHeightBanner)
        Timer.scheduledTimer(withTimeInterval: 450.0 , repeats: true) { (timer) in
            self.showBannerPromotionDetail(position: "1", image: self.imgBannerAds, constrain: self.constraintHeightBanner)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(eventBanner))
        imgBannerAds.addGestureRecognizer(tap)
        imgBannerAds.isUserInteractionEnabled = true
        
        typeBtn.layer.cornerRadius = typeBtn.frame.height/2.0
        typeBtn.clipsToBounds = true
        typeBtn.layer.borderWidth = 1
        typeBtn.layer.borderColor = backGroundColor?.cgColor
        typeImage.image = typeImage.image?.withRenderingMode(.alwaysTemplate)
        typeImage.tintColor = backGroundColor
        selectedCategories = CategoryModel.getSelectedCategory(in: Authenticator.shareInstance.getCategoryList())
        if let parentCategory = selectedCategories?[0] {
            typeLB.text = parentCategory.name
        }
        
        jobBtn.layer.cornerRadius = jobBtn.frame.height/2.0
        jobBtn.clipsToBounds = true
        jobBtn.layer.borderWidth = 1
        jobBtn.layer.borderColor = backGroundColor?.cgColor
        jobImage.image = jobImage.image?.withRenderingMode(.alwaysTemplate)
        jobImage.tintColor = backGroundColor
        if let category = selectedCategories?[1] {
            jobLB.text =  category.name
        }
        
        ratingView.emptySelectedImage = UIImage(named: "star_empty_yellow")
        ratingView.fullSelectedImage = UIImage(named:"star_full_yellow")
        ratingView.contentMode =  .scaleAspectFill
        ratingView.maxRating = 5
        ratingView.minRating = 0
        ratingView.halfRatings = false
        ratingView.floatRatings = false
        ratingView.rating = rating
        ratingView.editable = true
        
        quantityBtn.layer.cornerRadius = quantityBtn.frame.height/2.0
        quantityBtn.clipsToBounds = true
        quantityBtn.layer.borderWidth = 1
        quantityBtn.layer.borderColor = backGroundColor?.cgColor
        quantityImage.image = quantityImage.image?.withRenderingMode(.alwaysTemplate)
        quantityImage.tintColor = backGroundColor
        
        choosePlaceBtn.layer.cornerRadius = choosePlaceBtn.frame.height/2.0
        choosePlaceBtn.clipsToBounds = true
        choosePlaceBtn.layer.borderWidth = 1
        choosePlaceBtn.layer.borderColor = backGroundColor?.cgColor
        
        chooseMapBtn.layer.cornerRadius = chooseMapBtn.frame.height/2.0
        chooseMapBtn.clipsToBounds = true
        chooseMapBtn.layer.borderWidth = 1
        chooseMapBtn.layer.borderColor = backGroundColor?.cgColor
        
        salaryTF.layer.cornerRadius = salaryTF.frame.height/2.0
        salaryTF.clipsToBounds = true
        salaryTF.layer.borderWidth = 1
        salaryTF.layer.borderColor = backGroundColor?.cgColor
        let salaryTFPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: salaryTF.frame.height))
        salaryTF.leftView = salaryTFPaddingView
        salaryTF.leftViewMode = .always
        salaryTF.keyboardType = .numberPad
        self.forTimeLB.text = paymentPeriod.title()
        
        forTimeBtn.layer.cornerRadius = forTimeBtn.frame.height/2.0
        forTimeBtn.clipsToBounds = true
        forTimeBtn.layer.borderWidth = 1
        forTimeBtn.layer.borderColor = backGroundColor?.cgColor
        forTimeImage.image = forTimeImage.image?.withRenderingMode(.alwaysTemplate)
        forTimeImage.tintColor = backGroundColor
        
        endBtn.layer.cornerRadius = endBtn.frame.height/2.0
        endBtn.clipsToBounds = true
        endBtn.layer.borderWidth = 1
        endBtn.layer.borderColor = backGroundColor?.cgColor
        endImage.image = endImage.image?.withRenderingMode(.alwaysTemplate)
        endImage.tintColor = backGroundColor
        
        descriptionView.layer.cornerRadius = 5
        descriptionView.clipsToBounds = true
        descriptionView.layer.borderWidth = 1
        descriptionView.layer.borderColor = backGroundColor?.cgColor
        
        doneBtn.layer.cornerRadius = doneBtn.frame.height/2.0
        doneBtn.clipsToBounds = true
        
        // For PickerView
        let pickerHeight = CGFloat(120)
        overLapView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        overLapView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        contentPickerView.frame = CGRect(x: 0, y:  UIScreen.main.bounds.size.height - 20 - pickerHeight , width: UIScreen.main.bounds.size.width, height: pickerHeight + 20)
        contentPickerView.backgroundColor = backGroundColor
        
        pickerView.frame = CGRect(x: 0, y:  20 , width: UIScreen.main.bounds.size.width, height: pickerHeight)
        contentPickerView.addSubview(pickerView)
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(0, inComponent: 0, animated: false)
        pickerView.backgroundColor = UIColor.clear
        pickerView.isHidden = true
        
        datePickerView.frame = CGRect(x: 0, y:  20 , width: UIScreen.main.bounds.size.width, height: pickerHeight)
        datePickerView.datePickerMode = .date
        datePickerView.addTarget(self, action: #selector(datePickerChanged(datePicker:)), for: UIControlEvents.valueChanged)
        datePickerView.isHidden = true
        datePickerView.setValue(UIColor.white, forKeyPath: "textColor")
        contentPickerView.addSubview(datePickerView)
        
        let pickerDoneBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width - 70, y: 5, width: 50, height: 15))
        pickerDoneBtn.setTitle("Done", for: .normal)
        pickerDoneBtn.setTitleColor(UIColor.white, for: .normal)
        pickerDoneBtn.backgroundColor = UIColor.clear
        pickerDoneBtn.addTarget(self, action: #selector(onBtnPickerDone), for: .touchUpInside)
        contentPickerView.addSubview(pickerDoneBtn)
        
        overLapView.addSubview(contentPickerView)
        
        navigationController?.view.addSubview(overLapView)
        overLapView.isHidden = true
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let location = Authenticator.shareInstance.getLocation() {
            self.location = location
            self.locationChanged(to: location)
        }
        
        setupActivityIndicator()
        
        if postModel != nil {
            self.activityIndicator?.startAnimating()
            ServiceManager.postService.get(postId: postID) { [unowned self] (result) in
                self.activityIndicator?.stopAnimating()
                switch result {
                case let .success(postModel):
                    self.postModel = postModel
                    self.setUpWithPostModel(postModel: postModel)
                case let .failure(error):
                    log.debug(error.errorMessage)
                }
            }
        }
        
        setupTypeDropDown()
        setupJobDropDown()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // check authen

        if let session = Authenticator.shareInstance.getAuthSession(), let user = session.user {
            if user.verified {

            }
            else {
//                showDialog(title: "Hune".localized(), message: "NeedVerified".localized(), buttonTitle: "Cancel", handler: { (action) in
//                    self.navigationController?.popViewController(animated: true)
//                }, rightButtonTitle: "OK") { (action) in
//                    (UIApplication.shared.delegate as? AppDelegate)?.makeCenterView()
//                }
            }
        }
        else {
            showDialog(title: "Hune".localized(), message: "NeedAuthentication".localized(), buttonTitle: "Cancel", handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }, rightButtonTitle: "OK") { (action) in
                (UIApplication.shared.delegate as? AppDelegate)?.makeCenterView()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
    }

    //MARK: - Setup views
    func setupActivityIndicator() {
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0), type: .ballSpinFadeLoader, color: UIColor.black, padding: 0)
        view.addSubview(activityIndicator!)
        activityIndicator?.snp.makeConstraints({ (make) in
            make.center.equalTo(view)
        })
    }
    
    func configNavigaton()  {
        
        // Add left bar button
        let leftButton = UIButton.init(type: .custom)
        leftButton.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        leftButton.addTarget(self, action:#selector(cancelPost), for: UIControlEvents.touchUpInside)
        leftButton.frame = CGRect.init(x: 0, y: 0, width: 10, height: 20)
        leftButton.tintColor = .white
        leftButton.backgroundColor = .clear
        let leftBarButton = UIBarButtonItem.init(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        // Add right bar button
        let rightMenuButton = UIBarButtonItem(image: UIImage(named: "icon_notification"), style: .done, target: self, action: #selector(displayNotification))
        rightMenuButton.image = UIImage(named: "icon_notification")?.withRenderingMode(.alwaysTemplate)
        rightMenuButton.tintColor = .white

        let storeMenuButton = UIBarButtonItem(image: UIImage(named: "icHuneStore"), style: .done, target: self, action: #selector(displayNotification))
        storeMenuButton.image = UIImage(named: "icHuneStore")?.withRenderingMode(.alwaysTemplate)
        storeMenuButton.tintColor = .white

        navigationItem.rightBarButtonItems = [rightMenuButton, storeMenuButton]
        
        
        // Title
        if self.postModel != nil {
            title = "EditInfo".localized()
        }
        else {
            title = "Recruit".localized()
        }
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "Lato-Regular", size: 15)!]
    }
    
    
    func setUpWithPostModel(postModel: PostModel) {
        self.selectedCategories = [CategoryModel]()
        if let parentCategory = Authenticator.shareInstance.getCategoryFromId(id: postModel.category_parent_id!) {
            self.selectedCategories?.append(parentCategory)
        }
        if let category = Authenticator.shareInstance.getCategoryFromId(id: postModel.category_id!) {
            self.selectedCategories?.append(category)
        }
        self.setupJobDropDown()
        self.updateTypeAndJobTitle()
        if let rating = postModel.rating {
            ratingView.rating = rating
        }

        if let quantity = postModel.amount {
            quantityLB.text = "\(quantity)"
        }
        
        choosePlaceLB.text = postModel.address
        
        salaryTF.text = postModel.salaryWithoutPeriod
        if let period = TempPostModel.PaymentPeriod(rawValue: postModel.salary_type!) {
            forTimeLB.text = period.title()
            paymentPeriod = period
        }
        endLB.text = postModel.end_date
        descriptionTF.text = postModel.description
        
        location = postModel.location
        if let amount = postModel.amount {
            quality = amount
        }
    
        if let startDateString = postModel.start_date {
            self.startDate = dateFormatter.date(from: startDateString)
        }
        if let endDateString = postModel.end_date {
            self.endDate = dateFormatter.date(from: endDateString)
        }
   
    }
    
    func setupTypeDropDown() {
        typeDropDown.anchorView = typeBtn
        typeDropDown.bottomOffset = CGPoint(x: 0, y: typeBtn.bounds.height)
        var typeDataSource = [String]()
        for category in Authenticator.shareInstance.getCategoryList()! {
            typeDataSource.append(category.name!)
        }
        typeDropDown.dataSource = typeDataSource
        typeDropDown.selectionAction = { [unowned self] (index, item) in
            if let category = Authenticator.shareInstance.getCategoryList()?[index] {
                if category.categoryId != self.selectedCategories?[0].categoryId {
                    self.selectedCategories?.removeAll()
                    self.selectedCategories?.append(category)
                    if let childrenCategories = category.children, childrenCategories.count > 0 {
                        self.selectedCategories?.append(childrenCategories[0])
                    }
                    self.setupJobDropDown()
                    self.updateTypeAndJobTitle()
                }
            }
        }
    }
    
    func setupJobDropDown() {
        jobDropDown.anchorView = jobBtn
        jobDropDown.bottomOffset = CGPoint(x: 0, y: jobBtn.bounds.height)
        var jobDataSource = [String]()
        for category in (selectedCategories?[0].children)! {
            jobDataSource.append(category.name!)
        }
        jobDropDown.dataSource = jobDataSource
        jobDropDown.selectionAction = { [unowned self] (index, item) in
            if let category = self.selectedCategories?[0].children?[index] {
                if self.selectedCategories?.count == 2 {
                    self.selectedCategories?.removeLast()
                }
                self.selectedCategories?.append(category)
                self.updateTypeAndJobTitle()
            }
        }
        
    }
    
    func updateTypeAndJobTitle() {
        if let parentCategory = selectedCategories?[0] {
            typeLB.text = parentCategory.name
        }
        if let category = selectedCategories?[1] {
            jobLB.text = category.name
        }
    }
    
    func datePickerChanged(datePicker:UIDatePicker){
        print(datePicker.date)
        let date = datePicker.date
        let dateString = dateFormatter.string(from: date) //pass Date here
        if typePicker == 2 {
            // 2019-05-29 09:35:03 +0000
            startDate = date
        }
        else if (typePicker == 3) {
            endDate = date
            endLB.text = dateString
        }
    }
    
    
    //MARK: - Handle user action
    
    func displayNotification() {
        print("displayNotification")
        let notificationVC = MMYNotificationViewController(nibName: "MMYNotificationViewController", bundle: nil)
        self.navigationController?.pushViewController(notificationVC, animated: true)
    }

    func displayHuneStore() {
        let vc = HuneStoreViewController.loadFromNib()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showBannerPromotionDetail(position: String, image: UIImageView, constrain: NSLayoutConstraint) {
        ServiceManager.adsService.getBanners(position) { (result) in
            switch result {
            case .success(let arrBanner, _):
                if arrBanner.count > 0  {
                    self.lbHuneAds.isHidden = false
                    constrain.constant = 60.0
                    image.layoutIfNeeded()
                    
                    image.sd_setImage(with: URL(string: arrBanner[0].cover!) , placeholderImage: UIImage(named: "placeholder.png"), options: [], completed: nil)
                    self.linkBanner = arrBanner[0].url!
                }
            case .failure(let error):
                print(error.errorCode)
            }
        }
    }
    
    func eventBanner() {
        UIApplication.shared.open(URL(string: linkBanner)!, options: [:], completionHandler: nil)
    }
    
    @IBAction func onBtnType(_ sender: Any) {
        typeDropDown.show()
    }
    
    @IBAction func onBtnJob(_ sender: Any) {
        jobDropDown.show()
    }
    
    
    @IBAction func onBtnQuality(_ sender: Any) {
        typePicker = 1
        self.overLapView.isHidden = false
        pickerView.isHidden = false
        pickerView.reloadAllComponents()
        datePickerView.isHidden = true
        pickerView.selectRow(quality - 1, inComponent: 0, animated: false)
        view.endEditing(true)
    }
    
    @IBAction func onBtnForTime(_ sender: Any) {
        typePicker = 4
        self.overLapView.isHidden = false
        pickerView.isHidden = false
        pickerView.reloadAllComponents()
        pickerView.selectRow(Int(paymentPeriod.rawValue)! - 1, inComponent: 0, animated: false)
        datePickerView.isHidden = true
        view.endEditing(true)
    }
    
    @IBAction func onBtnStart(_ sender: Any) {
        typePicker = 2
        self.overLapView.isHidden = false
        pickerView.isHidden = true
        datePickerView.isHidden = false
        if let startDate = startDate {
            datePickerView.setDate(startDate, animated: true)
        }
        else {
            self.startDate = Date()
            datePickerView.setDate(self.startDate!, animated: true)
        }
        view.endEditing(true)
    }
    
    @IBAction func onBtnEnd(_ sender: Any) {
        typePicker = 3
        self.overLapView.isHidden = false
        pickerView.isHidden = true
        datePickerView.isHidden = false
        if let endDate = endDate {
            datePickerView.setDate(endDate, animated: true)
        }
        else {
            self.endDate = Date()
            datePickerView.setDate(self.endDate!, animated: true)
        }
        view.endEditing(true)
    }
    
    @IBAction func onBtnChoosePlace(_ sender: Any) {
        let mapPickerViewController = MapPickerViewController()
        mapPickerViewController.location = Authenticator.shareInstance.getLocation()
        mapPickerViewController.onDismissCallback = {[weak self](location) in
            self?.locationChanged(to: location)
        }
        navigationController?.pushViewController(mapPickerViewController, animated: true)
    }
    
    func onBtnPickerDone() {
        self.overLapView.isHidden = true
        let date = datePickerView.date
        let dateString = dateFormatter.string(from: date) //pass Date here
        if typePicker == 2 {
            startDate = date
        }
        else if (typePicker == 3) {
            endDate = date
            endLB.text = dateString
        }
    }
    @IBAction func onBtnDone(_ sender: Any) {
        
        if location == nil {
            showDialog(title: "Empty Field".localized(), message: "Location", handler: nil)
        }
        else if choosePlaceLB.text?.count == 0 {
            showDialog(title: "Empty Field".localized(), message: "Địa điểm", handler: nil)
        }
        else if salaryTF.text?.count == 0 {
            showDialog(title: "Empty Field".localized(), message: "Salary", handler: nil)
        }
        else if endDate == nil {
            showDialog(title: "Empty Field".localized(), message: "Ngày kết thúc", handler: nil)
        }
        else if descriptionTF.text.count == 0 {
            showDialog(title: "Empty Field".localized(), message: "Mô tả", handler: nil)
        }
        else {
            let newPost = TempPostModel()

            newPost.categories = selectedCategories
            if let postType = Authenticator.shareInstance.getPostType() {
                newPost.postType = postType
            }
            startDate = Date()
            newPost.description = self.descriptionTF.text
            newPost.location = location
            newPost.address = choosePlaceLB.text
            newPost.amount = quality
            newPost.salary = salaryTF.text
            newPost.paymentPeriod = paymentPeriod
            newPost.rating = ratingView.rating
            newPost.start_date = dateFormatter.string(from: startDate!)
            newPost.end_date = dateFormatter.string(from: endDate!)

            if let post = self.postModel {
                editPost(postModel: newPost, postID: post.postID!)
            }
            else {
                postNewJobToServer(postModel: newPost)
            }
        }
    }

    func postNewJobToServer(postModel: TempPostModel) {
        activityIndicator?.startAnimating()
        ServiceManager.postService.post(postModel) { (categoryModel) in
            self.activityIndicator?.stopAnimating()
            self.view.isUserInteractionEnabled = true
            switch categoryModel {
            case .success(_):
                UIAlertController.showSimpleAlertView(in: self, title: "Thành công".localized(), message: "Bạn đã đăng Booking thành công, bấm vào ok để xem ngay các tin của người dùng HuNe Red phù hợp.", buttonTitle: "Ok".localized(), action: { (action) in
                    self.backToPreviousController()
                })
            case let .failure(error):
                UIAlertController.showSimpleAlertView(in: self, title: "Error".localized(), message: error.errorMessage)
            }
        }
    }

    func editPost(postModel: TempPostModel, postID: String) {
        activityIndicator?.startAnimating()
        ServiceManager.postService.editPost(postModel, postID: postID) { (resultCode) in
            self.activityIndicator?.stopAnimating()
            if resultCode == ErrorCode.success.rawValue {
                UIAlertController.showSimpleAlertView(in: self, title: "Thành công", message: "Bạn đã đăng Booking thành công, bấm vào ok để xem ngay các tin của người dùng HuNe Red phù hợp.", buttonTitle: "Ok", action: { (action) in
                    self.backToPreviousController()
                })
            }
            else {
                UIAlertController.showSimpleAlertView(in: self, title: "Error".localized(), message: "Có lỗi khi sửa bài đăng, vui lòng thử lại sau")
            }
        }
    }

    func cancelPost() {
        self.navigationController?.popViewController(animated: true)
    }

    func backToPreviousController () {
       // _ = navigationController?.popViewController(animated: true)
        let vc = PostsViewController(nibName: "PostsViewController", bundle: nil)
        vc.type = .suitableList
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // Function
    //MARK: - Handle Model Change
    func locationChanged(to newLocation: CLLocation?) {
        guard let newLocation = newLocation else {
            return
        }
        location = newLocation
        geoCoder.reverseGeocodeCoordinate(newLocation.coordinate) { [weak self] (response, error) in
            guard let weakSelf = self,
                let location = response?.firstResult() else {
                    return
            }
            let address = location.lines?.joined(separator: ", ")
            weakSelf.choosePlaceLB.text = address
        }
    }

    func showDialog(title: String, message: String, buttonTitle: String = "OK", handler: ((_ alertAction: UIAlertAction) -> Void)?,  rightButtonTitle: String? = nil, rightHandler: ((_ alertAction: UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: buttonTitle.localized(), style: UIAlertActionStyle.default,handler: handler))
        if let rightButtonTitle = rightButtonTitle {
            alertController.addAction(UIAlertAction(title: rightButtonTitle.localized(), style: UIAlertActionStyle.default,handler: rightHandler))
        }
        present(alertController, animated: true, completion: nil)
    }
}

extension PostJobViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRowsInComponent = 0
        if typePicker == 1 {
            numberOfRowsInComponent = 100
        }
        else if typePicker == 4 {
            numberOfRowsInComponent = TempPostModel.PaymentPeriod.allTitles().count
        }
        return numberOfRowsInComponent
    }
}

extension PostJobViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var string = ""
        if typePicker == 1 {
            string = "\(row + 1)"
        }
        else if typePicker == 4 {
            string = TempPostModel.PaymentPeriod.allTitles()[row]
        }
        
        let attString = NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName:UIColor.white])
        return attString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if typePicker == 1 {
            self.quantityLB.text = "\(row + 1)"
            self.quality = row + 1
        }
        else if typePicker == 4 {
            let paymentPeriod = TempPostModel.PaymentPeriod.allValues[row]
            self.paymentPeriod = paymentPeriod
            self.forTimeLB.text = paymentPeriod.title()
        }
    }
}

