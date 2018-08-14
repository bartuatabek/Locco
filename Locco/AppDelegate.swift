//
//  AppDelegate.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn
import CoreLocation
import UserNotifications
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        // MARK: - Notifications
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // Enable or disable features based on authorization.
            if granted {
                center.removeAllPendingNotificationRequests()
                center.removeAllDeliveredNotifications()
            }
        }
        
        // MARK: - Firebase Auth Config
        FirebaseApp.configure()
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        // MARK: - User Defaults
//        let userDefaults = UserDefaults.standard
//        if userDefaults.value(forKey: "appFirstTimeOpend") == nil {
//            //if app is first time opened then it will be nil
//            userDefaults.setValue(true, forKey: "appFirstTimeOpend")
//            // signOut from FIRAuth
//            do {
//                try Firebase.Auth.auth().signOut()
//                let domain = Bundle.main.bundleIdentifier!
//                UserDefaults.standard.removePersistentDomain(forName: domain)
//                UserDefaults.standard.synchronize()
//            } catch {
//                print("Sign out failed: ", error)
//            }
//            // go to beginning of app
//        } else {
            if let providerData = Firebase.Auth.auth().currentUser?.providerData {
                for userInfo in providerData {
                    switch userInfo.providerID {
                    case "facebook.com", "google.com", "phone":
                        let mainStoryboard = UIStoryboard(name: "Home", bundle: nil)
                        let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "Home") as UIViewController
                        let navigationController = UINavigationController(rootViewController: rootViewController)
                        navigationController.isNavigationBarHidden = true // or not, your choice.
                        
                        self.window = UIWindow(frame: UIScreen.main.bounds)
                        self.window!.rootViewController = navigationController
                        self.window!.makeKeyAndVisible()
                    default:
                        if (Firebase.Auth.auth().currentUser?.isEmailVerified)! {
                            let mainStoryboard = UIStoryboard(name: "Home", bundle: nil)
                            let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "Home") as UIViewController
                            let navigationController = UINavigationController(rootViewController: rootViewController)
                            navigationController.isNavigationBarHidden = true // or not, your choice.
                            
                            self.window = UIWindow(frame: UIScreen.main.bounds)
                            self.window!.rootViewController = navigationController
                            self.window!.makeKeyAndVisible()
                        }
                    }
                }
            }
//        }
        
        return true
    }
    
    func handleEvent(forRegion region: CLRegion!) {
        // Show an alert if application is active
        if UIApplication.shared.applicationState == .active {
            guard let message = note(fromRegionIdentifier: region.identifier) else { return }
            window?.rootViewController?.showAlert(withTitle: nil, message: "Arrived at \(message)")
        } else {
            // Otherwise present a local notification
            let content = UNMutableNotificationContent()
            //            content.title = NSString.localizedUserNotificationString(forKey: "Elon said:", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "Arrived at \(note(fromRegionIdentifier: region.identifier) ?? "")", arguments: nil)
            content.sound = UNNotificationSound.default
            content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber;
            content.categoryIdentifier = "com.VLMedia.Location-Tracker"
            // Deliver the notification in five seconds.
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 60.0, repeats: true)
            let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
            
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request)
        }
    }
    
    func note(fromRegionIdentifier identifier: String) -> String? {
        let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedPlaces) as? [NSData]
        let geotifications = savedItems?.map { NSKeyedUnarchiver.unarchiveObject(with: $0 as Data) as? GeoPlace }
        let index = geotifications?.index { $0?.identifier == identifier }
        return index != nil ? geotifications?[index!]?.name : nil
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error {
            print("Failed to log into Google: ", err)
            return
        }
        
        print("Successfully logged into Google", user)
        
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        Firebase.Auth.auth().signInAndRetrieveData(with: credentials, completion: { (user, error) in
            if let err = error {
                print("Failed to create a Firebase User with Google account: ",  err)
                return
            }
            guard let uid = user?.user.uid else { return }
            print("Successfully logged into Firebase with Google:", uid)
            
            if let controller = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "Home") as? UITabBarController {
                if let window = self.window, let rootViewController = window.rootViewController {
                    var currentController = rootViewController
                    while let presentedController = currentController.presentedViewController {
                        currentController = presentedController
                    }
                    currentController.present(controller, animated: true, completion: nil)
                }
            }
        })
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = FBSDKApplicationDelegate.sharedInstance()?.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        
        GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        
        return handled!
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
}



