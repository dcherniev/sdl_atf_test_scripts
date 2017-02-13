local commonSteps = require("user_modules/shared_testcases/commonSteps")
commonSteps:CheckSDLPath()
commonSteps:DeleteLogsFileAndPolicyTable()

local commonPreconditions = require("user_modules/shared_testcases/commonPreconditions")
commonPreconditions:BackupFile("sdl_preloaded_pt.json")
commonPreconditions:ReplaceFile("sdl_preloaded_pt.json", "./files/jsons/RC/rc_sdl_preloaded_pt.json")

local revsdl = require("user_modules/revsdl")

revsdl.AddUnknownFunctionIDs()
revsdl.SubscribeToRcInterface()
config.ValidateSchema = false
config.application1.registerAppInterfaceParams.appHMIType = { "REMOTE_CONTROL" }
config.application1.registerAppInterfaceParams.appID = "8675311"

Test = require('connecttest')
require('cardinalities')


--groups_PrimaryRC Group
local arrayGroups_PrimaryRC = revsdl.arrayGroups_PrimaryRC()


--======================================Requirement=========================================--
---------------------------------------------------------------------------------------------
-----------------Requirement: VehicleData subscriptions handling by RSDL --------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--


--=================================================BEGIN TEST CASES 4==========================================================--
  --Begin Test suit CommonRequestCheck.4 for Req.#4

  --Description: 4. In case HMI sends OnInteriorVehicleData (<moduleZone_value>, <moduleType_value>), RSDL must transfer this notification to the application(s) that is(are) currently subscribed to this <moduleType_value> in this <moduleZone_value> (see req.#1).


  --Begin Test case CommonRequestCheck.4.1
  --Description:  PASSENGER's Device: In case HMI sends OnInteriorVehicleData (<moduleZone_value>, <moduleType_value>), RSDL must transfer this notification to the application(s) that is(are) currently subscribed to this <moduleType_value> in this <moduleZone_value> (see req.#1).

    --Requirement/Diagrams id in jira:
        --Requirement
        --TC: Requirement, Requirement

    --Verification criteria:
        --RSDL subscribes the RC-app to interiorVehicleData notifications right after getting "subscribe:true" from the app

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.4.1.1
      --Description: --1. Application sends GetInteriorVehicleData as Zone = Driver and ModuleType = CLIMATE
               --2. HMI sends OnInteriorVehicleData notification to RSDL (different moduleType)
        function Test:Subscription_PassengerDriverCLIMATE()
          --mobile sends request for precondition as Driver
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "CLIMATE",
              moduleZone =
              {
                colspan = 2,
                row = 0,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RC.GetInteriorVehicleData request
          EXPECT_HMICALL("RC.GetInteriorVehicleData")
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleData response
              self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
                moduleData =
                {
                  moduleType = "CLIMATE",
                  moduleZone =
                  {
                    colspan = 2,
                    row = 0,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  },
                  climateControlData =
                  {
                    fanSpeed = 50,
                    circulateAirEnable = true,
                    dualModeEnable = true,
                    currentTemp = 30,
                    defrostZone = "FRONT",
                    acEnable = true,
                    desiredTemp = 24,
                    autoModeEnable = true,
                    temperatureUnit = "CELSIUS"
                  }
                }
              })

              --hmi side: HMI sends OnInteriorVehicleData notification to RSDL
              self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
                moduleData = {
                  moduleType = "RADIO",
                  moduleZone = {
                    col = 0,
                    colspan = 2,
                    level = 0,
                    levelspan = 1,
                    row = 0,
                    rowspan = 2
                  },
                  radioControlData = {
                    frequencyInteger = 99,
                    frequencyFraction = 3,
                    band = "AM",
                    rdsData = {
                      PS = "name",
                      RT = "radio",
                      CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                      PI = "Sign",
                      PTY = 1,
                      TP = true,
                      TA = true,
                      REG = "Murica"
                    },
                    availableHDs = 3,
                    hdChannel = 1,
                    signalStrength = 50,
                    signalChangeThreshold = 60,
                    radioEnable = true,
                    state = "ACQUIRING"
                  }
                }
              })

            end)



          --mobile side: expect SUCCESS response with info
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

          --mobile side: RSDL sends notifications to mobile app
          EXPECT_NOTIFICATION("OnInteriorVehicleData")
          :Times(0)

        end
      --End Test case CommonRequestCheck.4.1.1

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.4.1.2
      --Description: --1. Application sends GetInteriorVehicleData as Zone = Front Passenger and ModuleType = CLIMATE
               --2. HMI sends OnInteriorVehicleData notification to RSDL (different moduleType)
        function Test:Subscription_PassengerFrontCLIMATE()
          --mobile sends request for precondition as Driver
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "CLIMATE",
              moduleZone =
              {
                colspan = 2,
                row = 0,
                rowspan = 2,
                col = 1,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RC.GetInteriorVehicleData request
          EXPECT_HMICALL("RC.GetInteriorVehicleData")
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleData response
              self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
                moduleData =
                {
                  moduleType = "CLIMATE",
                  moduleZone =
                  {
                    colspan = 2,
                    row = 0,
                    rowspan = 2,
                    col = 1,
                    levelspan = 1,
                    level = 0
                  },
                  climateControlData =
                  {
                    fanSpeed = 50,
                    circulateAirEnable = true,
                    dualModeEnable = true,
                    currentTemp = 30,
                    defrostZone = "FRONT",
                    acEnable = true,
                    desiredTemp = 24,
                    autoModeEnable = true,
                    temperatureUnit = "CELSIUS"
                  }
                }
              })

              --hmi side: HMI sends OnInteriorVehicleData notification to RSDL
              self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
                moduleData = {
                  moduleType = "RADIO",
                  moduleZone = {
                    col = 1,
                    colspan = 2,
                    level = 0,
                    levelspan = 1,
                    row = 0,
                    rowspan = 2
                  },
                  radioControlData = {
                    frequencyInteger = 99,
                    frequencyFraction = 3,
                    band = "AM",
                    rdsData = {
                      PS = "name",
                      RT = "radio",
                      CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                      PI = "Sign",
                      PTY = 1,
                      TP = true,
                      TA = true,
                      REG = "Murica"
                    },
                    availableHDs = 3,
                    hdChannel = 1,
                    signalStrength = 50,
                    signalChangeThreshold = 60,
                    radioEnable = true,
                    state = "ACQUIRING"
                  }
                }
              })

            end)



          --mobile side: expect SUCCESS response with info
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

          --mobile side: RSDL sends notifications to mobile app
          EXPECT_NOTIFICATION("OnInteriorVehicleData")
          :Times(0)

        end
      --End Test case CommonRequestCheck.4.1.2

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.4.1.3
      --Description: --1. Application sends GetInteriorVehicleData as Zone = Left Rare Passenger and ModuleType = CLIMATE
               --2. HMI sends OnInteriorVehicleData notification to RSDL (different moduleType)
        function Test:Subscription_PassengerLeftCLIMATE()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "CLIMATE",
              moduleZone =
              {
                colspan = 2,
                row = 1,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "CLIMATE",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})

              --hmi side: expect RC.GetInteriorVehicleData request
              EXPECT_HMICALL("RC.GetInteriorVehicleData")
              :Do(function(_,data1)
                  --hmi side: sending RC.GetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data1.id, data1.method, "SUCCESS", { isSubscribed = true,
                    moduleData =
                    {
                      moduleType = "CLIMATE",
                      moduleZone =
                      {
                        colspan = 2,
                        row = 1,
                        rowspan = 2,
                        col = 0,
                        levelspan = 1,
                        level = 0
                      },
                      climateControlData =
                      {
                        fanSpeed = 50,
                        circulateAirEnable = true,
                        dualModeEnable = true,
                        currentTemp = 30,
                        defrostZone = "FRONT",
                        acEnable = true,
                        desiredTemp = 24,
                        autoModeEnable = true,
                        temperatureUnit = "CELSIUS"
                      }
                    }
                  })

                  --hmi side: HMI sends OnInteriorVehicleData notification to RSDL
                  self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
                    moduleData = {
                      moduleType = "RADIO",
                      moduleZone = {
                        col = 0,
                        colspan = 2,
                        level = 0,
                        levelspan = 1,
                        row = 1,
                        rowspan = 2
                      },
                      radioControlData = {
                        frequencyInteger = 99,
                        frequencyFraction = 3,
                        band = "AM",
                        rdsData = {
                          PS = "name",
                          RT = "radio",
                          CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                          PI = "Sign",
                          PTY = 1,
                          TP = true,
                          TA = true,
                          REG = "Murica"
                        },
                        availableHDs = 3,
                        hdChannel = 1,
                        signalStrength = 50,
                        signalChangeThreshold = 60,
                        radioEnable = true,
                        state = "ACQUIRING"
                      }
                    }
                  })
              end)
          end)



          --mobile side: expect SUCCESS response with info
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

          --mobile side: RSDL sends notifications to mobile app
          EXPECT_NOTIFICATION("OnInteriorVehicleData")
          :Times(0)

        end
      --End Test case CommonRequestCheck.4.1.3

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.4.1.4
      --Description: --1. Application sends GetInteriorVehicleData as Zone = Driver and ModuleType = RADIO
               --2. HMI sends OnInteriorVehicleData notification to RSDL (different zone)
        function Test:Subscription_PassengerDriverRADIO()
          --mobile sends request for precondition as Driver
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "RADIO",
              moduleZone =
              {
                colspan = 2,
                row = 0,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RC.GetInteriorVehicleData request
          EXPECT_HMICALL("RC.GetInteriorVehicleData")
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleData response
              self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
                moduleData = {
                  moduleType = "RADIO",
                  moduleZone = {
                    col = 0,
                    colspan = 2,
                    level = 0,
                    levelspan = 1,
                    row = 0,
                    rowspan = 2
                  },
                  radioControlData = {
                    frequencyInteger = 99,
                    frequencyFraction = 3,
                    band = "FM",
                    rdsData = {
                      PS = "name",
                      RT = "radio",
                      CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                      PI = "Sign",
                      PTY = 1,
                      TP = true,
                      TA = true,
                      REG = "Murica"
                    },
                    availableHDs = 3,
                    hdChannel = 1,
                    signalStrength = 50,
                    signalChangeThreshold = 60,
                    radioEnable = true,
                    state = "ACQUIRING"
                  }
                }
              })

              --hmi side: HMI sends OnInteriorVehicleData notification to RSDL
              self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
                moduleData = {
                  moduleType = "RADIO",
                  moduleZone = {
                    col = 1,
                    colspan = 2,
                    level = 0,
                    levelspan = 1,
                    row = 1,
                    rowspan = 2
                  },
                  radioControlData = {
                    frequencyInteger = 99,
                    frequencyFraction = 3,
                    band = "AM",
                    rdsData = {
                      PS = "name",
                      RT = "radio",
                      CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                      PI = "Sign",
                      PTY = 1,
                      TP = true,
                      TA = true,
                      REG = "Murica"
                    },
                    availableHDs = 3,
                    hdChannel = 1,
                    signalStrength = 50,
                    signalChangeThreshold = 60,
                    radioEnable = true,
                    state = "ACQUIRING"
                  }
                }
              })

            end)



          --mobile side: expect SUCCESS response with info
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

          --mobile side: RSDL sends notifications to mobile app
          EXPECT_NOTIFICATION("OnInteriorVehicleData")
          :Times(0)

        end
      --End Test case CommonRequestCheck.4.1.4

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.4.1.5
      --Description: --1. Application sends GetInteriorVehicleData as Zone = Front Passenger and ModuleType = RADIO
               --2. HMI sends OnInteriorVehicleData notification to RSDL (different zone)
        function Test:Subscription_PassengerFrontRADIO()
          --mobile sends request for precondition as Driver
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "RADIO",
              moduleZone =
              {
                colspan = 2,
                row = 0,
                rowspan = 2,
                col = 1,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "RADIO",
                  zone =
                  {
                    colspan = 2,
                    row = 0,
                    rowspan = 2,
                    col = 1,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})

              --hmi side: expect RC.GetInteriorVehicleData request
              EXPECT_HMICALL("RC.GetInteriorVehicleData")
                :Do(function(_,data1)
                  --hmi side: sending RC.GetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data1.id, data1.method, "SUCCESS", { isSubscribed = true,
                    moduleData = {
                      moduleType = "RADIO",
                      moduleZone = {
                        col = 1,
                        colspan = 2,
                        level = 0,
                        levelspan = 1,
                        row = 0,
                        rowspan = 2
                      },
                      radioControlData = {
                        frequencyInteger = 99,
                        frequencyFraction = 3,
                        band = "FM",
                        rdsData = {
                          PS = "name",
                          RT = "radio",
                          CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                          PI = "Sign",
                          PTY = 1,
                          TP = true,
                          TA = true,
                          REG = "Murica"
                        },
                        availableHDs = 3,
                        hdChannel = 1,
                        signalStrength = 50,
                        signalChangeThreshold = 60,
                        radioEnable = true,
                        state = "ACQUIRING"
                      }
                    }
                  })

                  --hmi side: HMI sends OnInteriorVehicleData notification to RSDL
                  self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
                    moduleData = {
                      moduleType = "RADIO",
                      moduleZone = {
                        col = 1,
                        colspan = 2,
                        level = 0,
                        levelspan = 1,
                        row = 1,
                        rowspan = 2
                      },
                      radioControlData = {
                        frequencyInteger = 99,
                        frequencyFraction = 3,
                        band = "AM",
                        rdsData = {
                          PS = "name",
                          RT = "radio",
                          CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                          PI = "Sign",
                          PTY = 1,
                          TP = true,
                          TA = true,
                          REG = "Murica"
                        },
                        availableHDs = 3,
                        hdChannel = 1,
                        signalStrength = 50,
                        signalChangeThreshold = 60,
                        radioEnable = true,
                        state = "ACQUIRING"
                      }
                    }
                  })

                end)
          end)


          --mobile side: expect SUCCESS response with info
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

          --mobile side: RSDL sends notifications to mobile app
          EXPECT_NOTIFICATION("OnInteriorVehicleData")
          :Times(0)

        end
      --End Test case CommonRequestCheck.4.1.5

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.4.1.6
      --Description: --1. Application sends GetInteriorVehicleData as Zone = Left Rare Passenger and ModuleType = RADIO
               --2. HMI sends OnInteriorVehicleData notification to RSDL (different zone)
        function Test:Subscription_PassengerLeftRADIO()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "RADIO",
              moduleZone =
              {
                colspan = 2,
                row = 1,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "RADIO",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})

              --hmi side: expect RC.GetInteriorVehicleData request
              EXPECT_HMICALL("RC.GetInteriorVehicleData")
              :Do(function(_,data1)
                  --hmi side: sending RC.GetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data1.id, data1.method, "SUCCESS", { isSubscribed = true,
                    moduleData = {
                      moduleType = "RADIO",
                      moduleZone = {
                        col = 0,
                        colspan = 2,
                        level = 0,
                        levelspan = 1,
                        row = 1,
                        rowspan = 2
                      },
                      radioControlData = {
                        frequencyInteger = 99,
                        frequencyFraction = 3,
                        band = "FM",
                        rdsData = {
                          PS = "name",
                          RT = "radio",
                          CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                          PI = "Sign",
                          PTY = 1,
                          TP = true,
                          TA = true,
                          REG = "Murica"
                        },
                        availableHDs = 3,
                        hdChannel = 1,
                        signalStrength = 50,
                        signalChangeThreshold = 60,
                        radioEnable = true,
                        state = "ACQUIRING"
                      }
                    }
                  })

                  --hmi side: HMI sends OnInteriorVehicleData notification to RSDL
                  self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
                    moduleData = {
                      moduleType = "RADIO",
                      moduleZone = {
                        col = 1,
                        colspan = 2,
                        level = 0,
                        levelspan = 1,
                        row = 1,
                        rowspan = 2
                      },
                      radioControlData = {
                        frequencyInteger = 99,
                        frequencyFraction = 3,
                        band = "AM",
                        rdsData = {
                          PS = "name",
                          RT = "radio",
                          CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                          PI = "Sign",
                          PTY = 1,
                          TP = true,
                          TA = true,
                          REG = "Murica"
                        },
                        availableHDs = 3,
                        hdChannel = 1,
                        signalStrength = 50,
                        signalChangeThreshold = 60,
                        radioEnable = true,
                        state = "ACQUIRING"
                      }
                    }

                  })
              end)
          end)


          --mobile side: expect SUCCESS response with info
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

          --mobile side: RSDL sends notifications to mobile app
          EXPECT_NOTIFICATION("OnInteriorVehicleData")
          :Times(0)

        end
      --End Test case CommonRequestCheck.4.1.6

    -----------------------------------------------------------------------------------------
  --End Test case CommonRequestCheck.4.1

  --Begin Test case CommonRequestCheck.4.2 (have to stop SDL before running CommonRequestCheck.4.1)
  --Description:  DRIVER's Device: In case HMI sends OnInteriorVehicleData (<moduleZone_value>, <moduleType_value>), RSDL must transfer this notification to the application(s) that is(are) currently subscribed to this <moduleType_value> in this <moduleZone_value> (see req.#1).

    --Requirement/Diagrams id in jira:
        --Requirement
        --TC: Requirement, Requirement

    --Verification criteria:
        --RSDL subscribes the RC-app to interiorVehicleData notifications right after getting "subscribe:true" from the app
    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.4.2.1
      --Description: --Set device to Driver's device
        function Test:Subscription_SetDriverDevice()
          --hmi side: send request RC.OnDeviceRankChanged
          self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
                              {deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

          --mobile side: Expect OnPermissionsChange notification for Driver's device
          EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )

        end
      --End Test case CommonRequestCheck.4.2.1

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.2.1
      --Description: activate App1 to FULL
        function Test:Precondition_Activation()

          --hmi side: sending SDL.ActivateApp request
          local rid = self.hmiConnection:SendRequest("SDL.ActivateApp",
                                { appID = self.applications["Test Application"] })

          --hmi side: Waiting for SDL.ActivateApp response
          EXPECT_HMIRESPONSE(rid)
          self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL" })
        end
      --End Test case CommonRequestCheck.3.2.1
    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.4.2.1
      --Description: --1. Application sends GetInteriorVehicleData as Zone = Driver and ModuleType = CLIMATE
               --2. HMI sends OnInteriorVehicleData notification to RSDL (different moduleType)
        function Test:Subscription_PassengerDriverCLIMATE()
          --mobile sends request for precondition as Driver
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "CLIMATE",
              moduleZone =
              {
                colspan = 2,
                row = 0,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RC.GetInteriorVehicleData request
          EXPECT_HMICALL("RC.GetInteriorVehicleData")
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleData response
              self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
                moduleData =
                {
                  moduleType = "CLIMATE",
                  moduleZone =
                  {
                    colspan = 2,
                    row = 0,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  },
                  climateControlData =
                  {
                    fanSpeed = 50,
                    circulateAirEnable = true,
                    dualModeEnable = true,
                    currentTemp = 30,
                    defrostZone = "FRONT",
                    acEnable = true,
                    desiredTemp = 24,
                    autoModeEnable = true,
                    temperatureUnit = "CELSIUS"
                  }
                }
              })

              --hmi side: HMI sends OnInteriorVehicleData notification to RSDL
              self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
                moduleData = {
                  moduleType = "RADIO",
                  moduleZone = {
                    col = 0,
                    colspan = 2,
                    level = 0,
                    levelspan = 1,
                    row = 0,
                    rowspan = 2
                  },
                  radioControlData = {
                    frequencyInteger = 99,
                    frequencyFraction = 3,
                    band = "AM",
                    rdsData = {
                      PS = "name",
                      RT = "radio",
                      CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                      PI = "Sign",
                      PTY = 1,
                      TP = true,
                      TA = true,
                      REG = "Murica"
                    },
                    availableHDs = 3,
                    hdChannel = 1,
                    signalStrength = 50,
                    signalChangeThreshold = 60,
                    radioEnable = true,
                    state = "ACQUIRING"
                  }
                }
              })

            end)



          --mobile side: expect SUCCESS response with info
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

          --mobile side: RSDL sends notifications to mobile app
          EXPECT_NOTIFICATION("OnInteriorVehicleData")
          :Times(0)

        end
      --End Test case CommonRequestCheck.4.2.1

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.4.2.2
      --Description: --1. Application sends GetInteriorVehicleData as Zone = Front Passenger and ModuleType = CLIMATE
               --2. HMI sends OnInteriorVehicleData notification to RSDL (different moduleType)
        function Test:Subscription_PassengerFrontCLIMATE()
          --mobile sends request for precondition as Driver
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "CLIMATE",
              moduleZone =
              {
                colspan = 2,
                row = 0,
                rowspan = 2,
                col = 1,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RC.GetInteriorVehicleData request
          EXPECT_HMICALL("RC.GetInteriorVehicleData")
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleData response
              self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
                moduleData =
                {
                  moduleType = "CLIMATE",
                  moduleZone =
                  {
                    colspan = 2,
                    row = 0,
                    rowspan = 2,
                    col = 1,
                    levelspan = 1,
                    level = 0
                  },
                  climateControlData =
                  {
                    fanSpeed = 50,
                    circulateAirEnable = true,
                    dualModeEnable = true,
                    currentTemp = 30,
                    defrostZone = "FRONT",
                    acEnable = true,
                    desiredTemp = 24,
                    autoModeEnable = true,
                    temperatureUnit = "CELSIUS"
                  }
                }
              })

              --hmi side: HMI sends OnInteriorVehicleData notification to RSDL
              self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
                moduleData = {
                  moduleType = "RADIO",
                  moduleZone = {
                    col = 1,
                    colspan = 2,
                    level = 0,
                    levelspan = 1,
                    row = 0,
                    rowspan = 2
                  },
                  radioControlData = {
                    frequencyInteger = 99,
                    frequencyFraction = 3,
                    band = "AM",
                    rdsData = {
                      PS = "name",
                      RT = "radio",
                      CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                      PI = "Sign",
                      PTY = 1,
                      TP = true,
                      TA = true,
                      REG = "Murica"
                    },
                    availableHDs = 3,
                    hdChannel = 1,
                    signalStrength = 50,
                    signalChangeThreshold = 60,
                    radioEnable = true,
                    state = "ACQUIRING"
                  }
                }
              })

            end)



          --mobile side: expect SUCCESS response with info
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

          --mobile side: RSDL sends notifications to mobile app
          EXPECT_NOTIFICATION("OnInteriorVehicleData")
          :Times(0)

        end
      --End Test case CommonRequestCheck.4.2.2

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.4.2.3
      --Description: --1. Application sends GetInteriorVehicleData as Zone = Left Rare Passenger and ModuleType = CLIMATE
               --2. HMI sends OnInteriorVehicleData notification to RSDL (different moduleType)
        function Test:Subscription_PassengerLeftCLIMATE()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "CLIMATE",
              moduleZone =
              {
                colspan = 2,
                row = 1,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

              --hmi side: expect RC.GetInteriorVehicleData request
              EXPECT_HMICALL("RC.GetInteriorVehicleData")
              :Do(function(_,data)
                  --hmi side: sending RC.GetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
                    moduleData =
                    {
                      moduleType = "CLIMATE",
                      moduleZone =
                      {
                        colspan = 2,
                        row = 1,
                        rowspan = 2,
                        col = 0,
                        levelspan = 1,
                        level = 0
                      },
                      climateControlData =
                      {
                        fanSpeed = 50,
                        circulateAirEnable = true,
                        dualModeEnable = true,
                        currentTemp = 30,
                        defrostZone = "FRONT",
                        acEnable = true,
                        desiredTemp = 24,
                        autoModeEnable = true,
                        temperatureUnit = "CELSIUS"
                      }
                    }
                  })

                  --hmi side: HMI sends OnInteriorVehicleData notification to RSDL
                  self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
                    moduleData = {
                      moduleType = "RADIO",
                      moduleZone = {
                        col = 0,
                        colspan = 2,
                        level = 0,
                        levelspan = 1,
                        row = 1,
                        rowspan = 2
                      },
                      radioControlData = {
                        frequencyInteger = 99,
                        frequencyFraction = 3,
                        band = "AM",
                        rdsData = {
                          PS = "name",
                          RT = "radio",
                          CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                          PI = "Sign",
                          PTY = 1,
                          TP = true,
                          TA = true,
                          REG = "Murica"
                        },
                        availableHDs = 3,
                        hdChannel = 1,
                        signalStrength = 50,
                        signalChangeThreshold = 60,
                        radioEnable = true,
                        state = "ACQUIRING"
                      }
                    }
                  })
              end)



          --mobile side: expect SUCCESS response with info
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

          --mobile side: RSDL sends notifications to mobile app
          EXPECT_NOTIFICATION("OnInteriorVehicleData")
          :Times(0)

        end
      --End Test case CommonRequestCheck.4.2.3

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.4.2.4
      --Description: --1. Application sends GetInteriorVehicleData as Zone = Driver and ModuleType = RADIO
               --2. HMI sends OnInteriorVehicleData notification to RSDL (different zone)
        function Test:Subscription_PassengerDriverRADIO()
          --mobile sends request for precondition as Driver
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "RADIO",
              moduleZone =
              {
                colspan = 2,
                row = 0,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RC.GetInteriorVehicleData request
          EXPECT_HMICALL("RC.GetInteriorVehicleData")
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleData response
              self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
                moduleData = {
                  moduleType = "RADIO",
                  moduleZone = {
                    col = 0,
                    colspan = 2,
                    level = 0,
                    levelspan = 1,
                    row = 0,
                    rowspan = 2
                  },
                  radioControlData = {
                    frequencyInteger = 99,
                    frequencyFraction = 3,
                    band = "FM",
                    rdsData = {
                      PS = "name",
                      RT = "radio",
                      CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                      PI = "Sign",
                      PTY = 1,
                      TP = true,
                      TA = true,
                      REG = "Murica"
                    },
                    availableHDs = 3,
                    hdChannel = 1,
                    signalStrength = 50,
                    signalChangeThreshold = 60,
                    radioEnable = true,
                    state = "ACQUIRING"
                  }
                }
              })

              --hmi side: HMI sends OnInteriorVehicleData notification to RSDL
              self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
                moduleData = {
                  moduleType = "RADIO",
                  moduleZone = {
                    col = 1,
                    colspan = 2,
                    level = 0,
                    levelspan = 1,
                    row = 1,
                    rowspan = 2
                  },
                  radioControlData = {
                    frequencyInteger = 99,
                    frequencyFraction = 3,
                    band = "AM",
                    rdsData = {
                      PS = "name",
                      RT = "radio",
                      CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                      PI = "Sign",
                      PTY = 1,
                      TP = true,
                      TA = true,
                      REG = "Murica"
                    },
                    availableHDs = 3,
                    hdChannel = 1,
                    signalStrength = 50,
                    signalChangeThreshold = 60,
                    radioEnable = true,
                    state = "ACQUIRING"
                  }
                }
              })

            end)



          --mobile side: expect SUCCESS response with info
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

          --mobile side: RSDL sends notifications to mobile app
          EXPECT_NOTIFICATION("OnInteriorVehicleData")
          :Times(0)

        end
      --End Test case CommonRequestCheck.4.2.4

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.4.2.5
      --Description: --1. Application sends GetInteriorVehicleData as Zone = Front Passenger and ModuleType = RADIO
               --2. HMI sends OnInteriorVehicleData notification to RSDL (different zone)
        function Test:Subscription_PassengerFrontRADIO()
          --mobile sends request for precondition as Driver
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "RADIO",
              moduleZone =
              {
                colspan = 2,
                row = 0,
                rowspan = 2,
                col = 1,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

              --hmi side: expect RC.GetInteriorVehicleData request
              EXPECT_HMICALL("RC.GetInteriorVehicleData")
                :Do(function(_,data)
                  --hmi side: sending RC.GetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
                    moduleData = {
                      moduleType = "RADIO",
                      moduleZone = {
                        col = 1,
                        colspan = 2,
                        level = 0,
                        levelspan = 1,
                        row = 0,
                        rowspan = 2
                      },
                      radioControlData = {
                        frequencyInteger = 99,
                        frequencyFraction = 3,
                        band = "FM",
                        rdsData = {
                          PS = "name",
                          RT = "radio",
                          CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                          PI = "Sign",
                          PTY = 1,
                          TP = true,
                          TA = true,
                          REG = "Murica"
                        },
                        availableHDs = 3,
                        hdChannel = 1,
                        signalStrength = 50,
                        signalChangeThreshold = 60,
                        radioEnable = true,
                        state = "ACQUIRING"
                      }
                    }
                  })

                  --hmi side: HMI sends OnInteriorVehicleData notification to RSDL
                  self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
                    moduleData = {
                      moduleType = "RADIO",
                      moduleZone = {
                        col = 1,
                        colspan = 2,
                        level = 0,
                        levelspan = 1,
                        row = 1,
                        rowspan = 2
                      },
                      radioControlData = {
                        frequencyInteger = 99,
                        frequencyFraction = 3,
                        band = "AM",
                        rdsData = {
                          PS = "name",
                          RT = "radio",
                          CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                          PI = "Sign",
                          PTY = 1,
                          TP = true,
                          TA = true,
                          REG = "Murica"
                        },
                        availableHDs = 3,
                        hdChannel = 1,
                        signalStrength = 50,
                        signalChangeThreshold = 60,
                        radioEnable = true,
                        state = "ACQUIRING"
                      }
                    }
                  })

                end)


          --mobile side: expect SUCCESS response with info
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

          --mobile side: RSDL sends notifications to mobile app
          EXPECT_NOTIFICATION("OnInteriorVehicleData")
          :Times(0)

        end
      --End Test case CommonRequestCheck.4.2.5

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.4.2.6
      --Description: --1. Application sends GetInteriorVehicleData as Zone = Left Rare Passenger and ModuleType = RADIO
               --2. HMI sends OnInteriorVehicleData notification to RSDL (different zone)
        function Test:Subscription_PassengerLeftRADIO()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "RADIO",
              moduleZone =
              {
                colspan = 2,
                row = 1,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

              --hmi side: expect RC.GetInteriorVehicleData request
              EXPECT_HMICALL("RC.GetInteriorVehicleData")
              :Do(function(_,data)
                  --hmi side: sending RC.GetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
                    moduleData = {
                      moduleType = "RADIO",
                      moduleZone = {
                        col = 0,
                        colspan = 2,
                        level = 0,
                        levelspan = 1,
                        row = 1,
                        rowspan = 2
                      },
                      radioControlData = {
                        frequencyInteger = 99,
                        frequencyFraction = 3,
                        band = "FM",
                        rdsData = {
                          PS = "name",
                          RT = "radio",
                          CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                          PI = "Sign",
                          PTY = 1,
                          TP = true,
                          TA = true,
                          REG = "Murica"
                        },
                        availableHDs = 3,
                        hdChannel = 1,
                        signalStrength = 50,
                        signalChangeThreshold = 60,
                        radioEnable = true,
                        state = "ACQUIRING"
                      }
                    }
                  })

                  --hmi side: HMI sends OnInteriorVehicleData notification to RSDL
                  self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
                    moduleData = {
                      moduleType = "RADIO",
                      moduleZone = {
                        col = 1,
                        colspan = 2,
                        level = 0,
                        levelspan = 1,
                        row = 1,
                        rowspan = 2
                      },
                      radioControlData = {
                        frequencyInteger = 99,
                        frequencyFraction = 3,
                        band = "AM",
                        rdsData = {
                          PS = "name",
                          RT = "radio",
                          CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                          PI = "Sign",
                          PTY = 1,
                          TP = true,
                          TA = true,
                          REG = "Murica"
                        },
                        availableHDs = 3,
                        hdChannel = 1,
                        signalStrength = 50,
                        signalChangeThreshold = 60,
                        radioEnable = true,
                        state = "ACQUIRING"
                      }
                    }

                  })
              end)


          --mobile side: expect SUCCESS response with info
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

          --mobile side: RSDL sends notifications to mobile app
          EXPECT_NOTIFICATION("OnInteriorVehicleData")
          :Times(0)

        end
      --End Test case CommonRequestCheck.4.2.6

    -----------------------------------------------------------------------------------------
  --End Test case CommonRequestCheck.4.2

--=================================================END TEST CASES 4==========================================================--

function Test.PostconditionsRestoreFile()
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end