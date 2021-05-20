# Overview

People with diabetes need to monitor their blood sugar and take insulin regularly. There are a mirad of devices on the market for patients to monitor their blood sugar, for example, [OneTouch has a family of glucose meters](https://www.onetouch.com/products). This document explains how Azure FHIR can help both patients and healthcare providers to leverage these devices to improve the quality of care.

## As a developer, how do I collect data from consumer diabetes devices to Azure FHIR so that I can build an application for health care providers to remotely review/monitor patient data and provide care

### Archtecture

The following diagram shows how to integrate data from consumer diabetes devices to Azure FHIR:
![Alt text](Media/DiabetesDeviceToFHIR.png?raw=true "device_to_fhir")

Consumer diabetes devices may or may not have bluetooth connections to mobile phones. As mobile phones are ubiqutous, device vendors are also starting to offer mobile apps for their devices. The mobile app could sync the data from devices via bluetooth, or the user could manually input data to the mobile app.

From the mobile app, there are multiple options to send data to Azure FHIR.

1. If the vendor provides a programming interface to retrieve data either from the mobile app or from their cloud service (if the mobile app sends data to the cloud), then a developer could:

   - write an app using the vendor API to get the data
   - call the Azure FHIR API to ingest data to Azure FHIR, or send high frequency sample data to Azure IoMT Connector for FHIR which aggregates observation data to send to Azure FHIR

2. If the vendor integrates their mobile app with the Health app on iPhone, then a developer could:

   - write an app, such as the sample provided in this repo, for Apple HealthKit to ingest high frequency data to Azure IoMT Connector to Azure FHIR and low frequency data to Azure FHIR directly.

We recommend option #2, as illustrated in the above diagram, for the following reasons:

1. iPhone and Andriod phone dominates the mobile market and have very mature developer support for their HealthKit and Google Fit apps. As a developer, you only need to write one app for iPhone and one for Android to collect data from a variety of devices to send to Azure FHIR.
2. Device vendors are already integrating their mobile apps to HealthKit and Google Fit so their users can have a single pane of glass for health/fitness management.
3. TODO: Authentication and authorization are largely handled by the vendor app and HealthKit.

### Deploying Azure Resources

TODO: Call out the different options to deploy IoMT Connector and recommendation for developer.

### Map or ingest diabetes data

TODO: 1. Call out the difference between Observations and MedicationAdministered, and IoMT only supports Observations
TODO: 1. Add the IoMT diagram to illustrate the 2-step mapping that a developer has to do.

### Testing end-to-end

TODO:

## As a patient, how do I send my data already logged in my diabetes device to my doctor so that I can get better care remotely

TODO:
