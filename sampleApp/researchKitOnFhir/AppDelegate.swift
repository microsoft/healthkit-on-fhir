//
//  AppDelegate.swift
//  researchKitOnFhir
//
//  Created by admin on 6/22/21.
//

import UIKit
import SMART

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    public var smartClient: Client?
    public static var callbackScheme = "researchkitonfhir"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        initializeServices()
        
        return true
    }
    private func initializeServices() {
        // Create the SMART on FHIR client
        let smartClientBaseUrl = ConfigHelper.smartClientBaseUrl
        let smartClientClientId = ConfigHelper.smartClientClientId
        let redirect = ConfigHelper.redirect
        
        smartClient = Client(
            baseURL: URL(string: smartClientBaseUrl!)!,
            settings: ["client_id": smartClientClientId, "redirect": redirect])
        
        smartClient?.authProperties.granularity = .tokenOnly
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        if url.scheme == AppDelegate.callbackScheme {
            guard smartClient != nil else {
                return false
            }
            
            if smartClient!.awaitingAuthCallback {
                return smartClient!.didRedirect(to: url)
            }
        }
        return false
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

