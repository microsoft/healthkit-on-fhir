//
//  AppDelegate.swift
//  researchKitOnFhir
//

import UIKit
import SMART

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    public var smartClient: Client?
    public static var callbackScheme = "researchkitonfhir"
    public static let servicesDidUpdateNotification = Notification.Name.init("ServicesDidUpdate")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        guard ConfigHelper.loadSavedConfiguration() else {
            return true
        }
        
        initializeServices()
        
        return true
    }
    
    public func initializeServices() {
        // Create the SMART on FHIR client
        let smartClientBaseUrl = ConfigHelper.smartClientBaseUrl
        let smartClientClientId = ConfigHelper.smartClientClientId
        let redirect = "\(AppDelegate.callbackScheme)://callback"
        
        smartClient = Client(
            baseURL: URL(string: smartClientBaseUrl)!,
            settings: ["client_id": smartClientClientId, "redirect": redirect])
        
        smartClient?.authProperties.granularity = .tokenOnly
        
        // TODO: implement token refresh capability - authentication times out with current implementation
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

