//
//  AppDelegate.swift
//  MMY
//
//  Created by Blue R&D on 2/15/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import MMDrawerController
import Firebase
import FirebaseMessaging
import Localize_Swift
import IQKeyboardManagerSwift
import UserNotifications
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.statusBarStyle = .default
        Fabric.with([Crashlytics.self])
        FirebaseApp.configure()
        handleDeepLinkInactive(from: launchOptions)
        setupLanguageAndKeyboard()
        registerRemoteNotification(for: application)
        setAuth()
        Authenticator.shareInstance.getAuthSignInViewCtl().delegate = self
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ControllerFactory.shared.makeController(type: .splash)
        _ = Authenticator.shareInstance.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        handleNoti(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            log.debug("Message ID: \(messageID)")
        }
        log.debug(userInfo)
        handleNoti(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        handleDeepLink(from: url)
        return Authenticator.shareInstance.application(app, open: url, options: options)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Messaging.messaging().shouldEstablishDirectChannel = false
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        connectToFcm()
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.debug("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if DEBUG
            Messaging.messaging().setAPNSToken(deviceToken, type: .sandbox)
            let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
            print(token)
        #else
            Messaging.messaging().setAPNSToken(deviceToken, type: .prod)
        #endif
        
    }

    func setAuth(){
        let service = AuthAPIService()
        Authenticator.shareInstance.set(authService: service)
        Authenticator.shareInstance.add(authProvider: AuthFacebookProvider())
        Authenticator.shareInstance.add(authProvider: AuthLocalProvider(with: service))
        Authenticator.shareInstance.add(authProvider: AuthGuestProvider())
    }
    
    func makeCenterView(_ isFirst: Bool = false) {

        Authenticator.shareInstance.checkIfAuthticated { (result) in
            switch result{
            case .success(_):
                self.transitToHomeViewController()
            case .failure(_):
                self.displayCenterViewCtl(Authenticator.shareInstance.getAuthSignInViewCtl(true))
            }
        }
    }
    
    func transitToHomeViewController() {
        pushToken(isLogin: true)
        let guestLoginViewController = GuestSignInViewController()
        guestLoginViewController.isHiddenBackButton = true
        self.window?.rootViewController = guestLoginViewController
    }
    
    func displayCenterViewCtl(_ controller: UIViewController){
        let rootController = MMDrawerController(center: controller, leftDrawerViewController: nil, rightDrawerViewController: nil)
        rootController?.closeDrawerGestureModeMask = .all
        self.window?.rootViewController = rootController
    }
    
    func setupLanguageAndKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(makeCenterView), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        let currentLanguage = UserDefaults.standard.object(forKey: "currentLanguage") != nil ? UserDefaults.standard.object(forKey: "currentLanguage") as! String : Language.vietnamese.shortTitle()
        Localize.setCurrentLanguage(currentLanguage)
        IQKeyboardManager.shared.enable = true
    }

}

extension AppDelegate: AuthSignInDelegate{
    func authSignInViewController(_ authSignInViewController: AuthSignInViewController, didFinishSignInWith result: AuthResult<AuthSession>) {
        if !Authenticator.shareInstance.getAuthSignInViewCtl().isPopup{
            transitToHomeViewController()
        } else {
            pushToken(isLogin: true)
        }
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        handleNoti(userInfo)
        
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        handleNoti(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]
// [START ios_10_data_message_handling]
extension AppDelegate : MessagingDelegate {

    public func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {

    }
}

//MARK: - Push notification
extension AppDelegate {
    func registerRemoteNotification(for application: UIApplication) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .InstanceIDTokenRefresh,
                                               object: nil)
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    func pushToken(isLogin: Bool){
        // Register FCM token
        if let token = InstanceID.instanceID().token(){
            ServiceManager.userService.updateFcm_token(fcm_token: token, completion: { (resultCode) in

            })
        }
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        connectToFcm()
    }
    
    func connectToFcm() {
        pushToken(isLogin: false)
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
}

//MARK: - Deeplink
extension AppDelegate {
    func handleDeepLinkInactive(from launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject],
            let urlString = notification["custom_url"] as? String,
            let url = URL(string: urlString) {
            handleDeepLink(from: url)
        }
    }
    
    
    func handleNoti(_ userInfo: [AnyHashable: Any]){
        if let messageID = userInfo[gcmMessageIDKey] {
            log.debug("Message ID: \(messageID)")
        }
        log.debug(userInfo)
        
        guard let aps = userInfo["aps"] as? [String: AnyObject],
            let urlString = userInfo["custom_url"] as? String,
            let url = URL(string: urlString) else  {
                return
        }
        DispatchQueue.main.async {
            if UIApplication.shared.applicationState == .active {
                self.showAlertView(from: aps, and: url)
            } else {
                self.handleDeepLink(from: url)
            }
        }
    }
    
    func handleDeepLink(from url:URL) {
        if url.scheme == "vn.asquare.os.mmy" && url.host == "post" {
            let urlParts = url.absoluteString.components(separatedBy: "?")
            if urlParts.count == 2 {
                let queryParts = urlParts[1].components(separatedBy: "=")
                if queryParts.count == 2 {
                    NotificationCenter.default.post(name: kPresentPostNotification, object: self, userInfo: [queryParts[0]: queryParts[1]])
                }
            }
        }
    }
    
    func showAlertView(from aps: [String: Any], and url: URL) {
        guard let viewController = window?.rootViewController,
            let alert = aps["alert"] as? [String: String],
            let title = alert["title"],
            let body = alert["body"] else {
                return
        }
        UIAlertController.showDiscardAlertView(in: viewController, title: title, message: body, buttonTitle: "View".localized()) { (_) in
            self.handleDeepLink(from: url)
        }
    }
}

