___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "BigQuery Event",
  "brand": {
    "id": "github.com_taneli-salonen1",
    "displayName": "taneli-salonen1"
  },
  "categories": [
    "ANALYTICS",
    "DATA_WAREHOUSING"
  ],
  "description": "Send events to BigQuery using the Streaming Insert API. The table schema configuration can be found from the tag\u0027s GitHub page: https://github.com/taneli-salonen1/sgtm-bigquery-event-tag",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "bqProject",
    "displayName": "BigQuery Project Id",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "The id of the BigQuery project where the data is sent to.",
    "valueHint": "project id",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "bqDataset",
    "displayName": "BigQuery Dataset Id",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "The id of the BigQuery dataset where the data is sent to.",
    "valueHint": "dataset id",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "bqTable",
    "displayName": "BigQuery Table Id",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "The id of the BigQuery table where the data is sent to.",
    "valueHint": "table id",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "user_id",
    "displayName": "User Id",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "Writes the id in the \u003cstrong\u003euser_id\u003c/strong\u003e string field."
  },
  {
    "type": "TEXT",
    "name": "device_id",
    "displayName": "Device Id",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "Writes the id in the \u003cstrong\u003edevice_id\u003c/strong\u003e string field."
  },
  {
    "type": "TEXT",
    "name": "session_id",
    "displayName": "Session Id",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "Writes the id in the \u003cstrong\u003esession_id\u003c/strong\u003e string field."
  },
  {
    "type": "TEXT",
    "name": "eventName",
    "displayName": "Event Name",
    "simpleValueType": true,
    "alwaysInSummary": true
  },
  {
    "type": "SIMPLE_TABLE",
    "name": "eventDataFields",
    "displayName": "Event parameters",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Key",
        "name": "key",
        "type": "TEXT",
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ],
        "valueHint": "key name"
      },
      {
        "defaultValue": "",
        "displayName": "Value",
        "name": "value",
        "type": "TEXT",
        "valueHint": "key value",
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ]
      }
    ],
    "help": "Set the key name and key value for each event data field. Object data types will be converted to string.",
    "alwaysInSummary": true,
    "newRowButtonText": "New parameter"
  },
  {
    "type": "LABEL",
    "name": "bqSchemaLink",
    "displayName": "The required BigQuery table schema can be found from: https://github.com/taneli-salonen1/sgtm-bigquery-event-tag/blob/main/schema.txt"
  }
]


___SANDBOXED_JS_FOR_SERVER___

const log = require('logToConsole');
const BigQuery = require('BigQuery');
const makeInteger = require('makeInteger');
const makeString = require('makeString');
const JSON = require('JSON');
const getTimestampMillis = require('getTimestampMillis');
const getType = require('getType');

const identifyDataType = (fieldValue) => {
  const fieldType = typeof fieldValue;
  
  if (fieldType === 'string') {
    return 'string_value';
  } else if (fieldType === 'number') {
    return makeInteger(fieldValue) === fieldValue ? 'int_value' : 'float_value';
  } else if (fieldType === 'object') {
    return 'string_value';
  } else if (fieldType === 'boolean') {
    // save boolean values as integers
    return 'int_value';
  }
};

const changeDataType = (fieldValue) => {
  // convert objects to a string
  if (typeof fieldValue === 'object' && fieldValue !== null) {
    return JSON.stringify(fieldValue);
  } else if (typeof fieldValue === 'boolean') {
    // convert booleans to integer
    return fieldValue ? 1 : 0;
  }
  return fieldValue;
};

// convert identifiers to strings
const convertToString = (fieldValue) => {
  if (getType(fieldValue) === 'null' || getType(fieldValue) === 'undefined') {
    return;
  }
  return makeString(fieldValue);
};

const row = {
  timestamp: getTimestampMillis(),
  event_name: data.eventName,
  user_id: convertToString(data.user_id),
  device_id: convertToString(data.device_id),
  session_id: convertToString(data.session_id),
  event_params: []
};


// Transform the event data fields to the BigQuery event schema
if (data.eventDataFields && data.eventDataFields.length > 0) {
  data.eventDataFields.forEach(field => {
    const val = {
      key: field.key,
      value: {
      }
    };

    val.value[identifyDataType(field.value)] = changeDataType(field.value);

    row.event_params.push(val);
  });
}

const connectionInfo = {
  projectId: data.bqProject,
  datasetId: data.bqDataset,
  tableId: data.bqTable
};

const options = {
  ignoreUnknownValues: true
};

BigQuery.insert(connectionInfo, [row], options, data.gtmOnSuccess(), data.gtmOnFailure());


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_bigquery",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedTables",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "projectId"
                  },
                  {
                    "type": 1,
                    "string": "datasetId"
                  },
                  {
                    "type": 1,
                    "string": "tableId"
                  },
                  {
                    "type": 1,
                    "string": "operation"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Untitled test 2
  code: |-
    const mockData = {
      bqProject: 'asdf',
      bqDataset: 'asdf',
      bqTable: 'test',
      eventDataFields:[
        {"key":"page_location","value":"test"},
        {"key":"session_id","value":12345}
      ]
    };

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
setup: |-
  const log = require('logToConsole');
  const makeInteger = require('makeInteger');
  const JSON = require('JSON');


  const testEventData = {"x-ga-protocol_version":"2","x-ga-measurement_id":"G-FBVKWPGDPE","x-ga-gtm_version":"2re540","x-ga-page_id":1940542384,"x-ga-system_properties":{"z":"ccd.tbB","eu":"Q"},"x-ga-mp2-tt":"internal_cookie","client_id":"ZDoa3Sn32zo3RN66kguVogdtbQB1xZr/EBDR9gylXKA=.1647778941","language":"en","screen_resolution":"1536x960","x-ga-mp2-ir":"1","x-ga-request_count":1,"ga_session_id":"1652075867","ga_session_number":18,"x-ga-mp2-seg":"1","page_location":"https://tanelytics.com/ip-filtering-in-server-side-gtm/","page_referrer":"https://tanelytics.com/?internalTraffic=1","page_title":"IP Filtering in Server-side Tag Manager - tanelytics.com","event_name":"page_view","engagement_time_msec":1,"page_type":"post","page_post_id":237.1,"page_post_date":"2022-05-05","page_post_category":"ga4,server-side-tag-manager","page_post_tags1":"ga4,server-side-gtm","page_type2":"single-post","custom_timestamp":1652077511712,"x-ga-mp2-user_properties":{"_npa":"1"},"x-ga-mp2-richsstsse":"","ip_override":"80.221.59.110","user_agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.54 Safari/537.36","x-ga-js_client_id":"2024456455.1647778941"};

  mock('getAllEventData', () => {
    return testEventData;
  });


___NOTES___

Created on 5/9/2022, 2:44:23 PM


