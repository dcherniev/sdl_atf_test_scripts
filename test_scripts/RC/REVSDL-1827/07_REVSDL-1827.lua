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
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')

---------------------------------------------------------------------------------------------
--Instruction for config multi-devcies: https://adc.luxoft.com/confluence/display/REVSDL/Connecting+Multi-Devices+with+ATF
--Declaration connected devices.
--1. Device 2:
local device2 = "192.168.100.199"
local device2Port = 12345

os.execute("ifconfig lo:1 192.168.100.199")

---------------------------------------------------------------------------------------------
-------------------------------------STARTING COMMON FUNCTIONS-------------------------------
---------------------------------------------------------------------------------------------


--New connection device2
local function newConnectionDevice2(self, DeviceIP, Port)

  local tcpConnection = tcp.Connection(DeviceIP, Port)
  local fileConnection = file_connection.FileConnection("mobile2.out", tcpConnection)
  self.mobileConnection2 = mobile.MobileConnection(fileConnection)
  self.mobileSession21 = mobile_session.MobileSession(
		self,
		self.mobileConnection2,
		config.application1.registerAppInterfaceParams
	)
  event_dispatcher:AddConnection(self.mobileConnection2)
  self.mobileSession21:ExpectEvent(events.connectedEvent, "Connection started")
  self.mobileConnection2:Connect()
end

---------------------------------------------------------------------------------------------
----------------------------------------END COMMON FUNCTIONS---------------------------------
---------------------------------------------------------------------------------------------

--======================================Requirement========================================--
---------------------------------------------------------------------------------------------
--------------Requirement: Policies: "equipment" permissions must be checked-----------------
-------------------------- against location provided from HMI--------------------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--


--=================================================BEGIN TEST CASES 7==========================================================--
	--Begin Test suit CommonRequestCheck.7 for Req.#7

	--Description: 7. In case an RC application from <deviceID> device has driver's permission to control <moduleType> from <HMI-provided interiorZone> (via RC.OnDeviceLocationChanged from HMI)
						-- and any application from the same device sends an rc-RPC for controlling a different <moduleType>
						-- RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to control this different <moduleType> to the vehicle (HMI).


	--Begin Test case CommonRequestCheck.7.2
	--Description: 	RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to control this different <moduleType> to the vehicle (HMI).

		--Requirement/Diagrams id in jira:
				--Requirement
				--Requirement

		--Verification criteria:
				--RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to control this different <moduleType> to the vehicle (HMI).

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.1.1
			--Description: Connecting Device2 to RSDL
			function Test:TC7_ConnectDevice2()
				newConnectionDevice2(self, device2, device2Port)

			end
			--End Test case CommonRequestCheck.7.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.1.2
			--Description: Register App2 from Device2
			   function Test:TC7_App2Device2()

				--mobile side: RegisterAppInterface request
				  self.mobileSession21:StartService(7)
				  :Do(function()
				   local CorIdRAI = self.mobileSession21:SendRPC("RegisterAppInterface",
						   {

							syncMsgVersion =
							{
							 majorVersion = 2,
							 minorVersion = 2,
							},
							appName ="App2",
							ttsName =
							{

							 {
							  text ="4005",
							  type ="PRE_RECORDED",
							 },
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1234569",

						   })

				   --mobile side: RegisterAppInterface response
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"})
				  end)

			   end
			--End Test case CommonRequestCheck.7.1.2

		-----------------------------------------------------------------------------------------
		-------------------------FOR LEFT PASSENGER ZONE----------------------------------------

			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Left Passenger) (col=0, row=1, level=0)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL

				function Test:ChangedLocationDevice1_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged",
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true},
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.2.1
			--Description: application sends GetInteriorVehicleData as Driver zone and ModuleType = RADIO
				function Test:GetInterior_App1DriverRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
							:Do(function(_,data)
									--hmi side: sending RC.GetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
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

							end)
					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.7.2.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.2.2
			--Description: application sends SetInteriorVehicleData as Back Right and ModuleType = CLIMATE (different moduleType and the same app)
				function Test:SetInterior_App2RightCLIMATE_NonReceivedChangedLocation()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession21:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 1,
							rowspan = 2,
							col = 0,
							levelspan = 1,
							level = 0
						},
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"
					})

					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
								{
									appID = self.applications["App2"],
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

						--hmi side: expect Buttons.ButtonPress request
						EXPECT_HMICALL("Buttons.ButtonPress",
										{
											zone =
											{
												colspan = 2,
												row = 1,
												rowspan = 2,
												col = 0,
												levelspan = 1,
												level = 0
											},
											moduleType = "CLIMATE",
											buttonPressMode = "SHORT",
											buttonName = "LOWER_VENT"
						})
						:Do(function(_,data)
							--hmi side: sending Buttons.ButtonPress response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)
					end)

					self.mobileSession21:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.7.2.2

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.7.2


--=================================================END TEST CASES 7==========================================================--

function Test.PostconditionsRestoreFile()
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end