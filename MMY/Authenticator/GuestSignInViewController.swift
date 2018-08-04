//
//  GuestSignInViewController.swift
//  MMY
//
//  Created by Dev on 7/12/17.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import AccountKit
import AccountKit.AKFViewController

class GuestSignInViewController: UIViewController {
    
    //MARK: - Static Constant Properties
    static let timeout: Double = 30
    
    //MARK: - Constant Dimension Properties
    let tableViewWidth: CGFloat = 300
    let tableViewCellHeight: CGFloat = 36
    let tablePaddingCell: CGFloat = 10
    let socialTablePaddingCell: CGFloat = 5
    let cornerRadius: CGFloat = CGFloat(18).fixHeight()
    let logoViewWidth: CGFloat = 100
    let logoViewHeight: CGFloat = 150
    
    let buttonMargin: CGFloat = 10
    let buttonInLineWidth: CGFloat = 140
    let buttonSingleLineWidth: CGFloat = 300
    let socialRowHeight: CGFloat = 44
    let lowMargin: CGFloat = 5
    let mediumMargin: CGFloat = 20
    let hightMargin: CGFloat = 40
    let extraMargin: CGFloat = 80
    
    //MARK: - Auth Properties
    var delegate: AuthSignInDelegate?
    var service: AuthService?
    var cellContents = [AuthLocalSignInCellContent]()
    var buttons = [AuthSignInButton]()
    
    //MARK: - View Properties
    var recruitmentButton = UIButton(), jobSearchButton = UIButton(),doneButton = UIButton()
    var btnVerify = UIButton()
    var btnLanguage = UIButton()
    var localSignInView = UIView(), orView = UIView(), footerGroupView = UIView(), logoView = UIView()
    var appImageView = UIImageView(), backgroundView = UIImageView()
    var appLabel = UILabel()
    var activityIndicator: NVActivityIndicatorView?
    var lbRecruitment = UILabel(), lbJobSearch = UILabel()
    
    
    //MARK: - color
    var inputColor: UIColor?
    var inputPlaceHolderColor: UIColor?
    
    //MARK: - Local Properties
    var json: JSON?
    var isSignUp = false, isForgetPass = false, isLoaded = false, isPopup = false
    var pushUpViewSize: CGFloat = 0
    
    var isHiddenBackButton: Bool = false
    
    
    let accountKit: AKFAccountKit = AKFAccountKit(responseType: AKFResponseType.authorizationCode)
    var accountKitVC: UIViewController!
    let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
    
    
    //MARK: - Display View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0),
                                                    type: .ballSpinFadeLoader,
                                                    color: UIColor.white, padding: 0)
        view.addSubview(activityIndicator!)
        activityIndicator?.snp.makeConstraints({ (make) in
            make.center.equalTo(view)
        })
        
        view.insertSubview(backgroundView, belowSubview: activityIndicator!)
        backgroundView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(view)
            make.height.equalTo(view)
        }
        
        self.initializeView()
        self.load()
        
        // test
        accountKitVC = accountKit.viewControllerForPhoneLogin()
        if let vc = accountKitVC as? AKFViewController {
            if ShareData.changePhoneVerify == false {
                vc.defaultCountryCode = "VN"
            } else {
                vc.defaultCountryCode = "US"
            }
            vc.delegate = self
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        setupAlpha(0)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    
    func initializeView() {
        // Get color from json
        
        backgroundView.isUserInteractionEnabled = true
        self.hideKeyboardWhenTappedAround(target: backgroundView)
        
        logoView.addSubview(appImageView)
        appImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(logoView)
            make.top.equalTo(logoView)
            make.width.equalTo(logoViewWidth.fixWidth())
            make.height.equalTo(logoViewWidth.fixWidth())
        }
        
        appLabel.text = "Slogon".localized()
        appLabel.font = UIFont(name: "Lato-Italic", size: 14)
        appLabel.textColor = .white
        appLabel.textAlignment = .center
        logoView.insertSubview(appLabel, belowSubview: activityIndicator!)
        appLabel.snp.makeConstraints { (make) in
            make.top.equalTo(appImageView.snp.bottom).offset(7)
            make.height.equalTo(tableViewCellHeight)
            make.centerX.equalTo(logoView)
            make.width.equalTo(appLabel.intrinsicContentSize)
        }
        
        
        logoView.backgroundColor = .clear
        logoView.isHidden = false
        view.insertSubview(logoView, belowSubview: activityIndicator!)
        logoView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            //make.top.equalTo(view).offset(CGFloat(70).fixHeight())
            make.top.equalTo(view).offset(CGFloat(45).fixHeight())
            make.width.equalTo(logoViewWidth.fixWidth())
            make.height.equalTo(logoViewHeight.fixHeight())
        }
        
        view.insertSubview(localSignInView, belowSubview: activityIndicator!)
        localSignInView.backgroundColor = .clear
        localSignInView.isUserInteractionEnabled = true
        self.hideKeyboardWhenTappedAround(target: localSignInView)
        localSignInView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(extraMargin.fixWidth())
            make.right.equalTo(view).offset(-extraMargin.fixWidth())
            make.top.equalTo(logoView.snp.bottom).offset(CGFloat(10).fixHeight())
        }
        // cuong
        
        if ( UIDevice.current.model.range(of: "iPad") != nil){
            lbRecruitment.font = UIFont(name: "Lato-Regular", size: 12)
            lbJobSearch.font = UIFont(name: "Lato-Regular", size: 12)
        } else {
            lbRecruitment.font = UIFont(name: "Lato-Regular", size: 15)
            lbJobSearch.font = UIFont(name: "Lato-Regular", size: 15)
        }
        
        localSignInView.insertSubview(lbRecruitment, belowSubview: activityIndicator!)
        lbRecruitment.numberOfLines = 0
        lbRecruitment.textColor = UIColor.white
        lbRecruitment.text = "lbRecruitment1".localized() + "\n" + "lbRecruitment2".localized() + "\n" + "lbRecruitment3".localized() + "\n" + "lbRecruitment4".localized() + "\n" + "lbRecruitment5".localized() + "\n" + "lbRecruitment6".localized()
        lbRecruitment.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(CGFloat(25).fixWidth())
            make.right.equalTo(view)
            make.top.equalTo(localSignInView.snp.top).offset(tableViewCellHeight.fixHeight() + tablePaddingCell.fixWidth())
        }
        
        /////
        recruitmentButton.backgroundColor = UIColor(hexString: "#0099cc")
        recruitmentButton.layer.cornerRadius = cornerRadius
        recruitmentButton.setTitle("Recruitment".localized().uppercased(), for: UIControlState.normal)
        recruitmentButton.titleLabel?.font = UIFont(name: "Lato-Regular", size: 15)
        recruitmentButton.titleLabel?.textColor = UIColor.white
        recruitmentButton.addTarget(self, action: #selector(GuestSignInViewController.recruitment), for: .touchUpInside)
        recruitmentButton.shadowButton()
        localSignInView.addSubview(recruitmentButton)
        recruitmentButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(localSignInView)
            make.top.equalTo(lbRecruitment.snp.bottom).offset(13)
            make.left.equalTo(localSignInView.snp.left).offset(mediumMargin.fixWidth())
            make.height.equalTo(tableViewCellHeight.fixHeight())
        }
        
        let viewSeparate = UIView()
        viewSeparate.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        localSignInView.addSubview(viewSeparate)
        viewSeparate.snp.makeConstraints { (make) in
            make.top.equalTo(recruitmentButton.snp.bottom).offset(10)
            make.height.equalTo(1.0)
            make.left.equalTo(view.snp.left).offset(35.0)
            make.right.equalTo(view.snp.right).offset(-35.0)
        }
        
        localSignInView.insertSubview(lbJobSearch, belowSubview: activityIndicator!)
        lbJobSearch.numberOfLines = 0
        lbJobSearch.textColor = UIColor.white
        lbJobSearch.text = "lbFindJob1".localized() + "\n" + "lbFindJob2".localized() + "\n" + "lbFindJob3".localized() + "\n" + "lbFindJob4".localized() + "\n" + "lbFindJob5".localized() + "\n" + "lbFindJob6".localized() + "\n" + "lbFindJob7".localized()
        lbJobSearch.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(CGFloat(25).fixWidth())
            make.right.equalTo(view)
            make.top.equalTo(viewSeparate.snp.bottom).offset(5)
        }
        jobSearchButton.backgroundColor = UIColor(hexString: "#CC3333") ?? .appColor
        jobSearchButton.layer.cornerRadius = cornerRadius
        jobSearchButton.setTitle("JobSeeking".localized().uppercased(), for: UIControlState.normal)
        jobSearchButton.titleLabel?.font = UIFont(name: "Lato-Regular", size: 15)
        jobSearchButton.titleLabel?.textColor = UIColor.white
        jobSearchButton.addTarget(self, action: #selector(GuestSignInViewController.jobSearch), for: .touchUpInside)
        jobSearchButton.shadowButton()
        localSignInView.addSubview(jobSearchButton)
        jobSearchButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(localSignInView)
            make.top.equalTo(lbJobSearch.snp.bottom).offset(13)
            make.left.equalTo(localSignInView.snp.left).offset(mediumMargin.fixWidth())
            make.height.equalTo(tableViewCellHeight.fixHeight())
        }
        
        localSignInView.snp.makeConstraints { (make) in
            make.bottom.equalTo(jobSearchButton.snp.bottom)
        }
        
        // Language
        btnLanguage.backgroundColor = UIColor(hexString: "#0099cc")
        btnLanguage.layer.cornerRadius = cornerRadius
        btnLanguage.titleLabel?.font = UIFont(name: "Lato-Regular", size: 15)
        btnLanguage.titleLabel?.textColor = UIColor.white
        btnLanguage.addTarget(self, action: #selector(GuestSignInViewController.changeLanguageTouched), for: .touchUpInside)
        btnLanguage.shadowButton()
        view.addSubview(btnLanguage)
        btnLanguage.snp.makeConstraints { (make) in
            make.centerX.equalTo(localSignInView)
            make.left.equalTo(localSignInView.snp.left).offset(mediumMargin.fixWidth())
            make.height.equalTo(tableViewCellHeight.fixHeight())
            
            if ( UIDevice.current.model.range(of: "iPad") != nil){
                appLabel.isHidden = true
                make.top.equalTo(logoView.snp.bottom).offset(-10.0)
            } else {
                make.top.equalTo(appLabel.snp.bottom).offset(tablePaddingCell.fixWidth())
            }
            
        }
        
        let imageVN = UIImageView()
        imageVN.image = UIImage(named: "ic_VN")
        btnLanguage.addSubview(imageVN)
        imageVN.snp.makeConstraints { (make) in
            make.left.equalTo(btnLanguage.snp.left).offset(50.0)
            make.centerY.equalTo(btnLanguage.snp.centerY)
            make.height.equalTo(btnLanguage.snp.height).multipliedBy(0.8)
            make.width.equalTo(imageVN.snp.height)
        }
        
        let imageUS = UIImageView()
        imageUS.image = UIImage(named: "ic_US")
        btnLanguage.addSubview(imageUS)
        imageUS.snp.makeConstraints { (make) in
            make.right.equalTo(btnLanguage.snp.right).offset(-50.0)
            make.centerY.equalTo(btnLanguage.snp.centerY)
            make.height.equalTo(btnLanguage.snp.height).multipliedBy(0.8)
            make.width.equalTo(imageUS.snp.height)
        }
        
        if let session = Authenticator.shareInstance.getAuthSession() {
            if let user = session.user, !user.verified {
                // verify
                btnVerify.backgroundColor = UIColor(hexString: "#0099cc")
                btnVerify.layer.cornerRadius = cornerRadius
                btnVerify.setTitle("VerifyAccount".localized().uppercased(), for: UIControlState.normal)
                btnVerify.titleLabel?.font = UIFont(name: "Lato-Regular", size: 15)
                btnVerify.titleLabel?.textColor = UIColor.white
                btnVerify.addTarget(self, action: #selector(GuestSignInViewController.verifyAccount), for: .touchUpInside)
                btnVerify.shadowButton()
                view.addSubview(btnVerify)
                btnVerify.snp.makeConstraints { (make) in
                    make.centerX.equalTo(localSignInView)
                    make.left.equalTo(localSignInView.snp.left).offset(mediumMargin.fixWidth())
                    make.height.equalTo(tableViewCellHeight.fixHeight())
                    make.bottom.equalTo(view.snp.bottom).offset(0 - tablePaddingCell.fixWidth())
                }
            }
        }
        
        doneButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        doneButton.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        doneButton.addTarget(self, action: #selector(GuestSignInViewController.cancel), for: .touchUpInside)
        doneButton.tintColor = .white
        doneButton.backgroundColor = .clear
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints { (make) in
            make.left.equalTo(view)
            make.top.equalTo(view).offset(mediumMargin.fixHeight())
            make.width.equalTo(extraMargin.fixHeight())
            make.height.equalTo(extraMargin.fixHeight())
        }
        doneButton.isHidden = isHiddenBackButton
        
        
        
        
    }
    
    func cancel() {
        dismiss(animated: false, completion: nil)
    }
    
    // Tuyển dụng
    func recruitment() {
        Authenticator.shareInstance.setPostType(postType: PostType.findPeople)
        let recruitmentVC = RecruitmentViewController()
        recruitmentVC.postType = PostType.findPeople
        let nav = UINavigationController(rootViewController: recruitmentVC)
        
        //        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //        appDelegate.window?.rootViewController = nav
        
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController = nav
        
    }
    
    // Tìm việc
    func jobSearch() {
        Authenticator.shareInstance.setPostType(postType: PostType.findJob)
        let recruitmentVC = RecruitmentViewController()
        recruitmentVC.postType = PostType.findJob
        let nav = UINavigationController(rootViewController: recruitmentVC)
        
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController = nav
    }
    
    
    func verifyAccount() {
        present(accountKitVC, animated: true, completion: nil)
    }
    
    func changeLanguageTouched() {
        let languageVC = LanguageViewController()
        
        let nvc = UINavigationController(rootViewController: languageVC)
        present(nvc, animated: true, completion: nil)
    }
    
    //MARK: - Load/Set Data
    func load() -> Void{
        loadJSONFile()
        
        guard let json = json else {
            showDialog(title: "Load File Error".localized(), message: "JSON file is not existed".localized(), handler: nil)
            return
        }
        
        
        guard json.dictionary?.count != nil else{
            showDialog(title: "Load File Error".localized(), message: "JSON configuration has problem".localized(), handler: nil)
            return
        }
        
        //        buttons = AuthSignInButton.loadButton(with: json, displayStyle: style, isPopup: isPopup)
        //
        //        if style == .hasSocial{
        //            service = Authenticator.shareInstance.getAuthService()
        //        }
        
        setDataFromJSONToUI()
        
        return
    }
    
    func loadJSONFile(){
        guard let path = Bundle.main.path(forResource: "config", ofType: "json") else {
            return
        }
        
        guard let data = NSData(contentsOfFile: path) else {
            return
        }
        
        json = try! JSON(data: data as Data)
    }
    
    func setDataFromJSONToUI(){
        guard let json = json else{
            return
        }
        
        if json.error != nil{
            return
        }
        
        //        backgroundView.image = UIImage(named: json["background"].stringValue)
        let backgroundColorString = json["backgroundColor"].string
        if let hexstring = backgroundColorString {
            let backgroundColor = UIColor(hexString: hexstring)
            backgroundView.backgroundColor = backgroundColor
        }
        appImageView.image = UIImage(named: json["appimage"].stringValue)
        appImageView.contentMode = .scaleAspectFit
    }
    
    //MARK: - Inner Class
    class AuthLocalSignInCellContent: NSObject {
        var key: String?
        var placeHolder: String?
        var security: Bool?
        var type: String?
        var retype: String?
        var textField: UITextField?
        
        init?(with json:JSON){
            guard json.error == nil else{
                return nil
            }
            
            key = json["key"].string
            placeHolder = json["placeholder"].string
            security = json["security"].bool
            type = json["type"].string
            retype = json["retype"].string
        }
    }
    
    
    class AuthSignInButton
    {
        //MARK: - Properties
        var icon: String?
        var title: String?
        var titleColor: UIColor?
        var backgroundColor: UIColor?
        var type: LoginType
        
        static func loadButton(with json: JSON, displayStyle: SignInStyle, isPopup: Bool) -> [AuthSignInButton] {
            var buttons = [AuthSignInButton]()
            
            
            for item in json["buttons"].arrayValue {
                guard let loginType = LoginType(rawValue: item["loginType"].stringValue) else{
                    continue
                }
                
                if (displayStyle == .hasSocial && loginType == .local) || (isPopup && loginType == .guest){
                    continue
                }
                
                let button = AuthSignInButton(json: item)
                if button != nil {
                    buttons.append(button!)
                }
            }
            
            return buttons
        }
        
        init?(json: JSON) {
            guard json.error == nil else {
                return nil
            }
            
            guard let loginType = LoginType(rawValue: json["loginType"].stringValue) else {
                return nil
            }
            
            type = loginType
            
            icon = json["icon"].string
            title = json["title"].string
            
            let titleColorString = json["titleColor"].string
            if let hexstring = titleColorString {
                titleColor = hexStringToUIColor(hex: hexstring)
            }
            
            let backgroundColorString = json["backgroundColor"].string
            if let hexstring = backgroundColorString {
                backgroundColor = hexStringToUIColor(hex: hexstring)
            }
        }
        
        func hexStringToUIColor(hex: String) -> UIColor {
            var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            
            if (cString.hasPrefix("#")) {
                cString.remove(at: cString.startIndex)
            }
            
            if ((cString.characters.count) != 8) {
                return UIColor.gray
            }
            
            var rgbValue:UInt64 = 0
            Scanner(string: cString).scanHexInt64(&rgbValue)
            
            return UIColor(
                red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                blue: CGFloat((rgbValue & 0xFF00) >> 8) / 255.0,
                alpha:CGFloat(rgbValue & 0xFF)/255.0
            )
        }
    }
}


////////////////////////////////////////////////////////////////////////////

//MARK: AccountKit Delegate
////////////////////////////////////////////////////////////////////////////

extension GuestSignInViewController : AKFViewControllerDelegate {
    
    
    func viewControllerDidCancel(_ viewController: UIViewController!) {
        
    }
    
    func viewController(_ viewController: UIViewController!, didFailWithError error: Error!) {
        self.showDialog(title: "Hune", message: "VerifyFailure".localized() + "\n" + error.localizedDescription, handler: { (action) in
        })
    }
    
    func viewController(_ viewController: UIViewController!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!) {
        ServiceManager.userService.verify(akToken: accessToken.tokenString) { (result) in
            switch (result) {
            case .success:
                self.btnVerify.isHidden = true
                self.showDialog(title: "Hune", message: "VerifySuccess".localized(), handler: { (action) in
                })
                break
            case .failure(let error):
                self.showDialog(title: "Hune", message: "VerifyFailure".localized() + "\n" + error.errorMessage, handler: { (action) in
                })
                break
            }
        }
    }
    
    func viewController(_ viewController: UIViewController!, didCompleteLoginWithAuthorizationCode code: String!, state: String!) {
        //        if let token = accountKit.currentAccessToken?.tokenString {
        ServiceManager.userService.verify(akToken: code) { (result) in
            switch (result) {
            case .success:
                self.btnVerify.isHidden = true
                self.showDialog(title: "Hune", message: "VerifySuccess".localized(), handler: { (action) in
                })
                break
            case .failure(let error):
                self.showDialog(title: "Hune", message: "VerifyFailure".localized() + "\n" + error.errorMessage, handler: { (action) in
                })
                break
            }
        }
        //        }
    }
}

////////////////////////////////////////////////////////////////////////////

