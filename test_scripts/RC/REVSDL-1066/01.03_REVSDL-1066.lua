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
local mobile_session = require('mobile_session')

--List permission of "OnPermissionsChange" for PrimaryDevice and NonPrimaryDevice
--groups_PrimaryRC Group
local arrayGroups_PrimaryRC = revsdl.arrayGroups_PrimaryRC()

--======================================Requirement=========================================--
---------------------------------------------------------------------------------------------
-----------Requirement: RSDL must inform HMILevel of a rc-application to HMI ----------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--


--=================================================BEGIN TEST CASES 1==========================================================--
  --Begin Test suit CommonRequestCheck.1 for Req.#1

  --Description: 1. In case the HMILevel of the application registered with "REMOTE_CONTROL" appHMIType from driver's device is changed (see Requirement for details), RSDL must inform this event via BC.ActivateApp (level: <appropriate assigned HMILevel of the app>) to HMI.
            --Exception: FULL level (that is, RSDL must not notify HMI about the rc-app has transitioned to FULL).
 --Begin Test case CommonRequestCheck.1.3
  --Description:  In case the HMILevel of the application registered with "REMOTE_CONTROL" appHMIType from driver's device is changed (see Requirement for details), RSDL must inform this event via BC.ActivateApp (level: <appropriate assigned HMILevel of the app>) to HMI.

    --Requirement/Diagrams id in jira:
        --Requirement
        --TC: Requirement

    --Verification criteria:
        --In case the device is set as 'driver's' (see Requirement), R-SDL must assign "groups_primaryRC" permissions from appropriate policies to each remote-control app from this device.

    -----------------------------------------------------------------------------------------

      --Begin Test case Precondition.1.3.1
      --Description: Set device1 to Driver's device from HMI.
        function Test:TC3_Precondition1()

          --hmi side: send request RC.OnDeviceRankChanged
          self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
                              {deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

          --mobile side: Expect OnPermissionsChange notification for Driver's device
          EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )

          --mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
          EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })

        end
      --End Test case Precondition.1.3.1

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.1.3.2
      --Description: activate App1 to FULL
        function Test:TC3_Precondition2()

          --hmi side: sending SDL.ActivateApp request
          local rid = self.hmiConnection:SendRequest("SDL.ActivateApp",
                                { appID = self.applications["Test Application"] })

          --hmi side: Waiting for SDL.ActivateApp response
          EXPECT_HMIRESPONSE(rid)
          self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
        end
      --End Test case CommonRequestCheck.1.3.2
    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.1.3.3
      --Description: activate App1 to LIMITED
        function Test:TC3_DeactivatedApp1_LIMITED()

          --hmi side: Go to "Application List" menu on HMI then deactivate App_1 to make HMILevel = LIMITED.
          self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "GENERAL"})

          --RSDL sends BC.ActivateApp (level: LIMITED) to HMI
          EXPECT_HMICALL("BasicCommunication.ActivateApp",
            {
              appID = self.applications["Test Application"],
              level = "LIMITED",
              priority = "NONE"
            }
          )

          --Mobile side: RSDL sends OnHMIStatus (LIMITED,params)
          self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED"})

        end
      --End Test case CommonRequestCheck.1.3.3
    -----------------------------------------------------------------------------------------
  --End Test case CommonRequestCheck.1.3


--=================================================END TEST CASES 1==========================================================--

function Test.PostconditionsRestoreFile()
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end