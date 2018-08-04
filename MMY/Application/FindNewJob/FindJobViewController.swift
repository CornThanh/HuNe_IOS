
import UIKit
import CoreLocation
import GoogleMaps
import NVActivityIndicatorView
import DropDown
import MMDrawerController
import MMDrawerController

class FindJobViewController: UIViewController {
    
    var backGroundColor = UIColor(hexString: "#CC3333")
    
    var postModel : PostModel?
    var indexData: Int = 0
    var arrIndex = [Int]()
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var uploadImageBtn: UIButton!
    
    @IBOutlet weak var lbType: UILabel! {
        didSet {
            lbType.text = "Type".localized()
        }
    }
    @IBOutlet weak var typeBtn: UIButton!
    @IBOutlet weak var typeLB: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    
    @IBOutlet weak var lbTitle: UILabel! {
        didSet {
            lbTitle.text = "Title".localized()
        }
    }
    @IBOutlet weak var jobTitleTF: UITextField!
    
    @IBOutlet weak var lbDescription: UILabel! {
        didSet {
            lbDescription.text = "Description".localized()
        }
    }
    @IBOutlet weak var descriptionView: UIView!
    
    @IBOutlet weak var lbImage: UILabel! {
        didSet {
            lbImage.text = "Images".localized()
        }
    }
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var uploadBtn: UIButton! {
        didSet {
            uploadBtn.setTitle("Upload".localized(), for: .normal)
        }
    }
    
    @IBOutlet weak var descriptionTF: UITextView!
    @IBOutlet weak var doneBtn: UIButton! {
        didSet {
            doneBtn.setTitle("Done".localized().uppercased(), for: .normal)
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let pickerView = UIPickerView()
    private let datePickerView = UIDatePicker()
    private let contentPickerView = UIView()
    private let overLapView = UIView()
    fileprivate var typePicker: Int = 1 // 1: quality, 2: date start, 3: date end, 4: Period
    
    fileprivate var quality: Int = 1
    private var rating: CGFloat = 1
    private var placeString: String?
    private var location: CLLocation?
    private var salaryString: String?
    fileprivate var paymentPeriod = TempPostModel.PaymentPeriod.hour
    fileprivate var startDate: Date?
    fileprivate var endDate: Date?
    private var jobDescription: String?
    fileprivate var selectedCategories: [CategoryModel]?
    var postID : String?
    
    fileprivate var selectedImageIndex: Int?
    
    private let geoCoder = GMSGeocoder()
    let dateFormatter = DateFormatter()
    
    var activityIndicator: NVActivityIndicatorView?
    
    var isUploadAvatar: Bool = true // true when camera is used for upload avatar, false : upload other image
    var avatar: UIImage?
    var images = [UIImage]()
    var address : String = ""
    
    let jobDropDown = DropDown()
    
    let locationManager = CLLocationManager()
    
    init(_ index: Int, postModelID : String, arrCheck: [Int]) {
        super.init(nibName: "FindJobViewController", bundle: nil)
        indexData = index
        self.arrIndex = arrCheck
        self.postID = postModelID
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("error load nib")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configNavigaton()
        print(indexData)
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        avatarImage.layer.cornerRadius = avatarImage.frame.size.height/2.0
        avatarImage.clipsToBounds = true
        uploadImageBtn.layer.cornerRadius = uploadImageBtn.frame.height/2.0
        uploadImageBtn.clipsToBounds = true
        let uploadImageBtnImage = UIImage(named: "icon_upload")?.withRenderingMode(.alwaysTemplate)
        uploadImageBtn.setImage(uploadImageBtnImage, for: .normal)
        uploadImageBtn.imageView?.tintColor = UIColor.white
        uploadImageBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        uploadImageBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        
        //        typeBtn.layer.cornerRadius = typeBtn.frame.height/2.0
        //        typeBtn.clipsToBounds = true
        //        typeBtn.layer.borderWidth = 1
        //        typeBtn.layer.borderColor = backGroundColor?.cgColor
        //        typeImage.image = typeImage.image?.withRenderingMode(.alwaysTemplate)
        //        typeImage.tintColor = backGroundColor
        selectedCategories = CategoryModel.getSelectedCategory(in: Authenticator.shareInstance.getCategoryList())
        //        typeLB.text = CategoryModel.makeString(from: selectedCategories)
        
        //        jobTitleTF.layer.cornerRadius = jobTitleTF.frame.height/2.0
        //        jobTitleTF.clipsToBounds = true
        //        jobTitleTF.layer.borderWidth = 1
        //        jobTitleTF.layer.borderColor = backGroundColor?.cgColor
        //        let jobTitleTFPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: jobTitleTF.frame.height))
        //        jobTitleTF.leftView = jobTitleTFPaddingView
        //        jobTitleTF.leftViewMode = .always
        
        //        choosePlaceBtn.layer.cornerRadius = choosePlaceBtn.frame.height/2.0
        //        choosePlaceBtn.clipsToBounds = true
        //        choosePlaceBtn.layer.borderWidth = 1
        //        choosePlaceBtn.layer.borderColor = backGroundColor?.cgColor
        
        descriptionView.layer.cornerRadius = 5
        descriptionView.clipsToBounds = true
        descriptionView.layer.borderWidth = 1
        descriptionView.layer.borderColor = backGroundColor?.cgColor
        
        image1.layer.cornerRadius = 5
        image1.clipsToBounds = true
        image2.layer.cornerRadius = 5
        image2.clipsToBounds = true
        image3.layer.cornerRadius = 5
        image3.clipsToBounds = true
        uploadBtn.layer.cornerRadius = uploadBtn.frame.height/2.0
        uploadBtn.clipsToBounds = true
        uploadBtn.setImage(uploadImageBtnImage, for: .normal)
        uploadBtn.imageView?.tintColor = UIColor.white
        uploadBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        uploadBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapImageView1(_:)))
        image1.addGestureRecognizer(tap)
        image1.isUserInteractionEnabled = true
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.tapImageView2(_:)))
        image2.addGestureRecognizer(tap2)
        image2.isUserInteractionEnabled = true
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.tapImageView3(_:)))
        image3.addGestureRecognizer(tap3)
        image3.isUserInteractionEnabled = true
        
        
        doneBtn.layer.cornerRadius = doneBtn.frame.height/2.0
        doneBtn.clipsToBounds = true
        
        if location == nil {
            if let location = Authenticator.shareInstance.getLocation() {
                self.locationChanged(to: location)
            }
        }
        
        setupActivityIndicator()
        
        //        collectionView.register(UINib.init(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        //        collectionView.dataSource = self
        //        collectionView.delegate = self
        //        collectionView.showsHorizontalScrollIndicator = false
        
        
        setupActivityIndicator()
        
        if let postModel = postModel {
            self.activityIndicator?.startAnimating()
            ServiceManager.postService.get(postId: (postModel.postID)!) { [unowned self] (result) in
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
        
        //updateTypeTitle()
        //setupJobDropDown()
        
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
    
    func updateTypeTitle() {
        if let category = selectedCategories?[1] {
            typeLB.text = category.name
        }
    }
    
    func setUpWithPostModel(postModel: PostModel) {
        if let urlString = postModel.thumbnail {
            let url = URL(string: urlString)
            avatarImage.kf.setImage(with: url, placeholder: UIImage(named : "no_image_available") , options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.selectedCategories = [CategoryModel]()
        if let parentCategory = Authenticator.shareInstance.getCategoryFromId(id: postModel.category_parent_id!) {
            self.selectedCategories?.append(parentCategory)
        }
        if let category = Authenticator.shareInstance.getCategoryFromId(id: postModel.category_id!) {
            self.selectedCategories?.append(category)
        }
        
        //collectionView.reloadData()
        //self.setupJobDropDown()
        //self.updateTypeTitle()
        
        jobTitleTF.text = postModel.title
        if let address = postModel.address {
            //            choosePlaceLB.text = address
            self.address = address
        }
        
        descriptionTF.text = postModel.description
        
        images.removeAll()
        if postModel.images?.count == 1 {
            let url = URL(string: (postModel.images?[0])!)
            image1.kf.setImage(with: url, placeholder: UIImage(named : "no_image_available") , options: nil, progressBlock: nil, completionHandler: nil)
            
            image1.kf.setImage(with: url, placeholder: UIImage(named : "no_image_available"), options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                if let image = image {
                    self.images.append(image)
                }
            })
            
            
        }
        else if postModel.images?.count == 2 {
            let url = URL(string: (postModel.images?[0])!)
            image1.kf.setImage(with: url, placeholder: UIImage(named : "no_image_available") , options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                if let image = image {
                    self.images.append(image)
                }
            })
            let url2 = URL(string: (postModel.images?[1])!)
            image2.kf.setImage(with: url2, placeholder: UIImage(named : "no_image_available") , options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                if let image = image {
                    self.images.append(image)
                }
            })
        }
        else if postModel.images?.count == 3 {
            let url = URL(string: (postModel.images?[0])!)
            image1.kf.setImage(with: url, placeholder: UIImage(named : "no_image_available") , options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                if let image = image {
                    self.images.append(image)
                }
            })
            let url2 = URL(string: (postModel.images?[1])!)
            image2.kf.setImage(with: url2, placeholder: UIImage(named : "no_image_available") , options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                if let image = image {
                    self.images.append(image)
                }
            })
            let url3 = URL(string: (postModel.images?[2])!)
            image3.kf.setImage(with: url3, placeholder: UIImage(named : "no_image_available") , options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                if let image = image {
                    self.images.append(image)
                }
            })
        }
        
        if location == nil {
            location = postModel.location
        }
    }
    
    func setupActivityIndicator() {
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0), type: .ballSpinFadeLoader, color: UIColor.black, padding: 0)
        view.addSubview(activityIndicator!)
        activityIndicator?.snp.makeConstraints({ (make) in
            make.center.equalTo(view)
        })
    }
    
    func setupJobDropDown() {
        jobDropDown.anchorView = typeBtn
        jobDropDown.bottomOffset = CGPoint(x: 0, y: typeBtn.bounds.height)
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
                self.updateTypeTitle()
            }
        }
    }
    
    
    func configNavigaton()  {
        
        // Add left bar button
        let leftButton = UIButton.init(type: .custom)
        leftButton.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        leftButton.addTarget(self, action:#selector(onBtnBack), for: UIControlEvents.touchUpInside)
        leftButton.frame = CGRect.init(x: 0, y: 0, width: 10, height: 20)
        leftButton.tintColor = .white
        leftButton.backgroundColor = .clear
        let leftBarButton = UIBarButtonItem.init(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        // Add right bar button
        let rightMenuButton = UIBarButtonItem(image: UIImage(named: "icon_notification"), style: .done, target: self, action: #selector(displayNotification))
        rightMenuButton.image = UIImage(named: "icon_notification")?.withRenderingMode(.alwaysTemplate)
        rightMenuButton.tintColor = .white
        
        let storeMenuButton = UIBarButtonItem(image: UIImage(named: "icHuneStore"), style: .done, target: self, action: #selector(displayHuneStore))
        storeMenuButton.image = UIImage(named: "icHuneStore")?.withRenderingMode(.alwaysTemplate)
        storeMenuButton.tintColor = .white
        
        navigationItem.rightBarButtonItems = [rightMenuButton, storeMenuButton]
        
        // Title
        if self.postModel != nil {
            title = "EditInfo".localized()
        }
        else {
            title = "AddJob".localized()
        }
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "Lato-Regular", size: 15)!]
    }
    
    func tapImageView1(_ sender: UITapGestureRecognizer) {
        uploadImageAt(index: 0)
    }
    
    func tapImageView2(_ sender: UITapGestureRecognizer) {
        uploadImageAt(index: 1)
    }
    
    func tapImageView3(_ sender: UITapGestureRecognizer) {
        uploadImageAt(index: 2)
    }
    
    func uploadImageAt(index: Int) {
        selectedImageIndex = index
        isUploadAvatar = false
        selectImage()
    }
    
    //MARK: - handle user action
    func displayNotification() {
        print("displayNotification")
        let notificationVC = MMYNotificationViewController(nibName: "MMYNotificationViewController", bundle: nil)
        self.navigationController?.pushViewController(notificationVC, animated: true)
    }
    
    
    func displayHuneStore() {
        let vc = HuneStoreViewController.loadFromNib()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onBtnUploadAvatar(_ sender: Any) {
        isUploadAvatar = true
        selectImage()
    }
    
    @IBAction func onBtnType(_ sender: Any) {
        jobDropDown.show()
    }
    
    @IBAction func onBtnChoosePlace(_ sender: Any) {
        let mapPickerViewController = MapPickerViewController()
        mapPickerViewController.location = Authenticator.shareInstance.getLocation()
        mapPickerViewController.onDismissCallback = {[weak self](location) in
            self?.locationChanged(to: location)
            if location != nil {
                //                self?.choosePlaceLB.text = String(format: "%.4f , %.4f", location.coordinate.latitude, location.coordinate.longitude)
            }
        }
        navigationController?.pushViewController(mapPickerViewController, animated: true)
    }
    
    @IBAction func onBtnUploadImage(_ sender: Any) {
        if images.count >= 3 {
            showDialog(title: "", message: "Bạn chỉ có thể upload tối đa 3 hình", handler: nil)
        }
        else {
            isUploadAvatar = false
            selectImage()
        }
    }
    
    @IBAction func onBtnDone(_ sender: Any) {
        if location == nil {
            showDialog(title: "Empty Field".localized(), message: "Location", handler: nil)
        }
        else if descriptionTF.text.characters.count == 0 {
            showDialog(title: "Empty Field".localized(), message: "Mô tả", handler: nil)
        }
        else {
            _ = TempPostModel()
            ShareData.arrNewPost[indexData]?.title = "abc"
            //newPost.categories = selectedCategories
            if let postType = Authenticator.shareInstance.getPostType() {
                ShareData.arrNewPost[indexData]?.postType = postType
            }
            ShareData.arrNewPost[indexData]?.description = self.descriptionTF.text
            ShareData.arrNewPost[indexData]?.location = location
            ShareData.arrNewPost[indexData]?.address = address
            ShareData.arrNewPost[indexData]?.amount = quality
            ShareData.arrNewPost[indexData]?.paymentPeriod = paymentPeriod
            if let avatar = avatar {
                ShareData.arrNewPost[indexData]?.avatar = avatar
            }
            if images.count > 0 {
                ShareData.arrNewPost[indexData]?.images = images
            }
            
            if arrIndex.contains(indexData) && postID != "" {
                editPost(postModel: ShareData.arrNewPost[indexData]!, postID: postID!)
            }
            else {
                self.navigationController?.popViewController(animated: true)
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
                UIAlertController.showSimpleAlertView(in: self, title: "Create new post successfully!".localized(), message: "", buttonTitle: "Back to home".localized(), action: { (action) in
                    self.backToPreviousController()
                })
            case let .failure(error):
                UIAlertController.showSimpleAlertView(in: self, title: "Error".localized(), message: "Something happens while creating new post. Please try again later.".localized())
                log.debug(error.errorMessage)
            }
        }
    }
    
    func editPost(postModel: TempPostModel, postID: String) {
        activityIndicator?.startAnimating()
        ServiceManager.postService.editPostWithImage(postModel, postID: postID) { (resultCode) in
            self.activityIndicator?.stopAnimating()
            if resultCode == ErrorCode.success.rawValue {
                let notificationName = Notification.Name("listFindJogChange")
                NotificationCenter.default.post(name: notificationName, object: nil)
                UIAlertController.showSimpleAlertView(in: self, title: "Thành công", message: "Sửa thông tin bài đăng thành công", buttonTitle: "Trở về trang trước", action: { (action) in
                    self.backToPreviousController()
                })
            }
            else {
                UIAlertController.showSimpleAlertView(in: self, title: "Error".localized(), message: "Có lỗi khi sửa bài đăng, vui lòng thử lại sau")
            }
        }
    }
    
    func cancelPost() {
        let backAction: ((UIAlertAction) -> Void) = { (action) in self.backToPreviousController() }
        //        isModifying ? UIAlertController.showDiscardAlertView(in: self, action: backAction) : backToPreviousController()
        UIAlertController.showDiscardAlertView(in: self, action: backAction)
    }
    
    func backToPreviousController () {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    // Function
    //MARK: Handle Model Change
    func locationChanged(to newLocation: CLLocation?) {
        guard let newLocation = newLocation else {
            return
        }
        location = newLocation
        geoCoder.reverseGeocodeCoordinate(newLocation.coordinate) { [weak self] (response, error) in
            guard let _ = self,
                let location = response?.firstResult() else {
                    return
            }
            if let address = location.lines?.joined(separator: ", ") {
                self?.address = address
            }
            //            weakSelf.choosePlaceLB.text = self?.address
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
    
    //Mark: Function
    func selectImage() {
        func showSelectAvatarOption(with sourceType: UIImagePickerControllerSourceType) {
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
        
        let controller = UIAlertController(title: "", message: "Choose action".localized(), preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera".localized(), style: .default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                showSelectAvatarOption(with: .camera)
            }
            
        }
        let photoAction = UIAlertAction(title: "Photo".localized(), style: .default) { (_) in
            showSelectAvatarOption(with: .photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        controller.addAction(cameraAction)
        controller.addAction(photoAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
}

//MARK: - ImagePickerDelegate
extension FindJobViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if isUploadAvatar {
                avatarImage.image = pickedImage
                avatar = pickedImage
            }
            else {
                if selectedImageIndex == 0 {
                    image1.image = pickedImage
                }
                else if selectedImageIndex == 1 {
                    image2.image = pickedImage
                }
                else {
                    image3.image = pickedImage
                }
                images.removeAll()
                if let image = image1.image {
                    images.append(image)
                }
                if let image = image2.image {
                    images.append(image)
                }
                if let image = image3.image {
                    images.append(image)
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


//extension FindJobViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if let categories = Authenticator.shareInstance.getCategoryList() {
//            return categories.count
//        }
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as!CategoryCollectionViewCell
//        if let categories = Authenticator.shareInstance.getCategoryList() {
//            let category = categories[indexPath.row]
//            cell.updateWithCategory(category: category)
//            cell.checkImage.image = UIImage(named: "icon_uncheck")
//            if let parentSelectedCategory = self.selectedCategories?[0] {
//                if category.categoryId == parentSelectedCategory.categoryId {
//                    cell.checkImage.image = UIImage(named: "icon_check")
//                }
//            }
//        }
//
//        return cell
//    }
//}

//extension FindJobViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 90, height: 90)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if let categories = Authenticator.shareInstance.getCategoryList() {
//            let category = categories[indexPath.row]
//            if let parentSelectedCategory = self.selectedCategories?[0] {
//                if parentSelectedCategory.categoryId != category.categoryId {
//                    self.selectedCategories?.removeAll()
//                    self.selectedCategories?.append(category)
//                    self.selectedCategories?.append((category.children?[0])!)
//                }
//            }
//            collectionView.reloadData()
//            //self.setupJobDropDown()
//            self.updateTypeTitle()
//        }
//    }
//}

extension FindJobViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let _:CLLocationCoordinate2D = manager.location!.coordinate
        if let location = manager.location {
            self.locationChanged(to: location)
        }
    }
}

