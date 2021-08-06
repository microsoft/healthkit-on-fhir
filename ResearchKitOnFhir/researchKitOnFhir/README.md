#  ResearchKit-on-Fhir

ResearchKitOnFhir is an iOS template app that integrates Apple ResearchKit with FHIR by:
1. Automating the import of [FHIR Questionnaires](https://www.hl7.org/fhir/questionnaire.html#resource) from a FHIR Server and their conversion to corresponding ResearchKit UI modules
2. Automating the conversion of ResearchKit Survey responses to [FHIR QuestionnaireResponses](https://www.hl7.org/fhir/questionnaireresponse.html#resource) and their export to a FHIR Server


## Supported Types
ResearchKitOnFhir currently supports conversion between the following [ResearchKit UI formats](http://researchkit.org/docs/docs/Survey/CreatingSurveys.html) and [FHIR types](https://www.hl7.org/fhir/valueset-item-type.html#expansion):

| FHIR Type        | ResearchKit Format                                                                     | Notes                                                                                                                                                               |
|------------------|-------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| text                  | ORKTextAnswerFormat                                                                | enforce maximum response length through .maxLength  field in FHIR                                                          |
| string               | ORKTextAnswerFormat                                                                |                                                                                                                                                                          |
| boolean           | ORKBooleanAnswerFormat                                                          | .booleanAnswerFormat                                                                                                                                   |
| integer             | ORKNumericAnswerFormat                                                         | for integer: .integerAnswerFormat                                                                                                                   |
| decimal            | ORKNumericAnswerFormat                                                         | decimal: .decimalAnswerFormat                                                                                                                     |
| choice              | ORKTextChoiceAnswerFormat, ORKValuePickerAnswerFormat | **Only supports one answer chosen per question. Set answer choice list  through .answerOption in FHIR |
| time                  | ORKTimeOfDayAnswerFormat                                                     |                                                                                                                                                                         |
| date                  | ORKDateAnswerFormat                                                               | style: ORKDateAnswerStyle.date                                                                                                                   |
| dateTime          | ORKDateAnswerFormat                                                               | style: ORKDateAnswerStyle.dateAndTime                                                                                                     |

**Threshold of 10 arbitrarily set in func MultipleChoiceFormat in FhirToResearchKit.swift: if all responses are shorter than 10 characters, Value Picker format is displayed. Otherwise, TextChoice format is displayed.


## Authentication and Configuration
ResearchKitOnFhir uses [SMART on FHIR](https://docs.smarthealthit.org) to integrate the app with a FHIR Server. Current implementation supports configuration through the Config.json file, which the user populates with their FHIR Server URL, SMART Client ID, and Patient ID (the FHIR id of the [Patient Resource](https://www.hl7.org/fhir/patient.html#resource) representing the intended app user). For example, a Patient who is accessed in the FHIR Server through the URI "Patient/samplePatientName" will require a Config.json file with:

```json
"patientId": "samplePatientName"
```
Implementation is still needed to handle authentication token timeout (see TODO in AppDelegate.swift).


## Building Questionnaires

Each [FHIR Questionnaire](https://www.hl7.org/fhir/questionnaire.html#resource) must be associated with a [FHIR® Task](https://www.hl7.org/fhir/task.html#resource), which is linked to the [FHIR Patient](https://www.hl7.org/fhir/patient.html#resource) assigned to it through the "owner" field, and linked to the Questionnaire it assigns through the "basedOn" field. The Patient will only be asked to complete those questionnaires that are linked to a Task without status set to "completed". 

When the user completes a Survey through the app, a [FHIR QuestionnaireResponse](https://www.hl7.org/fhir/questionnaireresponse.html#resource) will be created and linked to the corresponding Questionnaire through the "questionnaire" field. Each questionnaire response (if not nil) of the QuestionnaireResponse will be linked to its corresponding question in the corresponding Questionnaire through the "linkId" field in both resources. 

Below is a set of sample FHIR Resources that have all fields required to facilitate the functionality of the app:

### Sample Task:
```json
{ 
    "resourceType": "Task", 
    "id": "sampleTask1", 
    "meta": { 
        "versionId": "16", 
        "lastUpdated": "2021-07-29T21:12:34.881+00:00" 
    }, 
    "basedOn": [ 
        { 
            "reference": "Questionnaire/bloodSugar" 
        } 
    ], 
    "status": "requested", 
    "intent": "order", 
    "owner": { 
        "reference": "Patient/samplePatientName" 
    } 
} 
```

### Corresponding Questionnaire:
```json
{ 
    "resourceType": "Questionnaire", 
    "id": "bloodSugar", 
    "meta": { 
        "versionId": "2", 
        "lastUpdated": "2021-07-29T18:09:43.914+00:00" 
    }, 
    "title": "Checking Your Blood Sugar Levels", 
    "status": "active", 
    "item": [ 
        { 
            "linkId": "1", 
            "type": "group", 
            "item": [ 
                { 
                    "linkId": "1.1", 
                    "text": "How many times a day do you take your short-acting Insulin?", 
                    "type": "choice", 
                    "answerOption": [ 
                        { 
                            "valueString": "0-1" 
                        }, 
                        { 
                            "valueString": "2-4" 
                        }, 
                        { 
                            "valueString": "Over 4" 
                        } 
                    ] 
                }, 
                { 
                    "linkId": "1.2", 
                    "text": "Do you take long-acting Insulin?", 
                    "type": "boolean" 
                }, 
                { 
                    "linkId": "1.3", 
                    "text": "How do you feel you are doing in your monitoring and maintenance of your blood sugar levels?", 
                    "type": "text" 
                } 
            ] 
        }, 
        { 
            "linkId": "2", 
            "type": "group", 
            "item": [ 
                { 
                    "linkId": "2.1", 
                    "text": "What time did you check your AM blood sugar reading today?", 
                    "type": "time" 
                }, 
                { 
                    "linkId": "2.2", 
                    "text": "What was your most recent blood sugar reading?", 
                    "type": "decimal" 
                }, 
                { 
                    "linkId": "2.3", 
                    "text": "When you check your blood sugar at night, what time do you check?", 
                    "type": "choice", 
                    "answerOption": [ 
                        { 
                            "valueString": "I check my blood sugar as part of my bedtime routine; roughly 30 minutes before bed." 
                        }, 
                        { 
                            "valueString": "I check my blood sugar when I am in bed. Sometimes I forget and fall asleep." 
                        }, 
                        { 
                            "valueString": "I check my blood sugar well before bed, sometimes 1-2 hours before. Sometimes I may have a snack before I go to sleep." 
                        } 
                    ] 
                } 
            ] 
        } 
    ] 
} 
```

### Sample QuestionnaireResponse 
Generated by the app upon completion of above Questionnaire

```json
{ 
  "resourceType": "QuestionnaireResponse",
  "id": "7a382ed7-5390-4b45-9ab6-d33b85f1f625",
  "meta": {
         "versionId": "1",
         "lastUpdated": "2021-07-30T21:15:38.99+00:00"
      },
  "questionnaire": "Questionnaire/bloodSugar",
  "status": "completed",
  "item": [
           {
                "linkId": "1.1",
                "answer": [
                        {
                              "valueString": "0-1"
                        }
                    ]
           },
           {
                "linkId": "1.2",
                "answer": [
                      {
                         "valueBoolean": true
                      }
                   ]
           },
           {
                 "linkId": "1.3",
                 "answer": [
                      {
                          "valueString": "I’m feeling okay. I think I need more education."
                      }
                  ]
            },
            {
                  "linkId": "2.1",
                  "answer": [
                       {
                           "valueTime": "10:15:00"
                       }
                  ]
            },
            {
                   "linkId": "2.2",
                   "answer": [
                        {
                            "valueDecimal": 93
                        }
                   ]
            },
            {
                   "linkId": "2.3",
                   "answer": [
                         {
                            "valueString": "I check my blood sugar when I am in bed. Sometimes I forget and fall asleep."
                         }
                   ]
            }
       ]
} 
```

## Adding Additional Types

The addition of FHIR QuestionTypes and their conversion to and from ResearchKit UI formats requires additions to func researchKitQuestionResponseToFhir in ResearchKitToFhir.swift and func fhirQuestionListToResearchKitQuestions in FhirToResearchKit.swift.
