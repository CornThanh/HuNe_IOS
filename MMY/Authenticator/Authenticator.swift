//
//  authticator.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/14/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import GoogleMaps

class Authenticator: NSObject {
    let authSessionIdKey = "vn.asquare.Authenticator.AuthSessionId"
    let loginTypeKey = "vn.asquare.Authenticator.loginType"
    
    //MARK: - Properties
    private var authService: AuthService?
    private var authProviders = [AuthProvider]()
    private var authSession: AuthSession?
    private var authSignInViewCtl = AuthSignInViewController(style: .hasSocial)
    
    var loginType: LoginType{
        get{
            return LoginType(rawValue: UserDefaults.standard.string(forKey: loginTypeKey) ?? "guest") ?? .guest
        }
        set{
            UserDefaults.standard.set(newValue.rawValue, forKey: loginTypeKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    private var postType: PostType?
    private var categoryList: [CategoryModel]?
    private var location: CLLocation?
    
    static let shareInstance = Authenticator()
    
    //MARK: - Init
    private override init(){}
    
    //MARK: - Get/Set/Add Properties
    func set(authService: AuthService){
        self.authService = authService
    }
    
    func getAuthService() -> AuthService?{
        return authService
    }
    
    func add(authProvider: AuthProvider){
        if !checkExisted(authProvider){
            authProviders.append(authProvider)
        }
    }
    
    func setPostType(postType: PostType) {
        self.postType = postType
    }
    
    func getPostType() -> PostType? {
        return postType
    }
    
    func setCategoryList(categoryList: [CategoryModel]?) {
        self.categoryList = categoryList
    }
    
    func getCategoryList() -> [CategoryModel]? {
        return categoryList
    }
    
    func getCategoryIconURL(id: String) -> String? {
        if let categoryList = self.categoryList {
            for category: CategoryModel in categoryList {
                if category.categoryId == id {
                    return category.icon?.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                }
                else if let subCategoryList = category.children {
                    for subCategory: CategoryModel in subCategoryList {
                        if subCategory.categoryId == id {
                            return subCategory.icon?.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                        }
                    }
                }
            }
        }
        return ""
    }
    
    
    func getCategoryTitle(id: String) -> String {
        if let categoryList = self.categoryList {
            for category: CategoryModel in categoryList {
                if category.categoryId == id {
                    if let title = category.name {
                       return title
                    }
                }
                else if let subCategoryList = category.children {
                    for subCategory: CategoryModel in subCategoryList {
                        if subCategory.categoryId == id {
                            if let title = subCategory.name {
                                return title
                            }
                        }
                    }
                }
            }
        }
        return ""
    }
    
    func getCategoryFromId(id: String) -> CategoryModel? {
        if let categoryList = self.categoryList {
            for category: CategoryModel in categoryList {
                if category.categoryId == id {
                    return category
                }
                else if let subCategoryList = category.children {
                    for subCategory: CategoryModel in subCategoryList {
                        if subCategory.categoryId == id {
                            return subCategory
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func setLocation(location: CLLocation?) {
        self.location = location
    }
    
    func getLocation() -> CLLocation? {
        return location
    }
    
    func set(authSession: AuthSession?){
        self.authSession = authSession
        UserDefaults.standard.set(authSession?.sessionId, forKey: authSessionIdKey)
        UserDefaults.standard.synchronize()
    }
    
    func getAuthSession() -> AuthSession?{
        return authSession
    }
    
    func resetAuthViewController(delegate: AuthSignInDelegate?){
        authSignInViewCtl = AuthSignInViewController(style: .hasSocial)
        authSignInViewCtl.delegate = delegate
    }
    
    func getAuthSignInViewCtl(_ reset: Bool = false) -> AuthSignInViewController{
        authSignInViewCtl.isPopup = reset ? false : authSignInViewCtl.isPopup
        return authSignInViewCtl
    }
    
    func popupAuthSignInViewCtl(in controller: UIViewController, style: SignInStyle = .hasSocial){
        authSignInViewCtl.style = style
        authSignInViewCtl.isPopup = true
        DispatchQueue.main.async {
            controller.present(self.authSignInViewCtl, animated: true, completion: nil)
        }
    }
    
    //MARK: - Application Delegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool{
        var result = false
        for provider in authProviders{
            result = result || provider.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
        return result
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool{
        var result = false
        for provider in authProviders{
            result = result || provider.application(app, open: url, options: options)
        }
        
        return result
    }
    
    //MARK: - Authentication Feature
    func login(_ type: LoginType, in controller: UIViewController = UIViewController(), completion: @escaping (_ result: AuthResult<AuthSession>) -> Void){
        guard let authProvider = getProvider(type) else{
            completion(AuthResult.failure(AuthError.missingProvider))
            return
        }
        
        authProvider.login(in: controller, completion: { (result) in
            switch result {
            case .success(let params):
                guard let params = params else{
                    completion(AuthResult.failure(AuthError.missingParams))
                    return
                }
                
                guard let authService = self.authService else{
                    completion(AuthResult.failure(AuthError.missingService))
                    return
                }
                
                if type != .local {
                    authService.signIn(type, params: params, completion: { (result) in
                        switch result{
                        case .success(let session):
                            self.loginType = type
                            
                            self.set(authSession: session)
                            completion(AuthResult.success(session))
                            
                        case .failure(let error):
                            completion(AuthResult.failure(error))
                        }
                    })
                    
                }else {
                    self.loginType = type
                    self.set(authSession: params["session"] as? AuthSession)
                    completion(AuthResult.success(self.authSession!))
                }
                
            case .failure(let error):
                completion(AuthResult.failure(error))
            }
        })
    }
    
    func login(params: [String: Any], completion: @escaping(_ result : AuthResult<AuthSession>) -> Void){
        guard let authService = authService else{
            completion(AuthResult.failure(AuthError.missingService))
            return
        }
        
        authService.signIn(.local, params: params, completion: { (result) in
            switch result{
            case .success(let session):
                self.set(authSession: session)
            default: break
            }
            
            completion(result)
        })
    }
    
    func signUp(params: [String: Any], completion: @escaping(_ result : AuthResult<Bool>) -> Void){
        guard let authService = authService else{
            completion(AuthResult.failure(AuthError.missingService))
            return
        }
        
        authService.signUp(params: params) { (result) in
            completion(result)
        }
    }
    
    func forgetPass(params: [String: Any], completion: @escaping(_ result: AuthResult<Bool>) -> Void){
        guard let authService = authService else{
            completion(AuthResult.failure(AuthError.missingService))
            return
        }
        
        authService.forgetPass(params: params, completion: { (result) in
            completion(result)
        })
    }
    
    func checkIfAuthticated(completion: @escaping(_ result: AuthResult<AuthSession>) -> Void){
        guard let authService = authService else{
            completion(AuthResult.failure(AuthError.missingService))
            return
        }
        
        if let sessionId = UserDefaults.standard.object(forKey: authSessionIdKey) as? String{
            log.debug("Check SessionId: \(sessionId)")
            authService.validate(sessionId: sessionId, renew: true, completion: { (result) in
                switch result{
                case .success(let session):
                    self.set(authSession: session)
                default: break
                }
                
                completion(result)
            })
            
        }else {
            log.debug("No sessionId to check")
            completion(AuthResult.failure(AuthError.failed))
        }
    }
    
    func logout(completion: @escaping(_ result: AuthResult<Bool>) -> Void) {
        for provider in authProviders{
            provider.logout()
        }
        
        guard let session = authSession else {
            completion(AuthResult.failure(AuthError.missingSession))
            return
        }
        
//        authService?.signOut(sessionId: session.sessionId, completion: { (result) in
//            switch result{
//            case .success(_):
//                self.set(authSession: nil)
//            default: break
//            }
//            
//            completion(result)
//        })

        completion(AuthResult.success(true))
    }
    
    //MARK: - Private Auth Support
    private func checkExisted(_ authProvider: AuthProvider) -> Bool{
        for existedAuth in authProviders {
            if existedAuth.getType() == authProvider.getType(){
                return true
            }
        }
        
        return false
    }
    
    private func getProvider(_ type: LoginType) -> AuthProvider?{
        for authProvider in authProviders{
            if authProvider.getType() == type{
                return authProvider
            }
        }
        
        return nil
    }
}
