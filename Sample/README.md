# HealthKitOnFhir_Sample

This sample application provides implementation examples for the HealthKitOnFhir Swift Library. The application will allow users to log in, create a simple Patient Resource, authorize access to Apple Health data, and continutally export heart rate, step count, blood pressure and blood glucose to a FHIR Server in the form of Observation Resources. The application will also create Device Resources for each device and/or application that generated the Observation.

## Prerequisites

Before launching the application make sure you have a FHIR Server supporting version R4 and SMART on FHIR, and an [IoMT FhirConnector for Azure](https://github.com/microsoft/iomt-fhir) set up. There are many FHIR Server options available, but for ease of setup, we recommend either deploying an instance of [FHIR Server for Azure](https://github.com/microsoft/fhir-server) or using [Azure API for FHIR](https://azure.microsoft.com/en-us/services/azure-api-for-fhir/).

## Configuring the application

The [Config.json](Config.json) file provides a way to set the FHIR Server URL and [IoMT FHIR Client](https://github.com/microsoft/iomt-fhir-client) Connection String without the need to change any source code or recompile the application. All values are required for the application to function correctly.  

```json
{
    "eventHubsConnectionString": "{ YOUR_DEVICE_CONNECTION_STRING }",
    "smartClientBaseUrl": "{ YOUR_FHIR_SERVER_URL }",
    "smartClientClientId": "{ YOUR_CLIENT_ID }",
    "smartClientAuthorizeUri": "{ YOUR_FHIR_SERVER_AUTH_URI }",
    "smartClientTokenUri": "{ YOUR_FHIR_SERVER_TOKEN_URI }"
}
```

<div style="text-align:center"><img src="Launch_Screen.png" /></div>

When the application is launched (before it is configured), a message will appear notifying the user that a configuration is required.

1. For iOS Simulator: Drag the Config.json file onto the screen of the simulator.

2. For iPhone: The Config.json file can be sent to the device via email, text message, iCloud, AirDrop etc. Tapping on the file will bring a menu to select the application to open the file. Select "HK on FHIR".

After the application has been configured, subsequent launches will not show this screen again.
