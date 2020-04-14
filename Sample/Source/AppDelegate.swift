//
//  AppDelegate.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import UIKit
import HealthKit
import IomtFhirClient
import HealthKitOnFhir
import HealthKitToFhir
import HealthDataSync
import SMART

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    public static let servicesDidUpdateNotification = Notification.Name.init("ServicesDidUpdate")
    public var smartClient: Client?
    public var syncManager: HDSManagerProtocol?
    private static var callbackScheme = "healthkitonfhir"
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Load the configuration
        guard ConfigurationHelper.loadSavedConfiguration() else {
            return true
        }
        
        initializeServices()
        
        return true
    }
    
    private func initializeServices() {
        // Create the SMART on FHIR client
        smartClient = Client(
            baseURL: URL(string: ConfigurationHelper.smartClientBaseUrl)!,
            settings: [ "client_id": ConfigurationHelper.smartClientClientId, "redirect": AppDelegate.callbackScheme + "://callback" ]
        )
        
        // Token only so the patient picker does not show.
        smartClient?.authProperties.granularity = .tokenOnly
        
        // The Health Data Sync Manager must be initialized during the didFinishLaunching method call so that observer query callbacks
        // will be processed if the application was terminated.
        do {
            // Instantiate a new Health Data Sync Manager.
            syncManager = HDSManagerFactory.manager()
            
            // Device factory used for both IoMT FHIR Connector for Azure and FHIR external store delegates.
            let deviceFactory = DeviceFactory()
            
            // Create an IoMT FHIR Client to handle the transport of high frequency data.
            let iomtFhirClient = try IomtFhirClient.CreateFromConnectionString(connectionString: ConfigurationHelper.eventHubsConnectionString)
            // Initialize the external store object with the client.
            let iomtFhirExternalStore = IomtFhirExternalStore(iomtFhirClient: iomtFhirClient)
            // (Optional) Set the delegate to handle pre and post request.
            iomtFhirExternalStore.delegate = IomtFhirDelegate(smartClient: smartClient!, deviceFactory: deviceFactory)
            // Set the object types that will be synchronized and the destination store.
            syncManager?.addObjectTypes([HeartRateMessage.self, StepCountMessage.self, OxygenSaturationMessage.self, BodyTemperatureMessage.self, RespiratoryRateMessage.self], externalStore: iomtFhirExternalStore)
            
            // Create the FHIR external store to handle low frequency data.
            let fhirExternalStore = FhirExternalStore(server: smartClient!.server)
            // (Optional) Set the delegate to handle pre and post request.
            fhirExternalStore.delegate = FhirDelegate(smartClient: smartClient!, deviceFactory: deviceFactory)
            syncManager?.addObjectTypes([BloodPressureContainer.self, BloodGlucoseContainer.self, BodyMassContainer.self, HeightContainer.self], externalStore: fhirExternalStore)
            // Set the converter
            syncManager?.converter = Converter(converterMap: [Observation.resourceType : try ObservationFactory()])
            
            // (Optional) Set the observer delegates to get callbacks before and after querys are executed.
            syncManager?.observerDelegate = QueryObserverDelegate()
            
            // Start observing HealthKit for changes.
            // If the user has not granted permissions to access requested HealthKit types the start call will be ignored.
            syncManager?.startObserving()
            
        } catch {
            // Handle any errors
            print(error)
        }
    }
    
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
        
        if ConfigurationHelper.loadConfiguation(url: url) {
            do {
                // The configuration has already been loaded - Delete the JSON file
                try FileManager.default.removeItem(at: url)
            } catch {
                print("Unable to delete configuration file - \(error)")
            }
            initializeServices()
            NotificationCenter.default.post(name: AppDelegate.servicesDidUpdateNotification, object: nil)
            return true
        }
        
        return false
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

