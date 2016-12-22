---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [PolicyTableUpdate] Request to update PT - after "N" ignition cycles
--
-- Description:
-- Triggering PTU on reaching 'ignition_cycles_since_last_exchange' value
-- 1. Used preconditions:
-- Delete log file and policy table if any
-- Register app and update policy
-- Stop SDL
-- Set ignition_cycles_since_last_exchange less on 1 from exchange_after_x_ignition_cycles
-- Start SDL
-- Register app
--
-- 2. Performed steps
-- Preform IGNOF
--
-- Expected result:
-- HMI->SDL:BasicCommunication.OnIgnitionCycleOver->
-- SDL must trigger a PolicyTableUpdate sequence
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
config.application1.registerAppInterfaceParams.appHMIType = {"DEFAULT"}
--[ToDo: should be removed when fixed: "ATF does not stop HB timers by closing session and connection"
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFiles()
commonSteps:DeletePolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
local mobile_session = require('mobile_session')
require('user_modules/AppTypes')

--[[ Local functions ]]
local function SetIgnitionCyclesSinceLastExchange()
  local pathToDB = config.pathToSDL .. "storage/policy.sqlite"
  local sql_query = 'select exchange_after_x_ignition_cycles from module_config where rowid=1;'
  local exchange_after_x_ignition_cycles = commonFunctions:get_data_policy_sql(pathToDB, sql_query)
  local DBQuery = 'sqlite3 ' .. pathToDB .. ' \"UPDATE module_meta SET ignition_cycles_since_last_exchange = ' .. tonumber(exchange_after_x_ignition_cycles[1]) - 1 .. ' WHERE rowid = 1;\"'
  os.execute(DBQuery)
  os.execute(" sleep 1 ")
end

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_Activate_App_Consent_Device_And_Update_Policy()
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", {appID = self.applications["Test Application"]})
  EXPECT_HMIRESPONSE(RequestId, {result = {code = 0, isSDLAllowed = false}, method = "SDL.ActivateApp"})
  :Do(function(_,_)
      local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
      EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
      :Do(function(_,_)
          self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
          -- GetCurrentTimeStampDeviceConsent()
          EXPECT_HMICALL("BasicCommunication.ActivateApp")
          :Do(function(_,data1)
              self.hmiConnection:SendResponse(data1.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
              EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
              :Do(function()
                end)
            end)
        end)
    end)
  EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
  :Do(function(_,data)
      pathToSnapshot = data.params.file
      local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
      EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
      :Do(function()
          self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",{requestType = "PROPRIETARY", fileName = "filename"})
          EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
          :Do(function()
              local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest", {fileName = "PolicyTableUpdate", requestType = "PROPRIETARY"}, "files/ptu_general.json")
              local systemRequestId
              EXPECT_HMICALL("BasicCommunication.SystemRequest")
              :Do(function(_,data1)
                  systemRequestId = data1.id
                  self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
                    {
                      policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"
                    })
                  self.hmiConnection:SendResponse(systemRequestId, "BasicCommunication.SystemRequest", "SUCCESS", {})
                  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UP_TO_DATE"}):Timeout(500)
                  self.mobileSession:ExpectResponse(CorIdSystemRequest, {success = true, resultCode = "SUCCESS"})
                end)
            end)
        end)
    end)
end

function Test:Precondition_StopSDL()
  StopSDL()
end

function Test:Precondition_SetIgnitionCyclesSinceLastExchange()
  SetIgnitionCyclesSinceLastExchange()
end

function Test:Precondition_StartSDL()
  StartSDL(config.pathToSDL, config.ExitOnCrash)
end

function Test:Precondition_InitHMI()
  self:initHMI()
end

function Test:Precondition_InitHMI_onReady()
  self:initHMI_onReady()
end

function Test:Precondition_Register_app()
  self:connectMobile()
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
  :Do(function()
      local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
      EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
      :Do(function(_,data)
          self.HMIAppID = data.params.application.appID
        end)
      self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS" })
      self.mobileSession:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
    end)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:Check_PTU_triggered_on_IGNOFF()
  StopSDL()
  self.hmiConnection:SendNotification("BasicCommunication.OnIgnitionCycleOver")
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})
  :Timeout(500)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_SDLStop()
  StopSDL()
end