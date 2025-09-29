___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Client ID \u0026 Session Information from Google Analytics by JabJab",
  "description": "Return storage information of Google Analytics on a webpage. Template can return either client_id, session_id, session_number or measurement_id or all of this information in an object.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "returnDataGroup",
    "displayName": "Which data?",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "all",
        "displayValue": "All Google Analytics storage data listed bellow"
      },
      {
        "value": "client_id",
        "displayValue": "Client ID only"
      },
      {
        "value": "session_id",
        "displayValue": "Session ID only"
      },
      {
        "value": "session_number",
        "displayValue": "Session Number only"
      },
      {
        "value": "measurement_id",
        "displayValue": "Measurement ID only"
      }
    ],
    "simpleValueType": true,
    "alwaysInSummary": true,
    "defaultValue": "all",
    "help": "Select which data to return by the variable template. Selecting all will return a JavaScript object with all values. Selecting a single option will return only that data as a string value."
  },
  {
    "type": "RADIO",
    "name": "multipleGA",
    "displayName": "Multiple Google Analytics sessions",
    "radioItems": [
      {
        "value": "all",
        "displayValue": "Return all sessions"
      },
      {
        "value": "index",
        "displayValue": "Filter to specific index",
        "subParams": [
          {
            "type": "TEXT",
            "name": "multipleGAIndex",
            "displayName": "Session Index",
            "simpleValueType": true,
            "valueValidators": [
              {
                "type": "NON_NEGATIVE_NUMBER"
              },
              {
                "type": "NON_EMPTY"
              }
            ],
            "valueHint": "0"
          }
        ]
      },
      {
        "value": "mpid",
        "displayValue": "Filter to specific Measurement ID",
        "subParams": [
          {
            "type": "TEXT",
            "name": "multipleGAMPID",
            "displayName": "Measurement ID",
            "simpleValueType": true,
            "valueValidators": [
              {
                "type": "REGEX",
                "args": [
                  "G\\-[A-Z0-9]+"
                ]
              },
              {
                "type": "NON_EMPTY"
              }
            ],
            "valueHint": "G-ABCD1234"
          }
        ]
      }
    ],
    "simpleValueType": true,
    "defaultValue": "all",
    "help": "Select how to return data when multiple Google Analytics sessions are running on a webpage (for example 2 or more G-XXXXXX destinations)",
    "enablingConditions": [
      {
        "paramName": "returnDataGroup",
        "paramValue": "client_id",
        "type": "NOT_EQUALS"
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "advancedOptions",
    "displayName": "Advanced Options",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "TEXT",
        "name": "cookiePrefix",
        "displayName": "Cookie Prefix",
        "simpleValueType": true,
        "valueValidators": [
          {
            "type": "REGEX",
            "args": [
              "^[A-Za-z0-9_\\-]*$"
            ]
          }
        ]
      },
      {
        "type": "TEXT",
        "name": "cookieDomain",
        "displayName": "Cookie Domain",
        "simpleValueType": true,
        "valueValidators": [
          {
            "type": "REGEX",
            "args": [
              "^\\.?(?:[A-Za-z0-9-]+\\.)+[A-Za-z]{2,63}$"
            ]
          }
        ]
      },
      {
        "type": "TEXT",
        "name": "cookiePath",
        "displayName": "Cookie Path",
        "simpleValueType": true,
        "valueValidators": [
          {
            "type": "REGEX",
            "args": [
              "^\\/(?:[A-Za-z0-9\\-._~%!$\u0026\u0027()*+,;\u003d:@/]*)$"
            ]
          }
        ]
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const log = require('logToConsole');
const readAnalyticsStorage = require('readAnalyticsStorage');

const returnDataGroup = data.returnDataGroup || "all";
const multipleGA = data.multipleGA || "all";
const multipleGAIndex = data.multipleGAIndex || 0;
const multipleGAMPID = data.multipleGAMPID || '';
const cookie_prefix = data.cookie_prefix || "";
const cookie_domain = data.cookie_domain || "";
const cookie_path = data.cookie_path || "";

const hasCookieOptions = [cookie_prefix, cookie_domain, cookie_path].some(v => v);

const cookieOptions = hasCookieOptions ? {
    'cookie_prefix': cookie_prefix,
    'cookie_domain': cookie_domain,
    'cookie_path': cookie_path,
  } : undefined;

const gaData = readAnalyticsStorage(cookieOptions);

if (!gaData) return false;

if (returnDataGroup === 'all') {
  let filteredSessions;

  switch (multipleGA) {
    case 'all':
      return gaData;

    case 'index':
      filteredSessions = gaData.sessions[multipleGAIndex] ? [gaData.sessions[multipleGAIndex]] : [];
      break;

    case 'mpid':
      filteredSessions = gaData.sessions.filter(
        session => session.measurement_id === multipleGAMPID
      );
      break;

    default:
      filteredSessions = [];
  }

  const returnGAData = {
    client_id: gaData.client_id,
    sessions: filteredSessions,
  };

  return returnGAData;

} else if (returnDataGroup === "client_id") {
  return gaData.client_id;

} else {
  let filteredSessions;

  switch (multipleGA) {
    case 'all':
      return gaData.sessions.map(session => session[returnDataGroup]);

    case 'index':
      return gaData.sessions[multipleGAIndex] ? gaData.sessions[multipleGAIndex][returnDataGroup] : undefined;

    case 'mpid':
      filteredSessions = gaData.sessions.filter(
        session => session.measurement_id === multipleGAMPID
      ).map(session => session[returnDataGroup]);
      
      if (filteredSessions.length === 0) {
        return undefined;
      } else if (filteredSessions.length === 1) {
        return filteredSessions[0];
      } else {
        return filteredSessions;
      }
  }
}

// Handle other cases explicitly if needed.

return false;


___WEB_PERMISSIONS___

[
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
  },
  {
    "instance": {
      "key": {
        "publicId": "read_analytics_storage",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Return all data
  code: |-
    const mockData = {"returnDataGroup":"all","multipleGA":"all"};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo(test_api_result);
- name: Return all data for specific existing index
  code: |-
    const returnIndex = 1;
    const mockData = {"returnDataGroup":"all","multipleGA":"index","multipleGAIndex":returnIndex};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo({
      "client_id": test_api_result.client_id,
      "sessions": [test_api_result.sessions[returnIndex]]
    });
- name: Return all data for specific non-existing index
  code: |-
    const returnIndex = 2;
    const mockData = {"returnDataGroup":"all","multipleGA":"index","multipleGAIndex":returnIndex};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo({
      "client_id":"12345678.87654321",
      "sessions":[]
    });
- name: Return all data for specific existing GA ID
  code: |-
    const returnGAID = "G-ABCD1234";
    const mockData = {"returnDataGroup":"all","multipleGA":"mpid","multipleGAMPID":returnGAID};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo({
      "client_id": test_api_result.client_id,
      "sessions": test_api_result.sessions.filter(session => session.measurement_id === returnGAID)
    });
- name: Return all data for specific non-existing GA ID
  code: |-
    const returnGAID = "G-XXXXXXXX";
    const mockData = {"returnDataGroup":"all","multipleGA":"mpid","multipleGAMPID":returnGAID};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo({
      "client_id": test_api_result.client_id,
      "sessions": []
    });
- name: Return Client ID only
  code: |-
    const mockData = {"returnDataGroup":"client_id"};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo(test_api_result.client_id);
- name: Return Session ID only for all sessions
  code: |-
    const mockData = {"returnDataGroup":"session_id","multipleGA":"all"};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo(test_api_result.sessions.map(session => session.session_id));
- name: Return Session ID only for existing index
  code: |-
    const returnIndex = 1;
    const mockData = {"returnDataGroup":"session_id","multipleGA":"index", "multipleGAIndex": returnIndex};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo(test_api_result.sessions[returnIndex].session_id);
- name: Return Session ID only for non-existing index
  code: |-
    const returnIndex = 2;
    const mockData = {"returnDataGroup":"session_id","multipleGA":"index", "multipleGAIndex": returnIndex};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isUndefined();
- name: Return Session ID only for existing GA ID
  code: |-
    const returnGAID = "G-ABCD1234";
    const mockData = {"returnDataGroup":"session_id","multipleGA":"mpid","multipleGAMPID":returnGAID};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo(test_api_result.sessions.filter(session => session.measurement_id === returnGAID)[0].session_id);
- name: Return Session ID only for non-existing GA ID
  code: |-
    const returnGAID = "G-XXXXXXX";
    const mockData = {"returnDataGroup":"session_id","multipleGA":"mpid","multipleGAMPID":returnGAID};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isUndefined();
- name: Return Session Number only for all sessions
  code: |-
    const mockData = {"returnDataGroup":"session_number","multipleGA":"all"};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo(test_api_result.sessions.map(session => session.session_number));
- name: Return Session Number only for existing index
  code: |-
    const returnIndex = 1;
    const mockData = {"returnDataGroup":"session_number","multipleGA":"index", "multipleGAIndex": returnIndex};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo(test_api_result.sessions[returnIndex].session_number);
- name: Return Session Number only for non-existing index
  code: |-
    const returnIndex = 2;
    const mockData = {"returnDataGroup":"session_number","multipleGA":"index", "multipleGAIndex": returnIndex};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isUndefined();
- name: Return Session Number only for existing GA ID
  code: |-
    const returnGAID = "G-ABCD1234";
    const mockData = {"returnDataGroup":"session_number","multipleGA":"mpid","multipleGAMPID":returnGAID};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo(test_api_result.sessions.filter(session => session.measurement_id === returnGAID)[0].session_number);
- name: Return Session Number only for non-existing GA ID
  code: |-
    const returnGAID = "G-XXXXXXX";
    const mockData = {"returnDataGroup":"session_number","multipleGA":"mpid","multipleGAMPID":returnGAID};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isUndefined();
- name: Return Measurement ID only for all sessions
  code: |-
    const mockData = {"returnDataGroup":"measurement_id","multipleGA":"all"};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo(test_api_result.sessions.map(session => session.measurement_id));
- name: Return Measurement ID only for existing index
  code: |-
    const returnIndex = 1;
    const mockData = {"returnDataGroup":"measurement_id","multipleGA":"index", "multipleGAIndex": returnIndex};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo(test_api_result.sessions[returnIndex].measurement_id);
- name: Return Measurement ID only for non-existing index
  code: |-
    const returnIndex = 2;
    const mockData = {"returnDataGroup":"measurement_id","multipleGA":"index", "multipleGAIndex": returnIndex};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isUndefined();
- name: Return Measurement ID only for existing GA ID
  code: |-
    const returnGAID = "G-ABCD1234";
    const mockData = {"returnDataGroup":"measurement_id","multipleGA":"mpid","multipleGAMPID":returnGAID};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo(test_api_result.sessions.filter(session => session.measurement_id === returnGAID)[0].measurement_id);
- name: Return Measurement ID only for non-existing GA ID
  code: |-
    const returnGAID = "G-XXXXXXX";
    const mockData = {"returnDataGroup":"measurement_id","multipleGA":"mpid","multipleGAMPID":returnGAID};

    let variableResult = runCode(mockData);

    assertThat(variableResult).isUndefined();
setup: |-
  const test_api_result = {
    "client_id": "12345678.87654321",
    "sessions": [{
      "measurement_id": "G-ABCD1234",
      "session_id": "session_id_1",
      "session_number": "1"
    },{
      "measurement_id": "G-EFGH5678",
      "session_id": "session_id_2",
      "session_number": "2"
    }]
  };

  mock("readAnalyticsStorage", test_api_result);


___NOTES___

Created on 9/29/2025, 8:49:11 AM
