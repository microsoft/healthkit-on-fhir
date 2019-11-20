# HealthKitOnFhir

[![Build Status](https://microsofthealth.visualstudio.com/Health/_apis/build/status/POET/HealthKitOnFhir_Daily?branchName=master)](https://microsofthealth.visualstudio.com/Health/_build/latest?definitionId=441&branchName=master)

HealthKitOnFhir is a Swift library that automates the export of Apple HealthKit Data to a FHIR® Server. HealthKit data can be routed through the [IoMT FHIR Connector for Azure](https://github.com/microsoft/iomt-fhir) for grouping high frequency data to reduce the number of Observation Resources generated. HealthKit Data can also be exported directly to a FHIR Server (appropriate for low frequency data). The most basic implementation requires:

1. initializing an ExternalStore object,
2. adding the types that you wish to be exported to the HDSManager (Health Data Sync Manager),
3. calling the startObserving() method,
4. and calling requestPermissionsForAllObservers() on the HDSManager (will request permission from the user for access to the appropriate data types).

## Sample Application

For a detailed example of how to use HealthKitOnFhir, see the sample application in the [Sample](https://github.com/microsoft/healthkit-on-fhir/tree/master/Sample) directory.

## Installation

HealthKitOnFhir uses **Swift Package Manager** to manage dependencies. It is recommended that you use Xcode 11 or newer to add HealthKitOnFhir to your project.

1. Using Xcode 11 go to File > Swift Packages > Add Package Dependency
2. Paste the project URL: https://github.com/microsoft/healthkit-on-fhir
3. Click on next and select the project target

## Basic Implementation

HealthKitOnFhir is an implementation of the [HealthDataSync Swift library](https://github.com/microsoft/health-data-sync). HealthKitOnFhir defines the External Store as a FHIR Server, and provides a simple way to export high frequency data using the [IoMT FHIR Connector for Azure](https://github.com/microsoft/iomt-fhir) and low frequency data using an instance of a [Swift-FHIR](https://github.com/smart-on-fhir/Swift-FHIR) FHIRServer.

### Exporting High Frequency Data

```swift
// Use the HDSManagerFactory to get the singleton instance of the HDSManager (Health Data Sync Manager).
// The syncManager should be fully configured before the AppDelegate didFinishLaunchingWithOptions completes
// so changes to HealthKit data can be handled if the application is not running.
let syncManager = HDSManagerFactory.manager();

// Create an IoMT FHIR Client to handle the transport of high frequency data.
let iomtFhirClient = try IomtFhirClient.CreateFromConnectionString(connectionString: { YOUR_CONNECTION_STRING_HERE })

// Initialize the external store object with the Client.
let iomtFhirExternalStore = IomtFhirExternalStore(iomtFhirClient: iomtFhirClient)

// Set the object types that will be synchronized and the destination store.
syncManager?.addObjectTypes([HeartRateMessage.self, StepCountMessage.self], externalStore: iomtFhirExternalStore)

// Start observing HealthKit for changes.
// If the user has not granted permissions to access requested HealthKit types, the start call will be ignored.
syncManager?.startObserving()
```

### Exporting Low Frequency Data

Below, we are initializing a [Swift-Smart](https://github.com/smart-on-fhir/Swift-SMART) Client for a SMART on FHIR application and instantiating a FhirExternalStore using the FHIRServer provided by the Client. We are also setting a Converter to handle the conversion of HealthKit Data to FHIR Resources - See: [HealthKitToFhir](https://github.com/microsoft/healthkit-to-fhir).

```swift
// Create the Swift-Smart Client
let client = Client(
    baseURL: URL(string: { YOUR_FHIR_URL })!,
    settings: [ "client_id": { YOUR_CLIENT_ID }, "redirect": { YOUR_REDIRECT } ])

// Create the FHIR external store using the client.server to handle low frequency data.
let fhirExternalStore = FhirExternalStore(server: client.server)

// Set the object types that will be synchronized and the destination store.
syncManager?.addObjectTypes([BloodPressureContainer.self, BloodGlucoseContainer.self], externalStore: fhirExternalStore)

// REQUIRED: Set a HKObject to FHIR Resource converter to convert HealthKit Data to Fhir resources.
// In this case we are using the HealthKitToFhir ObservationFactory to handle Observation Resources.
syncManager?.converter = Converter(converterMap: [Observation.resourceType : try ObservationFactory()])

// Start observing HealthKit for changes.
// When new types are added startObserving must be called to begin 'listening' for changes.
// If the user has not granted permissions to access requested HealthKit types the start call will be ignored.
syncManager?.startObserving()
```

### Adding a delegate for the IomtFhirExternalStore

Creating an IomtFhirExternalStoreDelegate will provide your application a way to receive callbacks before HealthKit data is exported and after the export has completed. There are 2 optional methods that can be implemented to receive these callbacks:

```swift
/// Called once for each EventData after a HealthKit query has completed but before the data is sent to the IoMT FHIR Client.
    ///
    /// - Parameters:
    ///   - eventData: The EventData object to be sent.
    ///   - object: The original underlying HealthKit HKObject.
    ///   - completion: Must be called to start the upload of the EventData. Return true to start the upload and false to cancel. Optional Error will be passed to the IomtFhirExternalStore.
    func shouldAdd(eventData: EventData, object: HKObject?, completion: @escaping (Bool, Error?) -> Void)

    /// Called after ALL data is sent to the IoMT FHIR Client.
    ///
    /// - Parameters:
    ///   - eventDatas: The EventData that was sent to the IoMT FHIR Client.
    ///   - success: Bool representing whether or not the request was successful.
    ///   - error: An Error with detail about the failure (will be nil if the operation was successful).
    func addComplete(eventDatas: [EventData], success: Bool, error: Error?)
```

### Adding a delegate to the FhirExternalStore

Like the IomtFhirExternalStoreDelegate the FhirExternalStore delegate can provide your application callbacks before and after HealthKit data is exported to the FHIR server (POST), However the FhirExternalStore also supports GET, PUT and DELETE, so delegate methods can be added to receive callbacks before and after any of these operations. The implementation of any of these methods is optional:

```swift
/// Called after a HealthKit query has completed but before the data is fetched from the FHIR server.
    ///
    /// - Parameters:
    ///   - objects: The collection of HDSExternalObjectProtocol objects used to fetch resources from the Server.
    ///   - completion: MUST be called to start the fetch of the FHIR.Resources. Return true to start the fetch process and false to cancel. Optional Error will be passed to the FhirExternalStore.
    func shouldFetch(objects: [HDSExternalObjectProtocol], completion: @escaping (Bool, Error?) -> Void)

    /// Called after all data is fetched from the FHIR Server.
    ///
    /// - Parameters:
    ///   - objects: The collection of HDSExternalObjectProtocol objects used to fetch resources from the Server.
    ///   - success: Bool representing whether or not the request was successful.
    ///   - error: An Error with detail about the failure (will be nil if the operation was successful).
    func fetchComplete(objects: [HDSExternalObjectProtocol]?, success: Bool, error: Error?)

    /// Called after a HealthKit query has completed but before the data is sent to the FHIR server.
    ///
    /// - Parameters:
    ///   - resource: The FHIR.Resource object to be sent.
    ///   - object: The original underlying HealthKit HKObject.
    ///   - completion: MUST be called to start the upload of the FHIR.Resource. Return true to start the upload and false to cancel. Optional Error will be passed to the FhirExternalStore.
    func shouldAdd(resource: Resource, object: HKObject?, completion: @escaping (Bool, Error?) -> Void)

    /// Called after all data is sent to the FHIR Server.
    ///
    /// - Parameters:
    ///   - objects: The collection of HDSExternalObjectProtocol objects used to add resources to the Server.
    ///   - success: Bool representing whether or not the request was successful.
    ///   - error: An Error with detail about the failure (will be nil if the operation was successful).
    func addComplete(objects: [HDSExternalObjectProtocol], success: Bool, error: Error?)

    /// Called after a HealthKit query has completed but before the data is updated in the FHIR server.
    ///
    /// - Parameters:
    ///   - resource: The FHIR.Resource object to be updated.
    ///   - object: The original underlying HealthKit HKObject.
    ///   - completion: MUST be called to initiate the update on the FHIR.Resource. Return true to start the update request and false to cancel. Optional Error will be passed to the FhirExternalStore.
    func shouldUpdate(resource: Resource, object: HKObject?, completion: @escaping (Bool, Error?) -> Void)

    /// Called after all data is updated on the FHIR Server.
    ///
    /// - Parameters:
    ///   - containers: The collection of HDSExternalObjectProtocol objects used to update resources on the Server.
    ///   - success: Bool representing whether or not the request was successful.
    ///   - error: An Error with detail about the failure (will be nil if the operation was successful).
    func updateComplete(objects: [HDSExternalObjectProtocol], success: Bool, error: Error?)

    /// Called after a HealthKit query has completed but before the delete request is sent the FHIR server.
    ///
    /// - Parameters:
    ///   - resource: The FHIR.Resource object to be deleted.
    ///   - object: The HealthKit HKDeletedObject.
    ///   - completion: MUST be called to initiate the deletion of the FHIR.Resource. Return true to delete and false to cancel. Optional Error will be passed to the FhirExternalStore.
    func shouldDelete(resource: Resource, deletedObject: HKDeletedObject?, completion: @escaping (Bool, Error?) -> Void)

    /// Called after all deletes are completed on the FHIR Server.
    ///
    /// - Parameters:
    ///   - success: Bool representing whether or not the request was successful.
    ///   - error: An Error with detail about the failure (will be nil if the operation was successful).
    func deleteComplete(success: Bool, error: Error?)
```

## Adding additional types

HealthKitOnFhir currently supports the following types for both IoMTFhirClients and FhirClients:

- HKQuantityTypeIdentifierHeartRate
- HKCorrelationTypeIdentifierBloodPressure
- HKQuantityTypeIdentifierBloodPressureDiastolic
- HKQuantityTypeIdentifierBloodPressureSystolic
- HKQuantityTypeIdentifierStepCount
- HKQuantityTypeIdentifierBloodGlucose

### IomtFhirClient (High Frequency Data)

Adding new export types for the IomtFhirExternalStore requires creating a subclass of the [IomtFhirMessageBase](Source/IomtFhir/Messages/IomtFhirMessageBase.swift) and implementing the [HealthDataSync](https://github.com/microsoft/health-data-sync) Swift library's [HDSExternalObjectProtocol](https://github.com/microsoft/health-data-sync/blob/master/Sources/Synchronizers/HDSExternalObjectProtocol.swift). IomtFhirMessages are serialized into a JSON payload and sent to an [IoMT FHIR Connector for Azure](https://github.com/microsoft/iomt-fhir) and new types must be added to the IoMT FHIR Connector for Azure configuration file. Details about how to set up the configuration file can be found [here](https://github.com/microsoft/iomt-fhir/README.MD).

Below is an example of a class created for exporting Blood Glucose.

```swift
open class BloodGlucoseMessage : IomtFhirMessageBase, HDSExternalObjectProtocol {
    // These 2 properties will be serialized into the JSON payload.
    internal var bloodGlucose: Double?
    internal let unit = "mg/dL"

    public init?(object: HKObject) {
        guard let sample = object as? HKQuantitySample,
            sample.quantityType == BloodGlucoseMessage.healthKitObjectType() else {
                return nil
        }

        super.init(uuid: sample.uuid, startDate: sample.startDate, endDate: sample.endDate)

        self.update(with: object)
        self.healthKitObject = object
    }

    // Required because the super class conforms to Codable protocol.
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    // HDSExternalObjectProtocol method. HKObjectTypes returned here will be used for obtaining permissions from the user.
    // Types returned here will be displayed to the user in the OS controlled health data permissions UI.
    public static func authorizationTypes() -> [HKObjectType]? {
        if let bloodGlucoseType = healthKitObjectType() {
            return [bloodGlucoseType]
        }

        return nil
    }

    // HDSExternalObjectProtocol method. HKObjectTypes returned here will be used for querying HealthKit.
    public static func healthKitObjectType() -> HKObjectType? {
        return HKObjectType.quantityType(forIdentifier: .bloodGlucose)
    }

    // HDSExternalObjectProtocol method. Return an initialized IomtFhirMessageBase object here.
    // The object will be serialized and exported using the IomtFhirExternalStore.
    public static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return BloodGlucoseMessage.init(object: object)
    }

    // HDSExternalObjectProtocol method. Should return nil.
    // Deleting objects using the IomtFhirExternalStore is currently not supported.
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return nil
    }

    // HDSExternalObjectProtocol method.
    public func update(with object: HKObject) {
        if let sample = object as? HKQuantitySample {
            bloodGlucose = sample.quantity.doubleValue(for: HKUnit(from: unit))
        }
    }

    // Required for serialization.
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bloodGlucose, forKey: .bloodGlucose)
        try container.encode(unit, forKey: .unit)
    }

    // Required for serialization.
    private enum CodingKeys: String, CodingKey {
        case bloodGlucose
        case unit
    }
}
```

### FhirClient (Low Frequency Data)

Adding new export types for the FhirExternalStore requires creating a subclass of the [ResourceContainer](Source/Fhir/Resources/ResourceContainer.swift) and also implementing the [HealthDataSync](https://github.com/microsoft/health-data-sync) Swift library's [HDSExternalObjectProtocol](https://github.com/microsoft/health-data-sync/blob/master/Sources/Synchronizers/HDSExternalObjectProtocol.swift). It's important to make sure that the HKObject to FHIR Resource converter supports any new export types added. The [HealthKitOnFhir Sample application](https://github.com/microsoft/healthkit-on-fhir/tree/master/Sample) uses the [HealthKitToFhir](https://github.com/microsoft/healthkit-to-fhir) Swift library to handle the conversion of HKObjects.

```swift
open class BloodGlucoseContainer : ResourceContainer<Observation>, HDSExternalObjectProtocol {
    internal let unit = "mg/dL"

    // HDSExternalObjectProtocol method. HKObjectTypes returned here will be used for obtaining permissions from the user.
    // Types returned here will be displayed to the user in the OS controlled health data permissions UI.
    public static func authorizationTypes() -> [HKObjectType]? {
        if let bloodGlucoseType = healthKitObjectType() {
            return [bloodGlucoseType]
        }

        return nil
    }

    // HDSExternalObjectProtocol method. HKObjectTypes returned here will be used for querying HealthKit.
    public static func healthKitObjectType() -> HKObjectType? {
        return HKObjectType.quantityType(forIdentifier: .bloodGlucose)
    }

    // HDSExternalObjectProtocol method. Return an initialized ResourceContainer here.
    // The object and converter are passed to the super on initialization.
    public static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        if let sample = object as? HKSample,
            sample.sampleType == BloodGlucoseContainer.healthKitObjectType() {
            return BloodGlucoseContainer(object: object, converter: converter)
        }

        return nil
    }

    // HDSExternalObjectProtocol method. Return an initialized ResourceContainer here.
    // The deletedObject and converter are passed to the super on initialization.
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return BloodGlucoseContainer(deletedObject: deletedObject, converter: converter)
    }

    // HDSExternalObjectProtocol method. Update the resource with the HKObject.
    public func update(with object: HKObject) {
        if let sample = object as? HKQuantitySample {
            resource?.valueQuantity?.value = FHIRDecimal(Decimal(floatLiteral: sample.quantity.doubleValue(for: HKUnit(from: unit))))
        }
    }
}

```

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

There are many other ways to contribute to the HealthDataSync Project.

* [Submit bugs](https://github.com/microsoft/healthkit-on-fhir/issues) and help us verify fixes as they are checked in.
* Review the [source code changes](https://github.com/microsoft/healthkit-on-fhir/pulls).
* [Contribute bug fixes](CONTRIBUTING.md).

See [Contributing to HealthKitOnFhir](CONTRIBUTING.md) for more information.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

FHIR® is the registered trademark of HL7 and is used with the permission of HL7. Use of the FHIR trademark does not constitute endorsement of this product by HL7.
