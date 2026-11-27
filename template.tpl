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
  "displayName": "UCookie CMP",
  "categories": [
    "TAG_MANAGEMENT",
    "UTILITY"
  ],
  "brand": {
    "id": "brand_dummy",
    "displayName": "UCookie",
    "thumbnail": ""
  },
  "description": "Cookie consent banner (CMP) with Google Consent Mode v2. Sets the default consent state, restores the visitor's previous choice and loads the UCookie widget.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "LABEL",
    "name": "helpText",
    "displayName": "Fire this tag on the \"Consent Initialization - All Pages\" trigger. It sets the Consent Mode default (all denied except security_storage), restores the returning visitor's choice and loads the UCookie widget. Do not also paste the inline UCookie snippet."
  },
  {
    "type": "TEXT",
    "name": "scriptUrl",
    "displayName": "Widget script URL",
    "simpleValueType": true,
    "defaultValue": "https://fe.v2.ucookie.com.tr/ucookie.js",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      },
      {
        "type": "REGEX",
        "args": [
          "^https://([a-zA-Z0-9-]+\\.)*ucookie\\.com\\.tr/.+$"
        ],
        "errorMessage": "Must be an https URL on ucookie.com.tr."
      }
    ],
    "help": "The site is resolved from the page origin; no site id is needed. Only https URLs on ucookie.com.tr are allowed."
  },
  {
    "type": "TEXT",
    "name": "waitForUpdate",
    "displayName": "wait_for_update (ms)",
    "simpleValueType": true,
    "defaultValue": "500",
    "valueValidators": [
      {
        "type": "NON_NEGATIVE_NUMBER"
      }
    ],
    "help": "How long Google tags wait for a consent update before firing with the default state."
  },
  {
    "type": "CHECKBOX",
    "name": "adsDataRedaction",
    "checkboxText": "Redact ads data when ad_storage is denied (ads_data_redaction)",
    "simpleValueType": true,
    "defaultValue": true
  },
  {
    "type": "CHECKBOX",
    "name": "urlPassthrough",
    "checkboxText": "Pass through ad click information in URLs (url_passthrough)",
    "simpleValueType": true,
    "defaultValue": false
  },
  {
    "type": "GROUP",
    "name": "regionGroup",
    "displayName": "Region-specific default consent states (optional)",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "regionSettings",
        "displayName": "",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Regions (comma separated, e.g. US-CA,TR)",
            "name": "regions",
            "type": "TEXT",
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              }
            ]
          },
          {
            "defaultValue": "denied",
            "displayName": "ad_storage",
            "name": "ad_storage",
            "type": "SELECT",
            "selectItems": [
              {
                "value": "granted",
                "displayValue": "granted"
              },
              {
                "value": "denied",
                "displayValue": "denied"
              }
            ]
          },
          {
            "defaultValue": "denied",
            "displayName": "ad_user_data",
            "name": "ad_user_data",
            "type": "SELECT",
            "selectItems": [
              {
                "value": "granted",
                "displayValue": "granted"
              },
              {
                "value": "denied",
                "displayValue": "denied"
              }
            ]
          },
          {
            "defaultValue": "denied",
            "displayName": "ad_personalization",
            "name": "ad_personalization",
            "type": "SELECT",
            "selectItems": [
              {
                "value": "granted",
                "displayValue": "granted"
              },
              {
                "value": "denied",
                "displayValue": "denied"
              }
            ]
          },
          {
            "defaultValue": "denied",
            "displayName": "analytics_storage",
            "name": "analytics_storage",
            "type": "SELECT",
            "selectItems": [
              {
                "value": "granted",
                "displayValue": "granted"
              },
              {
                "value": "denied",
                "displayValue": "denied"
              }
            ]
          },
          {
            "defaultValue": "denied",
            "displayName": "functionality_storage",
            "name": "functionality_storage",
            "type": "SELECT",
            "selectItems": [
              {
                "value": "granted",
                "displayValue": "granted"
              },
              {
                "value": "denied",
                "displayValue": "denied"
              }
            ]
          },
          {
            "defaultValue": "denied",
            "displayName": "personalization_storage",
            "name": "personalization_storage",
            "type": "SELECT",
            "selectItems": [
              {
                "value": "granted",
                "displayValue": "granted"
              },
              {
                "value": "denied",
                "displayValue": "denied"
              }
            ]
          },
          {
            "defaultValue": "granted",
            "displayName": "security_storage",
            "name": "security_storage",
            "type": "SELECT",
            "selectItems": [
              {
                "value": "granted",
                "displayValue": "granted"
              },
              {
                "value": "denied",
                "displayValue": "denied"
              }
            ]
          }
        ],
        "newRowButtonText": "Add region"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const setDefaultConsentState = require('setDefaultConsentState');
const updateConsentState = require('updateConsentState');
const gtagSet = require('gtagSet');
const setInWindow = require('setInWindow');
const injectScript = require('injectScript');
const localStorage = require('localStorage');
const getTimestampMillis = require('getTimestampMillis');
const parseUrl = require('parseUrl');
const makeNumber = require('makeNumber');
const getType = require('getType');
const JSON = require('JSON');
const logToConsole = require('logToConsole');

// Google Consent Mode developer ID issued to the UCookie CMP; sent on every
// page via gtagSet('developer_id.<ID>', true).
const DEVELOPER_ID = 'dMmNlYm';

const STORAGE_KEY = 'ucookie';
const ALL_SIGNALS = [
  'ad_storage',
  'ad_user_data',
  'ad_personalization',
  'analytics_storage',
  'functionality_storage',
  'personalization_storage',
  'security_storage'
];
const TAG_TO_SIGNALS = {
  targeting: ['ad_storage', 'ad_user_data', 'ad_personalization'],
  tracking: ['analytics_storage'],
  functionality: ['functionality_storage', 'personalization_storage']
};

let finished = false;
const succeed = function() {
  if (finished) return;
  finished = true;
  data.gtmOnSuccess();
};
const fail = function() {
  if (finished) return;
  finished = true;
  data.gtmOnFailure();
};

// --- Script URL validation (https + ucookie.com.tr host) ------------------
const isAllowedUrl = function(url) {
  if (getType(url) !== 'string') return false;
  const parsed = parseUrl(url);
  if (!parsed || parsed.protocol !== 'https:') return false;
  const host = parsed.hostname;
  const root = 'ucookie.com.tr';
  if (host === root) return true;
  const suffix = '.' + root;
  return host.length > suffix.length &&
    host.indexOf(suffix) === host.length - suffix.length;
};

if (!isAllowedUrl(data.scriptUrl)) {
  logToConsole('UCookie: script URL must be https on ucookie.com.tr: ' + data.scriptUrl);
  fail();
} else {
  // --- Default consent state ---------------------------------------------
  const waitForUpdate = makeNumber(data.waitForUpdate);
  const globalDefault = {};
  ALL_SIGNALS.forEach(function(signal) {
    globalDefault[signal] = signal === 'security_storage' ? 'granted' : 'denied';
  });
  if (waitForUpdate >= 0) globalDefault.wait_for_update = waitForUpdate;
  setDefaultConsentState(globalDefault);

  // Region-specific defaults (more specific than the global one, so they win).
  (data.regionSettings || []).forEach(function(row) {
    const regions = (row.regions || '').split(',')
      .map(function(r) { return r.trim(); })
      .filter(function(r) { return r.length > 0; });
    if (regions.length === 0) return;
    const state = {};
    ALL_SIGNALS.forEach(function(signal) {
      state[signal] = row[signal] === 'granted' ? 'granted' : 'denied';
    });
    state.region = regions;
    if (waitForUpdate >= 0) state.wait_for_update = waitForUpdate;
    setDefaultConsentState(state);
  });

  // Global default always denies ad_storage, so redaction applies when enabled.
  gtagSet('ads_data_redaction', data.adsDataRedaction === true);
  gtagSet('url_passthrough', data.urlPassthrough === true);
  if (DEVELOPER_ID) {
    gtagSet('developer_id.' + DEVELOPER_ID, true);
  }

  // --- Returning visitor: restore the stored decision ---------------------
  const restoreConsent = function() {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return;
    const store = JSON.parse(raw);
    if (getType(store) !== 'object') return;
    if (getType(store.accepted) !== 'array' || getType(store.cats) !== 'array') return;
    if (getType(store.exp) === 'number' && store.exp < getTimestampMillis()) return;

    const accepted = {};
    store.accepted.forEach(function(id) { accepted['' + id] = true; });

    const update = {};
    ALL_SIGNALS.forEach(function(signal) {
      update[signal] = signal === 'security_storage' ? 'granted' : 'denied';
    });
    store.cats.forEach(function(cat) {
      if (getType(cat) !== 'object') return;
      if (cat.isRequired !== true && accepted['' + cat.id] !== true) return;
      const signals = TAG_TO_SIGNALS[cat.tag];
      if (!signals) return;
      signals.forEach(function(signal) { update[signal] = 'granted'; });
    });
    updateConsentState(update);
  };
  // Any storage/parse problem is ignored: the default state simply stays.
  if (getType(localStorage) !== 'undefined') {
    restoreConsent();
  }

  // --- Load the widget ----------------------------------------------------
  // Tells the widget the template owns the Consent Mode default.
  setInWindow('__ucookieGtm', true, true);
  injectScript(data.scriptUrl, succeed, fail, 'ucookie');
}


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_consent",
        "versionId": "1"
      },
      "param": [
        {
          "key": "consentTypes",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "ad_storage"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "ad_user_data"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "ad_personalization"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "analytics_storage"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "functionality_storage"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "personalization_storage"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "security_storage"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true}
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
        "publicId": "write_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {"type": 1, "string": "ads_data_redaction"},
              {"type": 1, "string": "url_passthrough"},
              {"type": 1, "string": "developer_id.*"}
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
        "publicId": "inject_script",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {"type": 1, "string": "https://fe.v2.ucookie.com.tr/*"},
              {"type": 1, "string": "https://*.ucookie.com.tr/*"}
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
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "key"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"},
                  {"type": 1, "string": "execute"}
                ],
                "mapValue": [
                  {"type": 1, "string": "__ucookieGtm"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": false}
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
        "publicId": "access_local_storage",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "key"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "ucookie"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": false}
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
- name: Default consent state is set with correct values
  code: |-
    mockData.scriptUrl = 'https://fe.v2.ucookie.com.tr/ucookie.js';
    mockData.waitForUpdate = '500';
    mock('injectScript', function(url, onSuccess, onFailure, token) { onSuccess(); });
    mock('localStorage', {getItem: function() { return null; }});
    runCode(mockData);
    assertApi('setDefaultConsentState').wasCalledWith({
      ad_storage: 'denied',
      ad_user_data: 'denied',
      ad_personalization: 'denied',
      analytics_storage: 'denied',
      functionality_storage: 'denied',
      personalization_storage: 'denied',
      security_storage: 'granted',
      wait_for_update: 500
    });
    assertApi('gtmOnSuccess').wasCalled();
- name: Region-specific default is set with the region list
  code: |-
    mockData.scriptUrl = 'https://fe.v2.ucookie.com.tr/ucookie.js';
    mockData.waitForUpdate = '500';
    mockData.regionSettings = [{
      regions: 'US-CA, TR',
      ad_storage: 'granted',
      ad_user_data: 'granted',
      ad_personalization: 'granted',
      analytics_storage: 'granted',
      functionality_storage: 'denied',
      personalization_storage: 'denied',
      security_storage: 'granted'
    }];
    mock('localStorage', {getItem: function() { return null; }});
    runCode(mockData);
    assertApi('setDefaultConsentState').wasCalledWith({
      ad_storage: 'granted',
      ad_user_data: 'granted',
      ad_personalization: 'granted',
      analytics_storage: 'granted',
      functionality_storage: 'denied',
      personalization_storage: 'denied',
      security_storage: 'granted',
      region: ['US-CA', 'TR'],
      wait_for_update: 500
    });
- name: ads_data_redaction and url_passthrough are set
  code: |-
    mockData.scriptUrl = 'https://fe.v2.ucookie.com.tr/ucookie.js';
    mockData.waitForUpdate = '500';
    mockData.adsDataRedaction = true;
    mockData.urlPassthrough = true;
    mock('localStorage', {getItem: function() { return null; }});
    runCode(mockData);
    assertApi('gtagSet').wasCalledWith('ads_data_redaction', true);
    assertApi('gtagSet').wasCalledWith('url_passthrough', true);
    assertApi('gtagSet').wasCalledWith('developer_id.dMmNlYm', true);
- name: ads_data_redaction is false when the box is unchecked
  code: |-
    mockData.scriptUrl = 'https://fe.v2.ucookie.com.tr/ucookie.js';
    mockData.waitForUpdate = '500';
    mockData.adsDataRedaction = false;
    mockData.urlPassthrough = false;
    mock('localStorage', {getItem: function() { return null; }});
    runCode(mockData);
    assertApi('gtagSet').wasCalledWith('ads_data_redaction', false);
    assertApi('gtagSet').wasCalledWith('url_passthrough', false);
- name: Returning visitor consent is restored via updateConsentState
  code: |-
    mockData.scriptUrl = 'https://fe.v2.ucookie.com.tr/ucookie.js';
    mockData.waitForUpdate = '500';
    mock('getTimestampMillis', 1000);
    mock('localStorage', {getItem: function() {
      return '{"accepted":["2"],"cats":[{"id":"1","tag":"","isRequired":true},{"id":"2","tag":"tracking","isRequired":false},{"id":"3","tag":"targeting","isRequired":false}],"exp":5000}';
    }});
    runCode(mockData);
    assertApi('updateConsentState').wasCalledWith({
      ad_storage: 'denied',
      ad_user_data: 'denied',
      ad_personalization: 'denied',
      analytics_storage: 'granted',
      functionality_storage: 'denied',
      personalization_storage: 'denied',
      security_storage: 'granted'
    });
- name: Invalid localStorage content is ignored
  code: |-
    mockData.scriptUrl = 'https://fe.v2.ucookie.com.tr/ucookie.js';
    mockData.waitForUpdate = '500';
    mock('getTimestampMillis', 1000);
    mock('injectScript', function(url, onSuccess, onFailure, token) { onSuccess(); });
    mock('localStorage', {getItem: function() { return 'not json {'; }});
    runCode(mockData);
    assertApi('updateConsentState').wasNotCalled();
    assertApi('gtmOnSuccess').wasCalled();
- name: Expired stored consent is ignored
  code: |-
    mockData.scriptUrl = 'https://fe.v2.ucookie.com.tr/ucookie.js';
    mockData.waitForUpdate = '500';
    mock('getTimestampMillis', 9000);
    mock('localStorage', {getItem: function() {
      return '{"accepted":["2"],"cats":[{"id":"2","tag":"tracking","isRequired":false}],"exp":5000}';
    }});
    runCode(mockData);
    assertApi('updateConsentState').wasNotCalled();
- name: Script is injected with the configured URL and flag is set
  code: |-
    mockData.scriptUrl = 'https://fe.v2.ucookie.com.tr/ucookie.js';
    mockData.waitForUpdate = '500';
    let injected = '';
    mock('injectScript', function(url, onSuccess, onFailure, token) {
      injected = url + '|' + token;
      onSuccess();
    });
    mock('localStorage', {getItem: function() { return null; }});
    runCode(mockData);
    assertApi('setInWindow').wasCalledWith('__ucookieGtm', true, true);
    assertThat(injected).isEqualTo('https://fe.v2.ucookie.com.tr/ucookie.js|ucookie');
    assertApi('gtmOnSuccess').wasCalled();
- name: Script URL on a foreign host is rejected
  code: |-
    mockData.scriptUrl = 'https://evil.example.com/ucookie.js';
    mockData.waitForUpdate = '500';
    runCode(mockData);
    assertApi('injectScript').wasNotCalled();
    assertApi('gtmOnFailure').wasCalled();

setup: |-
  const mockData = {
    scriptUrl: 'https://fe.v2.ucookie.com.tr/ucookie.js',
    waitForUpdate: '500',
    adsDataRedaction: true,
    urlPassthrough: false,
    regionSettings: []
  };


___NOTES___

Created for the UCookie CMP. The tag must fire on the "Consent Initialization - All Pages" trigger.
