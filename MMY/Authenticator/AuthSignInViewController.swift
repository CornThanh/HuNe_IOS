//
//  LoginViewController.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/6/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import NVActivityIndicatorView
import SwiftyJSON
import Localize_Swift
import Alamofire
import AccountKit
import DropDown

class AuthSignInViewController: UIViewController {
    //MARK: - Static Constant Properties
    static let timeout: Double = 30
    
    //MARK: - Constant Dimension Properties
    let tableViewWidth: CGFloat = 300
    let tableViewCellHeight: CGFloat = 44
    let tablePaddingCell: CGFloat = 20
    let socialTablePaddingCell: CGFloat = 5
    let cornerRadius: CGFloat = CGFloat(20).fixHeight()
    let logoViewWidth: CGFloat = 110
    let logoViewHeight: CGFloat = 160

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
    var signInTableView = UITableView()
    var socialTableView = UITableView()
    var loginButton = UIButton(), signUpButton = UIButton(), forgetPassButton = UIButton(), doneButton = UIButton()
    var localSignInView = UIView(), orView = UIView(), footerGroupView = UIView(), logoView = UIView()
    var appImageView = UIImageView(), backgroundView = UIImageView()
    var appLabel = UILabel()
    var titleLB = UILabel()
    var activityIndicator: NVActivityIndicatorView?
    var btnLanguage = UIButton()
    var btnSex = UIButton()
    var imgBtSex = UIImageView()
    let typeDropDown = DropDown()
    var typeSex = 0
    
    //MARK: - color
    var inputColor: UIColor?
    var inputPlaceHolderColor: UIColor?
    
    //MARK: - Local Properties
    var json: JSON?
    var isSignUp = false, isForgetPass = false, isLoaded = false, isPopup = false
    var pushUpViewSize: CGFloat = 0
    var style: SignInStyle
	let accountKit: AKFAccountKit = AKFAccountKit(responseType: AKFResponseType.authorizationCode)
	var accountKitVC: UIViewController!
	var authenCode: String?
    
    //MARK: - Init
    init(style: SignInStyle){
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		if (!isForgetPass) {
			setupAlpha(0)
		}
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.isLoaded{
            self.initializeView()
            self.isLoaded = true
        }
		
		if (!isForgetPass && self.load()) {
			self.displayUI(style: self.style)
		}		
    }
    
    override func updateViewConstraints() {
        setupAlpha(0)
        UIView.animate(withDuration: 0.2) {
            self.setupAlpha(1)
        }
        
        if isLoaded && style != .onlySocial{
            let tableHeight = CGFloat(cellContents.count) * (tableViewCellHeight + tablePaddingCell)
            var localSignInViewHeight = tableHeight + tableViewCellHeight
            if style == .hasSocial && isSignUp == false && isForgetPass == false{
                
                view.insertSubview(logoView, belowSubview: activityIndicator!)
                logoView.snp.makeConstraints { (make) in
                    make.centerX.equalTo(view)
                    make.top.equalTo(view).offset(CGFloat(45).fixHeight())
                    make.width.equalTo(logoViewWidth.fixWidth())
                    make.height.equalTo(logoViewHeight.fixHeight())
                }
                
                localSignInView.snp.makeConstraints({ (make) in
                    make.top.equalTo(logoView.snp.bottom)
                })
                
                signInTableView.snp.remakeConstraints({ (make) in
                    make.centerX.equalTo(localSignInView)
                    make.left.equalTo(localSignInView).offset(mediumMargin.fixWidth())
                    make.right.equalTo(localSignInView).offset(-mediumMargin.fixWidth())
                    make.top.equalTo(btnLanguage.snp.bottom).offset(17)
                    make.height.equalTo(tableHeight.fixHeight())
                })
            } else  {
                
                view.insertSubview(titleLB, belowSubview: activityIndicator!)
                titleLB.snp.makeConstraints { (make) in
                    make.top.equalTo(logoView.snp.bottom).offset(CGFloat(5).fixHeight())
                    make.centerX.equalToSuperview()
                    make.height.equalTo(CGFloat(30).fixHeight())
                    make.width.equalTo(UIScreen.main.bounds.size.width - 40)
                }

                localSignInViewHeight += logoViewHeight
                
                signInTableView.snp.remakeConstraints({ (make) in
                    make.centerX.equalTo(localSignInView)
                    make.left.equalTo(localSignInView).offset(mediumMargin.fixWidth())
                    make.right.equalTo(localSignInView).offset(-mediumMargin.fixWidth())
                    make.top.equalTo(titleLB.snp.bottom).offset(CGFloat(25).fixHeight())
                    make.height.equalTo(tableHeight.fixHeight())
                })
            }
            
            localSignInView.snp.updateConstraints { (make) in
                make.height.equalTo(localSignInViewHeight.fixHeight())
            }
        }
        
        super.updateViewConstraints()
    }
    
    func setBottomConstraintFor(button: UIButton){
        view.addSubview(button)
        button.snp.remakeConstraints { (make) in
            make.centerX.equalTo(localSignInView)
            make.top.equalTo(btnSex.snp.bottom).offset(10.0)
            make.left.equalTo(localSignInView.snp.left).offset(mediumMargin.fixWidth())
            make.right.equalTo(localSignInView.snp.right).offset(-mediumMargin.fixWidth())
            make.height.equalTo(tableViewCellHeight.fixHeight())
        }
    }
    
    func setContrainsDoneButton (with view:UIView){
        view.addSubview(doneButton)
        doneButton.snp.remakeConstraints { (make) in
            make.left.equalTo(view)
            make.top.equalTo(view).offset(mediumMargin.fixHeight())
            make.width.equalTo(extraMargin.fixHeight())
            make.height.equalTo(extraMargin.fixHeight())
        }
    }
    
    func setupAlpha(_ alpha: CGFloat){
        logoView.alpha = alpha
        socialTableView.alpha = alpha
        localSignInView.alpha = alpha
        orView.alpha = alpha
        footerGroupView.alpha = alpha
    }
    
    func initializeView(){
        
        // Get color from json
        let stringLogin = "SignIn".localized()
        backgroundView.isUserInteractionEnabled = true
        self.hideKeyboardWhenTappedAround(target: backgroundView)
        
        view.insertSubview(localSignInView, belowSubview: activityIndicator!)
        localSignInView.backgroundColor = .clear
        localSignInView.isUserInteractionEnabled = true
        self.hideKeyboardWhenTappedAround(target: localSignInView)
        localSignInView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(extraMargin.fixWidth())
            make.right.equalTo(view).offset(-extraMargin.fixWidth())
            make.height.equalTo(0)
        }
        
        localSignInView.addSubview(signInTableView)
        setup(signInTableView, rowHeight: tableViewCellHeight)
        signInTableView.register(SignInCell.self, forCellReuseIdentifier: SignInCell.description())
        signInTableView.rowHeight = tableViewCellHeight.fixHeight()
        signInTableView.snp.makeConstraints { (make) in
            make.centerX.equalTo(localSignInView)
            make.top.equalTo(localSignInView.snp.top).offset(hightMargin.fixHeight())
            make.left.equalTo(localSignInView).offset(mediumMargin.fixWidth())
            make.right.equalTo(localSignInView).offset(-mediumMargin.fixWidth())
            make.height.equalTo(0)
        }
        
        setup(socialTableView, rowHeight: socialRowHeight)
        socialTableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.description())
        socialTableView.register(UINib(nibName: "FBLoginTableViewCell", bundle: nil), forCellReuseIdentifier: "FBLoginTableViewCell")
        
        loginButton.backgroundColor = UIColor(hexString: "#0099cc")
        loginButton.layer.cornerRadius = cornerRadius
        loginButton.setTitle(stringLogin, for: UIControlState.normal)
        loginButton.titleLabel?.font = UIFont(name: "Lato-Regular", size: 18)
        loginButton.titleLabel?.textColor = UIColor.white
        loginButton.addTarget(self, action: #selector(AuthSignInViewController.login), for: .touchUpInside)
        view.addSubview(loginButton)
        //setBottomConstraintFor(button: loginButton)
        loginButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(localSignInView)
            make.top.equalTo( self.view.snp.top).offset(view.frame.size.height/1.8)
            make.left.equalTo(localSignInView.snp.left).offset(mediumMargin.fixWidth())
            make.right.equalTo(localSignInView.snp.right).offset(-mediumMargin.fixWidth())
            make.height.equalTo(tableViewCellHeight.fixHeight())
        }  
        
        footerGroupView.addSubview(forgetPassButton)
        forgetPassButton.addTarget(self, action: #selector(AuthSignInViewController.checkForgetPass), for: .touchUpInside)
        
        view.insertSubview(footerGroupView, belowSubview: activityIndicator!)
        footerGroupView.backgroundColor = .clear
        footerGroupView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.width.equalTo(100)
            //make.top.equalTo(localSignInView.snp.bottom).offset(CGFloat(10).fixHeight())
            make.top.equalTo(localSignInView.snp.bottom).offset(10.0)
            make.height.equalTo(CGFloat(20).fixHeight())
        }

        signUpButton.backgroundColor = UIColor(hexString: "#0099cc")
        signUpButton.layer.cornerRadius = cornerRadius
        signUpButton.setTitle("Sign Up".localized(), for: UIControlState.normal)
        signUpButton.titleLabel?.font = UIFont(name: "Lato-Regular", size: 18)
        signUpButton.titleLabel?.textColor = UIColor.white
        signUpButton.addTarget(self, action: #selector(AuthSignInViewController.checkSignUp), for: .touchUpInside)
        view.addSubview(signUpButton)
        signUpButton.snp.makeConstraints { (make) in
//            make.top.equalTo(footerGroupView.snp.bottom).offset(CGFloat(15).fixHeight())
//            make.left.equalTo(localSignInView.snp.left).offset(mediumMargin.fixWidth())
//            make.right.equalTo(localSignInView.snp.right).offset(-mediumMargin.fixWidth())
//            make.height.equalTo(tableViewCellHeight.fixHeight())
            
            make.top.equalTo(forgetPassButton.snp.bottom).offset(8.0)
            make.left.equalTo(footerGroupView.snp.left).offset(mediumMargin.fixWidth())
            make.right.equalTo(footerGroupView.snp.right).offset(-mediumMargin.fixWidth())
            make.height.equalTo(tableViewCellHeight.fixHeight())
        }
        
        
        view.addSubview(orView)
        orView.backgroundColor = .white
        orView.snp.makeConstraints { (make) in
            make.top.equalTo(signUpButton.snp.bottom).offset(CGFloat(15).fixHeight())
            make.left.equalTo(localSignInView).offset(mediumMargin.fixHeight())
            make.right.equalTo(localSignInView).offset(-mediumMargin.fixHeight())
            make.height.equalTo(1)
        }
        orView.isHidden = true
        
        doneButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        doneButton.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        doneButton.addTarget(self, action: #selector(AuthSignInViewController.cancel), for: .touchUpInside)
        doneButton.tintColor = .white
        doneButton.backgroundColor = .clear
        
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
            make.top.equalTo(appImageView.snp.bottom)
            make.height.equalTo(tableViewCellHeight)
            make.centerX.equalTo(logoView)
            make.width.equalTo(appLabel.intrinsicContentSize)
        }
        logoView.backgroundColor = .clear
        view.insertSubview(logoView, belowSubview: activityIndicator!)
        
        if ( UIDevice.current.model.range(of: "iPad") != nil){
            appLabel.isHidden = true
        } else {

        }
        
        // Language
        btnLanguage.backgroundColor = UIColor(hexString: "#0099cc")
        btnLanguage.layer.cornerRadius = cornerRadius
        btnLanguage.titleLabel?.font = UIFont(name: "Lato-Regular", size: 15)
        btnLanguage.titleLabel?.textColor = UIColor.white
        btnLanguage.addTarget(self, action: #selector(changeLanguageTouched), for: .touchUpInside)
        btnLanguage.shadowButton()
        view.addSubview(btnLanguage)
        btnLanguage.snp.makeConstraints { (make) in
            make.right.equalTo(localSignInView.snp.right).offset(-mediumMargin.fixWidth())
            make.left.equalTo(localSignInView.snp.left).offset(mediumMargin.fixWidth())
            make.height.equalTo(tableViewCellHeight.fixHeight())
            
            if ( UIDevice.current.model.range(of: "iPad") != nil){
                appLabel.isHidden = true
                make.top.equalTo(logoView.snp.bottom).offset(-10.0)
            } else {
                make.top.equalTo(appLabel.snp.bottom).offset(5)
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
        
        btnSex.backgroundColor = UIColor.white
        btnSex.titleLabel?.textColor = UIColor.black
        btnSex.setTitleColor(UIColor.black, for: .normal)
        btnSex.setTitle("Female".localized(), for: UIControlState.normal)
        btnSex.layer.cornerRadius = cornerRadius
        btnSex.titleLabel?.font = UIFont(name: "Lato-Regular", size: 18)
        btnSex.addTarget(self, action: #selector(actionSex), for: .touchUpInside)
        view.addSubview(btnSex)
        btnSex.snp.makeConstraints { (make) in
            make.top.equalTo(signInTableView.snp.bottom).offset(0.0)
            make.left.equalTo(localSignInView.snp.left).offset(mediumMargin.fixWidth())
            make.right.equalTo(localSignInView.snp.right).offset(-mediumMargin.fixWidth())
            make.height.equalTo(tableViewCellHeight.fixHeight())
        }
        
        imgBtSex.image = UIImage(named: "icon_down")
        btnSex.addSubview(imgBtSex)
        imgBtSex.snp.makeConstraints { (make) in
            make.centerY.equalTo(btnSex.snp.centerY)
            make.right.equalTo(btnSex.snp.right).offset(-5.0)
            make.height.equalTo(10.0)
            make.width.equalTo(10.0)
        }
        
        self.setupTypeDropDown()
        btnSex.isHidden = true
        
        
    }
    
    func changeLanguageTouched() {
        let languageVC = LanguageViewController()
        
        let nvc = UINavigationController(rootViewController: languageVC)
        present(nvc, animated: true, completion: nil)
    }
    
    func displayUI(style: SignInStyle){
        switch style {
        case .hasSocial:
            displayUIStypeHasSocial()
            
        case .noSocial:
            displayUIStypeNoSocial()
            
        case .onlySocial:
            displayUIStypeOnlySocial()
        }
    }
    
    func displayUIStypeHasSocial(){
        displaySignInView()
        
        view.addSubview(socialTableView);
        socialTableView.snp.remakeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(orView.snp.bottom).offset(CGFloat(15).fixHeight())
            make.left.equalTo(view).offset(mediumMargin.fixWidth())
            make.right.equalTo(view).offset(-mediumMargin.fixWidth())
            make.height.equalTo(CGFloat(buttons.count) * (socialRowHeight + socialTablePaddingCell).fixHeight())
        }
        
        socialTableView.reloadData()
    }
    
    func displayUIStypeNoSocial(){
        socialTableView.removeFromSuperview()
        displaySignInView()
    }
    
    func displayUIStypeOnlySocial(){
        localSignInView.removeFromSuperview()
        setContrainsDoneButton(with: view)
        
        view.insertSubview(socialTableView, belowSubview: activityIndicator!)
        socialTableView.snp.remakeConstraints({ (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view).offset(-CGFloat(80).fixHeight())
            make.left.equalTo(view).offset(mediumMargin.fixWidth())
            make.right.equalTo(view).offset(-mediumMargin.fixWidth())
            make.height.equalTo(CGFloat(buttons.count) * (socialRowHeight + tablePaddingCell).fixHeight())
        })
        
        doneButton.isHidden = !isPopup
        socialTableView.reloadData()
        view.setNeedsUpdateConstraints()
    }
    
    private func displaySignInView(){
        setContrainsDoneButton(with: view)
        
        loadCellContentInJSONFile(type: "signin")
        signInTableView.reloadData()
        
        setHidden(false, for: loginButton, footerGroupView, socialTableView)
        
        doneButton.isHidden = style == .hasSocial && !isPopup ? true : false
        orView.isHidden = style != .hasSocial ? true: false
        
        signUpButton.isHidden = false
        signUpButton.backgroundColor = UIColor(hexString: "#0099cc")
        signUpButton.layer.cornerRadius = cornerRadius
        signUpButton.setTitle("Sign Up".localized(), for: UIControlState.normal)
        signUpButton.titleLabel?.font = UIFont(name: "Lato-Regular", size: 18)
        signUpButton.titleLabel?.textColor = UIColor.white
        view.addSubview(signUpButton)
        signUpButton.snp.makeConstraints { (make) in
            make.top.equalTo(forgetPassButton.snp.bottom).offset(CGFloat(20).fixHeight())
            make.left.equalTo(localSignInView.snp.left).offset(mediumMargin.fixWidth())
            make.right.equalTo(localSignInView.snp.right).offset(-mediumMargin.fixWidth())
            make.height.equalTo(tableViewCellHeight.fixHeight())
        }
        
        // test
        forgetPassButton.isHidden = false
        forgetPassButton.backgroundColor = UIColor.clear
        forgetPassButton.setTitle("Forget password?".localized(), for: .normal)
        forgetPassButton.titleLabel?.font = UIFont(name: "Lato-Italic", size: 13)
        forgetPassButton.layer.borderWidth = 0
        view.addSubview(forgetPassButton)
        forgetPassButton.snp.remakeConstraints { (make) in
            make.top.equalTo(loginButton.snp.bottom).offset(8.0)
            make.center.equalTo(footerGroupView)
            make.width.equalTo(footerGroupView)
            make.height.equalTo(footerGroupView)
        }
        
        titleLB.isHidden = true
        
        view.setNeedsUpdateConstraints()
    }
    // cuong
    private func displaySignUpView(){
        isSignUp = true
        loadCellContentInJSONFile(type: "signup")
        signInTableView.reloadData()
        
        setHidden(true, for: loginButton, forgetPassButton, socialTableView, orView)
        doneButton.isHidden = false
        btnLanguage.isHidden = true
        
        titleLB.isHidden = false
        titleLB.textAlignment = .center
        titleLB.text = "Registration information".localized()
        titleLB.font = UIFont(name: "Lato-Regular", size: 18)
        titleLB.textColor = UIColor.white
        
        btnSex.isHidden = false
        
        signUpButton.backgroundColor = UIColor(hexString: "#0099cc")
        signUpButton.layer.cornerRadius = cornerRadius
        signUpButton.setTitle("Sign Up".localized(), for: UIControlState.normal)
        signUpButton.titleLabel?.font = UIFont(name: "Lato-Regular", size: 18)
        signUpButton.titleLabel?.textColor = UIColor.white
        setBottomConstraintFor(button: signUpButton)
        
        view.setNeedsUpdateConstraints()
    }
    
    func setupTypeDropDown() {
        typeDropDown.anchorView = btnSex
        typeDropDown.bottomOffset = CGPoint(x: 0, y: tableViewCellHeight.fixHeight())
        let typeDataSource = ["Female".localized(), "Male".localized()]
        typeDropDown.dataSource = typeDataSource
        typeDropDown.selectionAction = { [unowned self] (index, item) in
            self.typeSex = index
            self.btnSex.setTitle(typeDataSource[index].localized(), for: .normal)
        }
    }

    
    func displayForgetPassView(){
        isForgetPass = true
        loadCellContentInJSONFile(type: "forgetpass")
        signInTableView.reloadData()
        setHidden(true, for: loginButton, signUpButton, socialTableView, orView)
        doneButton.isHidden = false
        
        titleLB.isHidden = false
        titleLB.textAlignment = .center
        titleLB.text = "ResetPassword".localized()
        titleLB.font = UIFont(name: "Lato-Regular", size: 18)
        titleLB.textColor = UIColor.white
        
        
        forgetPassButton.backgroundColor = UIColor(hexString: "#0099cc")
        forgetPassButton.layer.cornerRadius = cornerRadius
        forgetPassButton.titleLabel?.font = UIFont(name: "Lato-Regular", size: 18)
        forgetPassButton.titleLabel?.textColor = UIColor.white
        forgetPassButton.setTitleColor(.white, for: .normal)
        forgetPassButton.setTitle("Submit".localized(), for: .normal)
        
        setBottomConstraintFor(button: forgetPassButton)
        
        view.setNeedsUpdateConstraints()
    }
    
    //MARK: - Load/Set Data
    func load() -> Bool{
        loadJSONFile()
        
        guard let json = json else {
            showDialog(title: "Load File Error".localized(), message: "JSON file is not existed".localized(), handler: nil)
            return false
        }
        
        
        guard json.dictionary?.count != nil else{
            showDialog(title: "Load File Error".localized(), message: "JSON configuration has problem".localized(), handler: nil)
            return false
        }
        
        buttons = AuthSignInButton.loadButton(with: json, displayStyle: style, isPopup: isPopup)
        
        if style == .hasSocial{
            service = Authenticator.shareInstance.getAuthService()
        }
        
        setDataFromJSONToUI()
        
        return true
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
    
    func loadCellContentInJSONFile(type: String){
        guard let json = json else{
            return
        }
        
        cellContents.removeAll()
        
        for item in json[type].arrayValue {
            if let cellContent = AuthLocalSignInCellContent(with: item){
                cellContents.append(cellContent)
            }
        }
    }
    
    //MARK: - Authentication Feature
    func login(){
        doAuthAction { (params) in
            
            self.service?.signIn(.local, params: params, completion: { (result) in
                switch result{
                case .success(let session):
                    self.loginSuccessAction(style: self.style, with: session)
                case .failure(let error):
                    switch error{
                    case .failed:
                        let firstKey = Array(params.keys)[0]
                        let secondKey = Array(params.keys)[1]
                        self.showDialog(title: "Login Failed".localized(), message: firstKey.capitalized.localized() + " or ".localized() + secondKey.capitalized.localized() + " is incorrect".localized(), handler: nil)
                    case .noInternet:
                        self.showDialog(title: "No Internet Connection".localized(), message: "Your internet connection has problem".localized(), buttonTitle: "Retry".localized(), handler: { (alert) in
                            self.login()
                        })
                    default: break
                    }
                }
                
                self.stopActivityIndicator()
            })
            
            self.dispatchAfter {self.login()}
        }
    }
    
    func loginSuccessAction(style: SignInStyle, with session: AuthSession){
        activityIndicator?.stopAnimating()
        
        if style == .hasSocial {
            Authenticator.shareInstance.loginType = .local
            Authenticator.shareInstance.set(authSession: session)
        }
        
        self.delegate?.authSignInViewController(self, didFinishSignInWith: .success(session))
        
        if isPopup{
            self.dismiss(animated: true, completion: nil)
        }
        
        // Register FCM token
        if let token = InstanceID.instanceID().token(){
            ServiceManager.userService.updateFcm_token(fcm_token: token, completion: { (resultCode) in
                
            })
        }
    }
    
    func checkSignUp(){
        isSignUp ? signUp() : displaySignUpView()
    }
    
    func signUp(){
        doAuthAction { (params) in
            var newParams = params
            newParams["sex"] = self.typeSex + 1
            self.service?.signUp(params: newParams, completion: { (result) in
                switch result{
                case .success(_):
                    self.showDialog(title: "Sign Up Successfully".localized(), message:
                        "Now you can sign in with the account".localized(), handler: { (alertAction) in
                            self.isSignUp = false
                            self.displaySignInView()
                    })
                    
                case .failure(let error):
                    switch error{
                    case .failed:
                        self.showDialog(title: "Sign Up Failed".localized(), message:
                            "Can't create new account with this infomation".localized(), handler: nil)
                    case .noInternet:
                        self.showDialog(title: "No Internet Connection".localized(), message: "Your internet connection has problem".localized(), buttonTitle: "Retry".localized(), handler: { (alert) in
                            self.signUp()
                        })
                    default: break
                    }
                }
                
                self.stopActivityIndicator()
            })
            
            self.dispatchAfter {self.signUp()}
        }
    }
    
    func checkForgetPass(){
        if !isForgetPass{
            displayForgetPassView()
			accountKitVC = accountKit.viewControllerForPhoneLogin()
			if let vc = accountKitVC as? AKFViewController {
				vc.defaultCountryCode = "VN"
				vc.delegate = self
			}
			present(accountKitVC, animated: true, completion: nil)
        }else{
            requestPass()
        }
    }
    
    func requestPass() {
		guard let authenCode = authenCode else {
			return
		}
        doAuthAction { (params) in
			ServiceManager.userService.resetPassword(akToken: authenCode, params: params, completion: { (result) in
				switch (result) {
				case .success:
					self.showDialog(title: "Hune", message: "ResetPasswordSuccess".localized(), handler: { (action) in
					})
					break
				case .failure(let error):
					self.showDialog(title: "Hune", message: "ResetPasswordFailure".localized() + "\n" + error.errorMessage, handler: { (action) in
					})
					break
				}
				self.cancel()
				self.stopActivityIndicator()
			})
        }
    }
    
    func actionSex() {
        typeDropDown.show()
    }
    
    func cancel(){
        self.updateBtLanguageAndBtSignup()
        if isSignUp || isForgetPass{
            isSignUp = false
            isForgetPass = false
            displaySignInView()
        }else{
            UIView.animate(withDuration: 0.2, animations: {
                self.setupAlpha(0)
            }, completion: { (result) in
                self.delegate?.authSignInViewController(self, didFinishSignInWith: AuthResult.failure(AuthError.cancelled))
                self.dismiss(animated: false, completion: nil)
            })
            
        }
    }
    
    func updateBtLanguageAndBtSignup() {
        
        signUpButton.snp.remakeConstraints { (make) in
            make.top.equalTo(localSignInView.snp.bottom).offset(40.0)
           
        }
        
        signUpButton.layoutIfNeeded()
        btnSex.isHidden = true
        btnLanguage.isHidden = false
    }
    
    //MARK: - Supporting Feature
    func doAuthAction(successHandler: @escaping(_ params: [String: Any]) -> Void){
        let validateResult = validateContent()
        guard let code = validateResult["code"] as? Int else{
            return
        }
        
        guard let message = validateResult["message"] as? String else{
            return
        }
        
        if code == 0{
            view.isUserInteractionEnabled = false
            activityIndicator?.startAnimating()
            let params = getParams()
            successHandler(params)
        }else if code == -1{
            showDialog(title: "Empty Field".localized(), message: message, handler: nil)
        }else if code == -2{
            showDialog(title: "Re-type Error".localized(), message: message, handler: nil)
        }
    }
    
    func validateContent() -> [String: Any]{
        var result = [String: Any]()
        
        for cellContent in cellContents{
            if cellContent.textField?.text == "" {
                result["code"] = -1
                result["message"] = (cellContent.placeHolder ?? "").localized() + " is empty".localized()
                return result
            }
            
            if !checkRetype(cellContent){
                result["code"] = -2
                result["message"] = (cellContent.placeHolder ?? "").localized() + " is incorrect".localized()
                return result
            }
        }
        
        result["code"] = 0
        result["message"] = ""
        
        return result
    }
    
    func checkRetype(_ targetCellContent: AuthLocalSignInCellContent) -> Bool{
        guard targetCellContent.retype != nil else {
            return true
        }
        
        for cellContent in cellContents{
            if cellContent.key == targetCellContent.retype &&
                cellContent.textField?.text == targetCellContent.textField?.text{
                return true
            }
        }
        return false
    }
    
    func dispatchAfter(selector: @escaping () -> Void){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + AuthSignInViewController.timeout, execute: {
            if (self.activityIndicator?.isAnimating)!{
                self.showDialog(title: "Request Timeout".localized(), message: "Server didn't response data".localized(), buttonTitle: "Retry".localized(), handler: { (aleart) in
                    selector()
                })
                self.view.isUserInteractionEnabled = true
                self.stopActivityIndicator()
            }
        })
    }
    
    func getParams() -> [String: String]{
        var params = [String: String]()
        for cellContent in cellContents{
            if let key = cellContent.key, let textField = cellContent.textField{
                params[key] = textField.text
            }
        }
        
        return params
    }
    
    func stopActivityIndicator(){
        view.isUserInteractionEnabled = true
        activityIndicator?.stopAnimating()
    }
    
    func setHidden(_ hidden: Bool, for views: UIView...){
        for view in views{
            view.isHidden = hidden
        }
    }
    
    func setup(_ tableView: UITableView, rowHeight: CGFloat){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.rowHeight = rowHeight.fixHeight()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    // MARK: - Custom Cell
    class ButtonCell : UITableViewCell {
        public var title: UILabel?
        public var borderView: UIView?
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = UITableViewCellSelectionStyle.none
            backgroundColor = UIColor.clear
            
            title = UILabel()
            title?.numberOfLines = 0
            title?.font = UIFont(name: "Lato-Italic", size: 13)
            contentView.safeAddSubview(title)
            title?.snp.makeConstraints({ (make) in
                make.left.equalTo(contentView)
                make.centerY.equalTo(contentView)
                make.right.equalTo(contentView)
            })
            
            
            if let name = title {
                borderView = UIView(frame: CGRect.zero)
                borderView?.layer.cornerRadius = CGFloat(23).fixHeight()
                borderView?.layer.borderWidth = 1
                borderView?.layer.borderColor = UIColor(red: 124/255.0, green: 174/255.0, blue: 255/255.0, alpha: 1).cgColor
                contentView.safeAddSubview(borderView)
                borderView?.snp.makeConstraints({ (make) in
                    make.center.equalTo(name)
                    make.height.equalTo(contentView)
                    make.width.equalTo(140)
                })
            }
        }
        
        override func updateConstraints() {
            super.updateConstraints()
            if let title = title {
                borderView?.snp.updateConstraints({ (make) in
                    make.width.equalTo(title.intrinsicContentSize.width + 70)
                })
            }
        }
        
        func populateData(button: AuthSignInButton) {
            title?.text = button.title?.localized()
            title?.textColor = button.titleColor
            title?.textAlignment = .center
            contentView.backgroundColor = button.backgroundColor
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class SignInCell: UITableViewCell{
        let textField = UITextField()
        var cellContent : AuthLocalSignInCellContent?
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?){
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = UITableViewCellSelectionStyle.none
            layer.cornerRadius = CGFloat(20).fixHeight()
            backgroundColor = UIColor.white
            contentView.addSubview(textField)
            textField.snp.makeConstraints { (make) in
                make.left.equalTo(contentView)
                make.top.equalTo(contentView)
                make.right.equalTo(contentView)
                make.bottom.equalTo(contentView)
            }
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: contentView.frame.size.height))
            textField.leftView = paddingView
            textField.leftViewMode = .always
            
            let rightPaddingView = UIView(frame: CGRect(x: contentView.frame.size.width - 10, y: 0, width: 10, height: contentView.frame.size.height))
            textField.rightView = rightPaddingView
            textField.rightViewMode = .always
            
            textField.backgroundColor = .clear
            textField.textAlignment = .center
            textField.textColor = UIColor(hexString: "#666666")
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func load(cellContent: AuthLocalSignInCellContent){
            textField.text = ""
            //            textField.placeholder = cellContent.placeHolder?.localized()
            if let placeHolder = cellContent.placeHolder {
                textField.attributedPlaceholder = NSAttributedString(string: placeHolder.localized(), attributes: [NSForegroundColorAttributeName: UIColor(hexString: "#cccccc")!])
            }
            if let security = cellContent.security{
                textField.isSecureTextEntry = security
            }
            
            if let type = cellContent.type {
                if type == "number"{
                    textField.keyboardType = .numberPad
                }
            }else {
                textField.keyboardType = .default
            }
            
            cellContent.textField = textField
        }
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

//MARK: - TableView DataSource
extension AuthSignInViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == socialTableView{
            return buttons.count
        }else{
            return cellContents.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == socialTableView {
            return socialTablePaddingCell.fixHeight()
        }
        else {
            if section == 0 {
                return 0
            }
            else {
                return tablePaddingCell.fixHeight()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView();
        v.backgroundColor = UIColor.clear
        return v;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == socialTableView {
            if indexPath.section == 0 {
                let cell = socialTableView.dequeueReusableCell(withIdentifier: "FBLoginTableViewCell") as! FBLoginTableViewCell
                cell.loginWithFB = {
                    self.activityIndicator?.startAnimating()
                    Authenticator.shareInstance.login(LoginType.facebook, in: self, completion: { (result) in
                        switch result{
                        case .success(let session):
                            self.loginSuccessAction(style: SignInStyle.onlySocial, with: session)
                        case .failure(let error):
                            log.debug(error.localizedDescription)
                        }
                        
                        self.stopActivityIndicator()
                    })
                }
                cell.selectionStyle = .none
                return cell
            }
            let cell = socialTableView.dequeueReusableCell(withIdentifier: ButtonCell.description(), for: indexPath) as! ButtonCell
            let button = buttons[indexPath.section]
            cell.borderView?.isHidden = indexPath.section != 0
            cell.populateData(button: button)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SignInCell.description(), for: indexPath) as! SignInCell
            let cellContent = cellContents[indexPath.section]
            cell.load(cellContent: cellContent)
            return cell;
        }
    }
}


//MARK: - TableView Delegate
extension AuthSignInViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.socialTableView{
            let button = self.buttons[indexPath.section]
            
            if button.type == .guest {
                let guestLoginViewController = GuestSignInViewController()
                Authenticator.shareInstance.loginType = LoginType.guest
                present(guestLoginViewController, animated: false, completion: nil)
            }
            
            else {
                if button.type != .local{
                    self.activityIndicator?.startAnimating()
                }
                
                Authenticator.shareInstance.login(button.type, in: self, completion: { (result) in
                    switch result{
                    case .success(let session):
                        self.delegate?.authSignInViewController(self, didFinishSignInWith: .success(session))
                        self.presentedViewController?.dismiss(animated: true, completion: nil)
                        if self.isPopup{
                            self.dismiss(animated: false, completion: nil)
                        }
                        
                    case .failure(let error):
                        log.debug(error.localizedDescription)
                    }
                    
                    self.stopActivityIndicator()
                })
            }
        }
    }
}

//MARK: - UIGestureRecognizerDelegate
extension UIViewController: UIGestureRecognizerDelegate{
    func hideKeyboardWhenTappedAround(target: UIView) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.delegate = self
        target.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension CGFloat{
    func fixWidth() -> CGFloat{
        return self * (UIScreen.main.bounds.width / 414)
    }
    
    func fixHeight() -> CGFloat{
        return self * (UIScreen.main.bounds.height / 736)
    }
    
    func pixelToPoints() -> CGFloat {
        let pointsPerInch : CGFloat = 72.0
//        let scale : CGFloat = 1 
        let scale: CGFloat = UIScreen.main.scale
        var pixelPerInch : CGFloat // aka dpi
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            pixelPerInch = 132 * scale
        } else if (UI_USER_INTERFACE_IDIOM() == .phone) {
            pixelPerInch = 163 * scale
        } else {
            pixelPerInch = 160 * scale
        }
        let result: CGFloat = self * pointsPerInch / pixelPerInch
        return result;
    }
}

//MARK: - Protocol
protocol AuthSignInDelegate {
    func authSignInViewController(_ authSignInViewController: AuthSignInViewController, didFinishSignInWith result: AuthResult<AuthSession>)
}

////////////////////////////////////////////////////////////////////////////

//MARK: AccountKit Delegate
////////////////////////////////////////////////////////////////////////////

extension AuthSignInViewController : AKFViewControllerDelegate {
	
	func viewControllerDidCancel(_ viewController: UIViewController!) {
		self.cancel()
	}
	
	func viewController(_ viewController: UIViewController!, didFailWithError error: Error!) {
		self.showDialog(title: "Hune", message: "VerifyFailure".localized() + "\n" + error.localizedDescription, handler: { (action) in
			self.cancel()
		})
	}
	
	func viewController(_ viewController: UIViewController!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!) {
	}
	
	func viewController(_ viewController: UIViewController!, didCompleteLoginWithAuthorizationCode code: String!, state: String!) {
		authenCode = code
	}
}

////////////////////////////////////////////////////////////////////////////
