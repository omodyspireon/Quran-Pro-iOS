//
//  AppDelegate.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit
import AVFoundation
import MessageUI

enum UIUserInterfaceIdiom: Int {
    case unspecified
    case phone // iPhone and iPod touch style UI
    case pad // iPad style UI
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppiraterDelegate, MFMailComposeViewControllerDelegate {

    var window: UIWindow?
    @objc var appUrlToOpen: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

//        if !isDebug {
//            //Flurry.startSession(kFlurryAPIKey, withOptions: launchOptions)
//            //Flurry.setAppVersion(kApplicationVersion as String)
//            //Flurry.setCrashReportingEnabled(true)
//        }

        // Parse.setApplicationId(kParseAppId, clientKey: kParseClientKey)

        // Set the app rate system
        Appirater.setAppId(kAppId)
        Appirater.setDaysUntilPrompt(7)
        Appirater.setUsesUntilPrompt(5)
        Appirater.setSignificantEventsUntilPrompt(-1)
        Appirater.setTimeBeforeReminding(2)
        Appirater.setDebug(false)
        Appirater.setDelegate(self)
        // Appirater.setCustomAlertSendFriendButtonTitle("Tell a friend".local)

        // Style the navigation bar
        UINavigationBar.appearance().tintColor = kUINavigationBarTintColor
        UINavigationBar.appearance().backgroundColor = UIColor(red: 79, green: 106, blue: 173)

        UINavigationBar.appearance().setBackgroundImage(UIImage(named: kUINavigationBarBackgroundImage), for: UIBarMetrics.default)
        // let shadow = NSShadow()
        // shadow.shadowOffset = kUINavigationBarTitleShadowSize

        UINavigationBar.appearance().titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.foregroundColor.rawValue: kUINavigationBarTitleColor,
            // NSShadowAttributeName: shadow,
            NSAttributedString.Key.font.rawValue: kUINavigationBarTitleFont
        ])

        if #available(iOS 15.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor(red: 79, green: 106, blue: 173)
            navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                    NSAttributedString.Key.font: kUINavigationBarTitleFont]
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        }

        // Style the status bar
        UIApplication.shared.setStatusBarStyle(kUIStatusBarStyle, animated: false)

        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()

        // Inits the data service
        let _ = DataService.sharedInstance()

        // Inits the download service
        let _ = DownloadService.sharedInstance()

        // Bookmarks service
        let _ = BookmarkService.sharedInstance()

        if UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:))) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge], categories: nil))
        }

        var error: NSError?
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            // Flurry.logError(FlurryEvent.enableAudioSession, message: error!.description, error: error)
        }

        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.backgroundColor = UIColor.white

//        // Register for Push Notitications
//        if application.applicationState != UIApplicationState.Background {
//            
//            // Track an app open here if we launch with a push, unless
//            // "content_available" was used to trigger a background push (introduced in iOS 7).
//            // In that case, we skip tracking here to avoid double counting the app-open.
//            
//            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
//            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
//            var pushPayload = true
//            if let options = launchOptions {
//                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
//            }
//            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
//                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
//            }
//        }

//        if application.respondsToSelector("registerUserNotificationSettings:") {
//            let userNotificationTypes:UIUserNotificationType  = [.Alert, .Badge, .Sound]
//            //let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
//            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
//            application.registerUserNotificationSettings(settings)
//            application.registerForRemoteNotifications()
//        } else {
//            application.registerForRemoteNotifications()
//        }

        // Extract the notification data
//        if let notificationPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
//            // Create a pointer to the Photo object
//            if let newAppId = notificationPayload["app-id"] as? NSString {
//                appUrlToOpen = kAppUrl.localizeWithFormat(newAppId)
//             }
//        }

        Appirater.appLaunched(true)

        return true
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    // hadle the remote actions
    override func remoteControlReceived(with event: UIEvent?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: kBeginReceivingRemoteControlEvents), object: event, userInfo: nil)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        Appirater.appEnteredForeground(true)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        try! AVAudioSession.sharedInstance().setActive(true)

        if appUrlToOpen != nil {
            UIApplication.shared.openURL(URL(string: appUrlToOpen!)!)
            appUrlToOpen = nil
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

//    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//        let installation = PFInstallation.currentInstallation()
//        installation!.setDeviceTokenFromData(deviceToken)
//        installation!.addUniqueObject("Quran-App\(dollar.currentLanguageKey)", forKey: "channels")
//        installation!.saveInBackground()
//    }

//    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
//        if error.code == 3010 {
//            print("Push notifications are not supported in the iOS Simulator.")
//        } else {
//            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
//        }
//    }

//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        PFPush.handlePush(userInfo)
//        if application.applicationState == UIApplicationState.Inactive {
//            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
//        }
//    }

//    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//        // Extract the notification data
//        print(application.applicationState.rawValue)
//        //if application.applicationState != UIApplicationState.Inactive {
//            var title: String?
//            if let aps = userInfo["aps"] as? NSDictionary {
//                if let alert = aps["alert"] as? NSDictionary {
//                    if let message = alert["message"] as? NSString {
//                        title = message as String
//                    }
//                }
//                else if let alert = aps["alert"] as? NSString {
//                    title = alert as String
//                }
//            }
//        
//        if let newAppId = userInfo["app-id"] as? String {
//            appUrlToOpen = kAppUrl.localizeWithFormat(newAppId)
//        }
//        if(application.applicationState != UIApplicationState.Inactive) {
//            NSOperationQueue.mainQueue().addOperationWithBlock({
//                let alertController = UIAlertController(title: kApplicationDisplayName as String, message:
//                    title, preferredStyle: UIAlertControllerStyle.Alert)
//                if self.appUrlToOpen != nil {
//                    alertController.addAction(UIAlertAction(title: "Open".local, style: UIAlertActionStyle.Default,handler: {_ in
//                        if let url = NSURL(string: self.appUrlToOpen!) {
//                            UIApplication.sharedApplication().openURL(url)
//                            self.appUrlToOpen = nil
//                        }
//                    }))
//                }
//                alertController.addAction(UIAlertAction(title: self.appUrlToOpen != nil ? "Cancel".local : "OK".local, style: UIAlertActionStyle.Default,handler: nil))
//                self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
//            })
//        }
//        completionHandler(UIBackgroundFetchResult.NoData)
//     }

    func backgroundFetchResultcompletionHandler(_ result: UIBackgroundFetchResult?) {
//        print("backgroundFetchResultcompletionHandler")
    }

    // MARK: background session handling
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
//        print("-- handleEventsForBackgroundURLSession --")
//        let backgroundConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(identifier)
//        let backgroundSession = NSURLSession(configuration: backgroundConfiguration, delegate: DownloadService.sharedInstance(), delegateQueue: nil)
//        print("Rejoining session \(backgroundSession)")
//        self.delegate.addCompletionHandler(completionHandler, identifier: identifier)
    }

    func appiraterDidDecline(toRate appirater: Appirater) {
        // Flurry.logEvent(FlurryEvent.appiraterDidDeclineToRate)
    }

    func appiraterDidOpt(toRate appirater: Appirater) {
        // Flurry.logEvent(FlurryEvent.appiraterDidOptToRate)
    }

    func appiraterDidOpt(toRemindLater appirater: Appirater) {
        // Flurry.logEvent(FlurryEvent.appiraterDidOptToRemindLater)
    }

    @objc func appiraterDidOptToMail(_ appirater: Appirater) {
        // Flurry.logEvent(FlurryEvent.appiraterDidOptToMail)
        let tellAFriendMail = MFMailComposeViewController()
        tellAFriendMail.mailComposeDelegate = self
        tellAFriendMail.setSubject("Tell a friend subject".local)
        let message = "Tell a friend message".local
        tellAFriendMail.setMessageBody(message.localizeWithFormat(dollar.currentLanguageKey, kAppId), isHTML: true)
        self.window?.rootViewController?.present(tellAFriendMail, animated: true, completion: nil)
    }

    // MARK: MFMailComposeViewController delegate
    // this is duplicate!!!
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//        switch result.rawValue {
//        case MFMailComposeResult.cancelled.rawValue:
//            //Flurry.logEvent(FlurryEvent.tellAfriendMailCancelled)
//        case MFMailComposeResult.saved.rawValue:
//            //Flurry.logEvent(FlurryEvent.tellAfriendSaved)
//        case MFMailComposeResult.sent.rawValue:
//            //Flurry.logEvent(FlurryEvent.tellAfriendMailSent)
//        case MFMailComposeResult.failed.rawValue:
//            //Flurry.logError(FlurryEvent.tellAfriendMailFaild, message: error!.localizedDescription, error: error)
//        default:
//            break
//        }
        self.window?.rootViewController?.dismiss(animated: false, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
