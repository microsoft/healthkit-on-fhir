# Overview

People with diabetes need to monitor their blood sugar and take insulin regularly. There are a mirad of devices on the market for patients to monitor their blood sugar, for example, [OneTouch glucose meters](https://www.onetouch.com/products) or [True Metrix devices](https://www.trividiahealth.com/products/blood-glucose-meters-test-strips/true-metrix-air/). This document explains how Azure FHIR can help both patients and healthcare providers to leverage these devices to improve the quality of care.

## As a developer, how do I collect data from consumer diabetes devices to Azure FHIR so that I can build an application for health care providers to remotely review/monitor patient data and provide care

### Archtecture

The following diagram illustrates how to integrate data from consumer diabetes devices to Azure FHIR:
![Alt text](Media/DiabetesDeviceToFHIR.png?raw=true "device_to_fhir")

Consumer diabetes devices may or may not have bluetooth connections to mobile phones. As mobile phones are ubiqutous, device vendors are starting to offer mobile apps for their devices. The mobile app could sync the data from devices via bluetooth, or the user could manually input data to the mobile app.

From the mobile app, there are multiple options to send data to [Azure FHIR](https://docs.microsoft.com/en-us/azure/healthcare-apis/fhir/overview).

1. If the vendor provides a programming interface to retrieve data either from the mobile app or from their cloud service (if the mobile app sends data to the cloud), then a developer could:

   1. write an app using the vendor API to get the data
   1. call the Azure FHIR API to ingest data to Azure FHIR, or send high frequency sample data to Azure IoMT Connector for FHIR which aggregates observation data to send to Azure FHIR

1. If the vendor integrates their mobile app with the Health app on iPhone, then a developer could:

   1. write an app, such as the sample provided in this repo, for Apple HealthKit to ingest high frequency data to [Azure IoMT Connector to Azure FHIR](https://github.com/microsoft/iomt-fhir/) and low frequency data to Azure FHIR directly.

We recommend **option #2**, as illustrated in the above diagram, for the following reasons:

1. iPhone and Andriod phones dominate the mobile market and have mature developer support for their HealthKit and Google Fit apps. As a developer, you only need to write one app for iPhone and one for Android to collect data from a variety of devices to send to Azure FHIR rather than writing an app for each device.
1. Device vendors are already integrating their mobile apps to HealthKit and Google Fit so their users can have a single pane of glass for health/fitness management.
1. Device vendors' app and HealthKit take care of user consent to share data with HealthKit. As a developer, you just need to program against HealthKit to obtain user consent to share HealthKit data with your app.

### Deploy Azure Resources

In the README of this repo, we documented on how to install the sample app that a developer will build. For this sample app to communicate with Azure FHIR, you also need to deploy resources in Azure. Here are the steps:

1. Deploy an instance of [Azure FHIR managed service](https://docs.microsoft.com/en-us/azure/healthcare-apis/fhir/fhir-paas-portal-quickstart)
1. Deploy the Azure IoMT Connector for FHIR. There are two ways to do this:

   - [Deploy the Azure IoMT Connector as an Azure FHIR resource](https://docs.microsoft.com/en-us/azure/healthcare-apis/fhir/iot-fhir-portal-quickstart). This option is easy to get started and the Azure resources such as EventHub, Functions, Stream Analytics jobs, and AppInsights are all managed by the service. However, it doesn't yet have great support for developers to troubleshoot. For example, you can't examine the payload sent to the connector to figure out why it can't map the data.
   - [Deploy the Azure IoMT Connector standalone](https://github.com/microsoft/iomt-fhir/blob/master/docs/ARMInstallationManagedIdentity.md). This option is for you deploy the Azure resources consisting the connector with an Azure Resource Manager template. You have access to all the Azure resources for troubleshooting. For developers, we **recommend this option** at the time of this writing (May 2021). Once the connector is deployed,
     1. ensure the Managed Identity of deployed Azure Function is assigned `FHIR Data Contributor` role to the Azure FHIR that you deployed in the first step.
     1. load your device mapping template, for example, [devicecontent.json for HealthKit](sample/templates/healthkitOnFhir/devicecontent.json) and FHIR mapping template, for example, [fhirmapping.json for HealthKit](sample/templates/healthkitOnFhir/fhirmapping.json) to the `template` folder of the deployed Azure Blob Storage account. Note that they must be named `devicecontent.json` and `fhirmapping.json` by default, or, you need to update the names in the Azure Functions' app settings. More on data mappings in the next section below.
     1. Verify the deployment by sending some sample data that matches your data mapping definition to the EventHub deployed in this step. You can use VSCode or Azure Service Bus Explorer to send a json payload to EventHub. Depending on the length of the aggregation window set in the deployed Stream Analytics job, in a few minutes (check the Azure portal whether your Functions have run), you should be able to [query the data from Azure FHIR using Postman](https://docs.microsoft.com/en-us/azure/healthcare-apis/fhir/access-fhir-postman-tutorial).
     1. Another great tool to examine FHIR data is Power BI. From [Power BI Desktop](https://powerbi.microsoft.com/en-us/desktop/), [connect to FHIR](https://docs.microsoft.com/en-us/power-query/connectors/fhir/fhir) and you will see all the tables in FHIR. You can expand the columns of complex data types to see every data field. Note that even if you are the owner of the Azure FHIR service, you still need to grant yourself a minimum `FHIR Data Reader` role in Azure in order to read the data from Power BI.

### Ingest diabetes data to FHIR

FHIR defines [REST APIs](https://www.hl7.org/fhir/http.html#3.1.0) for ingesting data. You can always ingest data by issuing the REST API directly against Azure FHIR. However, for the FHIR resource [Observation](https://www.hl7.org/fhir/observation.html), which is a _a central element in healthcare used to support diagnosis, monitor progress, determine baselines and patterns and even capture demographic characteristics_, some level of aggregation or grouping on the high frequency raw time series measurement is required to ingest the right data. This is what the [Azure IoMT Connector](https://github.com/microsoft/iomt-fhir) is designed for.

[This IoMT Connector doc](https://github.com/microsoft/iomt-fhir/blob/master/docs/Configuration.md) explains how to map data from the raw format coming out a mobile app such as HealthKit to FHIR. It's important for a developer to understand that 2 step mapping is required, from device to a generic model as done below in the first Function, and from the generic model to FHIR, as done in the second Function in the following diagram. This understanding greatly helps troubleshooting.

![Alt Text](https://github.com/microsoft/iomt-fhir/blob/master/images/iomtfhirconnectorazurearchitecture.png?raw=true "IoMT Connector to FHIR")

In the case of diabetes, **glucose** measurement is an `Observation`, and it can be mapped [from device to a generic model as shown in this example](sample/templates/healthkitOnFhir/devicecontent.json#L61), and [from a generic model to FHIR in this example](sample/templates/healthkitOnFhir/fhirmapping.json#L61).

**Insulin** on the other hand, is not an `Observation`, but rather a FHIR resource called [MedicationAdministration](https://www.hl7.org/fhir/medicationadministration.html). Note that the Azure IoMT Connector for FHIR only supports `Observation`, `Patient`, and `Device` resources at the time of this writing (May 2021). So you need to make a REST API call against Azure FHIR service to ingest insulin data. You could also ingest additional insulin related data such as the type of insulin or the reason of insulin ingestion as supported by HealthKit. The following is a simple example to ingest insulin to Azure FHIR service (make sure to set the authorization header):

```json
POST https://<span></span>myfhirapi.azurehealthcareapis.com/MedicationAdministration
{
    "resourceType" : "MedicationAdministration",
    "status" : "completed",
    "medicationCodeableConcept" : {
        "text": "insulin"
    },
    "subject" : {
        "reference": "Patient/b98f5345-db32-4a74-9174-761ca9f0ad65"
    },
    "effectiveDateTime" : "2019-04-01T22:46:01.8750000Z",
    "performer" : [{
        "actor" : {
            "reference": "Patient/b98f5345-db32-4a74-9174-761ca9f0ad65"
        }
    }],
    "reasonCode" : [{
      "coding": [{
          "system": "http://snomed.info/sct",
          "code": "44054006",
          "display": "Diabetes mellitus type 2 (disorder)"
      }]
    }],
    "device" : {
        "reference": "Device/4d0725f3-bcca-46b0-9e81-33cb1cf8907c"
    },
    "dosage" : {
        "dose" : { "value": 1, "unit": "u"}
    }
}
```

### Troubleshooting tips

## As a patient, how do I send my data already logged in my diabetes device to my doctor so that I can get better care remotely

```

```
