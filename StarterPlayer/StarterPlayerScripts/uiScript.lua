--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")



--// Events
local events = ReplicatedStorage:WaitForChild("events")
local inputEvent = events:WaitForChild("input")
local messageHistoryFunction = events:WaitForChild("messageHistory")
local messageEvent = events:WaitForChild("message")



--// Modules
local modules = ReplicatedStorage:WaitForChild("modules")
local spring = require(modules:WaitForChild("spring"))
local data = require(modules:WaitForChild("data"))



--// Players
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera

local playerGui = localPlayer:WaitForChild("PlayerGui")
local mainScreen = playerGui:WaitForChild("main")
local phoneFrame = mainScreen:WaitForChild("phoneFrame")
local applicationsFrame = phoneFrame:WaitForChild("Applications")
local openMenuButton = mainScreen:WaitForChild("openMenu")
local menuFrame = phoneFrame:WaitForChild("Menu"):WaitForChild("Main")
local phoneOpenClick = phoneFrame:WaitForChild("openMenuPhone")
local buttonsFrame = menuFrame:WaitForChild("buttonsFrameLabels")
local blackFadeButton = mainScreen:WaitForChild("blackFade")



--// Snap

local templateFrame = applicationsFrame:WaitForChild("Snap"):WaitForChild("Main"):WaitForChild("chat"):WaitForChild("Frame"):WaitForChild("ScrollingFrame")
local contactTemplate = templateFrame:WaitForChild("Template")

local messageFrame =  applicationsFrame:WaitForChild("Snap"):WaitForChild("Message")
local chatFrame =  messageFrame:WaitForChild("chat")
local chatBox =  chatFrame:WaitForChild("chatBox")
local sendButton = chatFrame:WaitForChild("send")
local messages = chatFrame:WaitForChild("messages")
local messageTemplate = messages:WaitForChild("template")



local pictureFrame = applicationsFrame:WaitForChild("Snap"):WaitForChild("Picture")
local cameraFrame = pictureFrame:WaitForChild("cameraFrame")

local VPcamera = Instance.new("Camera")
VPcamera.Name = "VPcamera"
VPcamera.Parent = cameraFrame

cameraFrame.CurrentCamera = VPcamera
phoneFrame.Position = UDim2.fromScale(0.762, 1.25)

--// Global
_G.PlayerGallery = {}



for applicationCount, application in applicationsFrame:GetChildren() do
	if application:IsA("Frame") then
		application.Visible = false
	end
end

if data.PhoneTurnOff then
	for frameCount, frame in pairs(phoneFrame:GetDescendants()) do
		if frame.Name == "phoneFrame" or frame:IsDescendantOf(applicationsFrame) or frame.Name == "Menu" then continue end

		if frame:IsA("ImageButton") and frame.ImageTransparency ~= 1 and frame.BackgroundTransparency ~= 1 then
			frame.ImageTransparency = 0.99
			frame.BackgroundTransparency = 0.99
		elseif frame:IsA("Frame") and frame.BackgroundTransparency ~= 1 then
			frame.BackgroundTransparency = 0.99
		elseif frame:IsA("TextLabel") and frame.TextTransparency ~= 1 then
			frame.TextTransparency = 0.99
		elseif frame:IsA("TextButton") and frame.TextTransparency ~= 1 and frame.BackgroundTransparency ~= 1 then
			frame.TextTransparency = 0.99
			frame.BackgroundTransparency = 0.99
		elseif frame:IsA("ImageLabel") and frame.ImageTransparency ~= 1 then
			frame.ImageTransparency = 0.99
		end
	end
end

mainScreen.Enabled = true

--// Variables
local PhoneState = false
local CurrentApplication = nil
local CurrentOverlay = nil
local takingPicture = false
local selectedContact = nil
local camera = "front"

local camMinZoom = localPlayer.CameraMinZoomDistance
local camMaxZoom = localPlayer.CameraMaxZoomDistance

local originalWalkSpeed
local originalJumpHeight



--// Functions

local function ApplicationOpen()
	local Application = applicationsFrame:FindFirstChild(CurrentApplication)
	if Application and Application:IsA("Frame") then
		
		local oldSize = Application.Size
		CurrentOverlay = "Main"
		
		Application.Size = UDim2.fromScale(0, 0)
		Application.Visible = true
		Application:FindFirstChild("Main").Visible = true
		
		Application:TweenSize(oldSize, Enum.EasingDirection.In, data.ApplicationChangeStyle, data.ApplicationOpenTime, true)
		task.wait(data.ApplicationOpenTime)
		menuFrame.Visible = false
	else
		
		warn(CurrentApplication, "is not found.")
		
		CurrentApplication = nil
	end
end

local function ApplicationClose()
	local Application = applicationsFrame:FindFirstChild(CurrentApplication)
	menuFrame.Visible = true
	if Application and Application:IsA("Frame") then
		local oldSize = Application.Size
		
		Application:TweenSize(UDim2.fromScale(0, 0), Enum.EasingDirection.In, data.ApplicationChangeStyle, data.ApplicationOpenTime, true)
		
		task.wait(data.ApplicationOpenTime)
		
		Application.Visible = false
		Application.Size = oldSize
		
		for frameCount, frame in pairs(Application:GetChildren()) do
			if frame:IsA("Frame") then
				frame.Visible = false
				frame.Position = UDim2.fromScale(0.5, 0.5)
			end
		end
		
		CurrentApplication = nil
		
	else
		
		warn(CurrentApplication, "is not found.")
	end
end

local function ChangeOverlay(Overlay, imageButton, direction)
	
	if Overlay then
		local oldOverlay = applicationsFrame[imageButton.Name]:FindFirstChild(CurrentOverlay, true)

		if not oldOverlay then
			warn(imageButton.Name, "CurrentOverlay CANNOT BE FOUND!")
		end
		
		if direction then
			if direction == "Right" then
				Overlay.Position = UDim2.fromScale(-0.5, 0.5)

				oldOverlay:TweenPosition(UDim2.fromScale(1.5, 0.5), Enum.EasingDirection.In, data.OverlayChangeStyle, data.ApplicationOverlayTime, true)
			elseif direction == "Left" then
				Overlay.Position = UDim2.fromScale(1.5, 0.5)
				
				oldOverlay:TweenPosition(UDim2.fromScale(-0.5, 0.5), Enum.EasingDirection.In, data.OverlayChangeStyle, data.ApplicationOverlayTime, true)
				
			elseif direction == "Up" then
				Overlay.Position = UDim2.fromScale(0.5, 1.5)

				oldOverlay:TweenPosition(UDim2.fromScale(0.5, -0.5), Enum.EasingDirection.In, data.OverlayChangeStyle, data.ApplicationOverlayTime, true)
				
			elseif direction == "Down" then
				Overlay.Position = UDim2.fromScale(0.5, -0.5)

				oldOverlay:TweenPosition(UDim2.fromScale(0.5, 1.5), Enum.EasingDirection.In, data.OverlayChangeStyle, data.ApplicationOverlayTime, true)
			end
		else
			Overlay.Position = UDim2.fromScale(-0.5, 0.5)

			oldOverlay:TweenPosition(UDim2.fromScale(1.5, 0.5), Enum.EasingDirection.In, data.OverlayChangeStyle, data.ApplicationOverlayTime, true)
		end
		
		Overlay:TweenPosition(UDim2.fromScale(0.5, 0.5), Enum.EasingDirection.In, data.OverlayChangeStyle, data.ApplicationOverlayTime, true)
		
		Overlay.Visible = true
		
		CurrentOverlay = Overlay.Name

		task.wait(data.ApplicationOverlayTime)

		for frameCount, frame in pairs(Overlay.Parent:GetChildren()) do
			if frame:IsA("Frame") and frame ~= Overlay then
				frame.Visible = false
				frame.Position = UDim2.fromScale(0.5, 0.5)
			end
		end
		
	else
		warn("'OVERLAY' not found!")
	end
end

local function OverlayClose(imageButton)
	if CurrentOverlay then
		
		local newOverlay = applicationsFrame[imageButton.Name]:FindFirstChild("Main", true)
		local currentOverlay = applicationsFrame[imageButton.Name]:FindFirstChild(CurrentOverlay, true)

		newOverlay.ZIndex = 100
		currentOverlay.ZIndex = 10
		newOverlay.Position = UDim2.fromScale(1.5, 0.5)
		newOverlay.Visible = true
		
		currentOverlay:TweenPosition(UDim2.fromScale(-0.5, 0.5), Enum.EasingDirection.In, data.OverlayChangeStyle, data.ApplicationOverlayTime, true)
		CurrentOverlay = newOverlay.Name
		newOverlay:TweenPosition(UDim2.fromScale(0.5, 0.5), Enum.EasingDirection.In, data.OverlayChangeStyle, data.ApplicationOverlayTime, true)
		
		task.wait(data.ApplicationOverlayTime)
		
		for frameCount, frame in pairs(newOverlay.Parent:GetChildren()) do
			if frame:IsA("Frame") and frame ~= newOverlay then
				frame.Visible = false
				frame.Position = UDim2.fromScale(0.5, 0.5)
			end
		end
		
		newOverlay.ZIndex = 5
		currentOverlay.ZIndex = 5
	else
		warn("No CURRENTOVERLAY found!")
	end
end

local function OpenPhone()
	inputEvent:FireServer("Equip", true, 0)
	PhoneState = true
	phoneOpenClick.Visible = false
	
	spring.target(phoneFrame, 0.8, 1, {
		Position = UDim2.fromScale(0.762, 0.5),
	})
	
	if data.PhoneTurnOff then
		for frameCount, frame in pairs(phoneFrame:GetDescendants()) do
			if frame.Name == "phoneFrame" or frame:IsDescendantOf(applicationsFrame) or frame.Name == "Menu" then continue end

			if frame:IsA("ImageButton") and frame.ImageTransparency ~= 1 and frame.BackgroundTransparency ~= 1 then
				spring.target(frame, 1, 2, {
					ImageTransparency = 0,
					BackgroundTransparency = 0,
				})
			elseif frame:IsA("Frame") and frame.BackgroundTransparency ~= 1 then
				spring.target(frame, 1, 2, {
					BackgroundTransparency = 0
				})
			elseif frame:IsA("TextLabel") and frame.TextTransparency ~= 1 then
				spring.target(frame, 1, 2, {
					TextTransparency = 0
				})
			elseif frame:IsA("TextButton") and frame.TextTransparency ~= 1 and frame.BackgroundTransparency ~= 1 then
				spring.target(frame, 1, 2, {
					TextTransparency = 0,
					BackgroundTransparency = 0
				})
			elseif frame:IsA("ImageLabel") and frame.ImageTransparency ~= 1 then
				spring.target(frame, 1, 2, {
					ImageTransparency = 0,
				})
			end
		end
	end
end

local function ClosePhone()
	inputEvent:FireServer("Equip", false, 1)
	PhoneState = false
	phoneOpenClick.Visible = true
	
	if CurrentApplication then
		coroutine.wrap(ApplicationClose)()
	end
	
	spring.target(phoneFrame, 0.8, 1, {
		Position = UDim2.fromScale(0.762, 1.25),
	})
	
	if data.PhoneTurnOff then
		for frameCount, frame in pairs(phoneFrame:GetDescendants()) do
			if frame.Name == "phoneFrame" or frame:IsDescendantOf(applicationsFrame) or frame.Name == "Menu" then continue end
			
			if frame:IsA("ImageButton") and frame.ImageTransparency ~= 1 and frame.BackgroundTransparency ~= 1 then
				spring.target(frame, 1, 2, {
					ImageTransparency = 0.99,
					BackgroundTransparency = 0.99,
				})
			elseif frame:IsA("Frame") and frame.BackgroundTransparency ~= 1 then
				spring.target(frame, 1, 2, {
					BackgroundTransparency = 0.99
				})
			elseif frame:IsA("TextLabel") and frame.TextTransparency ~= 1 then
				spring.target(frame, 1, 2, {
					TextTransparency = 0.99
				})
			elseif frame:IsA("TextButton") and frame.TextTransparency ~= 1 and frame.BackgroundTransparency ~= 1 then
				spring.target(frame, 1, 2, {
					TextTransparency = 0.99,
					BackgroundTransparency = 0.99
				})
			elseif frame:IsA("ImageLabel") and frame.ImageTransparency ~= 1 then
				spring.target(frame, 1, 2, {
					ImageTransparency = 0.99,
				})
			end
		end
	end
end



UserInputService.InputBegan:Connect(function(input, processed)
	if processed and input.KeyCode ~= Enum.KeyCode.Return and input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
	
	if input.KeyCode == Enum.KeyCode.E then
		if PhoneState then
			ClosePhone()
		else
			OpenPhone()
		end
	end
	
	if input.KeyCode == Enum.KeyCode.Return then
		if chatBox.Text ~= "" then
			messageEvent:FireServer(selectedContact, chatBox.Text)
			chatBox.Text = ""
		end
	end
end)

openMenuButton.Activated:Connect(function()
	if PhoneState then
		ClosePhone()
	else
		OpenPhone()
	end
end)


phoneOpenClick.Activated:Connect(function()
	if not PhoneState then
		OpenPhone()
	end
end)

local function canSendGameInvite(sendingPlayer)
	local success, err = pcall(function()
		return SocialService:CanSendGameInviteAsync(sendingPlayer)
	end)
	
	if success then
		return success
	else
		warn('Cannot invite player: '..err)
		return false
	end
end

local function zoomOut()
	
	localPlayer.CameraMinZoomDistance = 0
	localPlayer.CameraMaxZoomDistance = 0
	
	spring.target(localPlayer, 0.8, 2, {
		CameraMinZoomDistance = data.CamZoomOutDistance;
	})
	
	localPlayer.CameraMaxZoomDistance = camMaxZoom
	
	spring.completed(localPlayer, function()
		localPlayer.CameraMinZoomDistance = camMinZoom;
	end)
end

local function checkFade()
	if blackFadeButton.Transparency ~= 1 then

		TweenService:Create(
			blackFadeButton,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad),
			{Transparency = 1}
		):Play()

		localPlayer.CameraMode = Enum.CameraMode.Classic
		blackFadeButton.Visible = false
		
		zoomOut()
		
		localPlayer.Character.Humanoid.WalkSpeed = originalWalkSpeed
		localPlayer.Character.Humanoid.JumpHeight = originalJumpHeight
	end
end

--// Custome Features

local function SnapFeatures(imageButton)
	
	local snapApplication = applicationsFrame:FindFirstChild(imageButton.Name)

	local mainCloseButton = snapApplication:WaitForChild("Main"):FindFirstChild("CloseButton")
	local takePictureButton = snapApplication:WaitForChild("Picture"):WaitForChild("takePhoto")
	
	for galleryButtonCount, galleryButton in snapApplication:GetDescendants() do
		if galleryButton:IsA("TextButton") and galleryButton.Name == "galleryButton" and galleryButton.Parent.Parent.Name ~= "Gallery" then
			galleryButton.Activated:Connect(function()
				ChangeOverlay(snapApplication:WaitForChild("Gallery"), imageButton, "Right")
				checkFade()
			end)
		end
	end
	
	for contactButtonCount, contactButton in snapApplication:GetDescendants() do
		if contactButton:IsA("TextButton") and contactButton.Name == "contactsButton" and contactButton.Parent.Parent.Name ~= "Main" then
			contactButton.Activated:Connect(function()
				ChangeOverlay(snapApplication:WaitForChild("Main"), imageButton, "Left")
				checkFade()
			end)
		end
	end
	
	for pictureButtonCount, pictureButton in snapApplication:GetDescendants() do
		if pictureButton:IsA("TextButton") and pictureButton.Name == "pictureButton" and pictureButton.Parent.Parent.Name ~= "Picture" then
			pictureButton.Activated:Connect(function()
				
				if CurrentOverlay == "Main" then
					ChangeOverlay(snapApplication:WaitForChild("Picture"), imageButton, "Left")
				else
					ChangeOverlay(snapApplication:WaitForChild("Picture"), imageButton, "Left")
				end
				
				takingPicture = true
				
				originalWalkSpeed = localPlayer.Character.Humanoid.WalkSpeed
				originalJumpHeight = localPlayer.Character.Humanoid.JumpHeight
				
				localPlayer.Character.Humanoid.WalkSpeed = 0
				localPlayer.Character.Humanoid.JumpHeight = 0


				inputEvent:FireServer("Equip", false, 0)
				
				TweenService:Create(
					blackFadeButton,
					TweenInfo.new(0.5, Enum.EasingStyle.Quad),
					{Transparency = 0.5}
				):Play()
				
				
				localPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
				blackFadeButton.Visible = true
			end)
		end
	end
	
	for overlayCount, overlay in snapApplication:GetDescendants() do
		if overlay:IsA("ImageButton") and overlay.Name == "CloseButton" and overlay.Parent.Name ~= "Main" and overlay.Parent.Name ~= "Message" then
			overlay.Activated:Connect(function()
				OverlayClose(imageButton)
				checkFade()
			end)
		end
	end
	
	snapApplication:WaitForChild("Message"):WaitForChild("CloseButton").Activated:Connect(function()
		ChangeOverlay(snapApplication:WaitForChild("Main"), imageButton)
	end)
	

	mainCloseButton.Activated:Connect(function()
		ApplicationClose()
	end)
	
	snapApplication:WaitForChild("Main"):WaitForChild("chat"):WaitForChild("Frame"):WaitForChild("InviteButton").Activated:Connect(function()
		local inviteOptions = Instance.new("ExperienceInviteOptions")
		inviteOptions.PromptMessage = "Invite friends to chat to and hang out with!"
		inviteOptions.InviteMessageId = "ef0e0790-e2e8-4441-9a32-93f3a5783bf1"
		
		local canInvite = canSendGameInvite(localPlayer)
		
		if canInvite then
			SocialService:PromptGameInvite(localPlayer, inviteOptions)
		end
		
	end)
	
	
	takePictureButton.Activated:Connect(function()
		
		takingPicture = false
		
		localPlayer.Character.Humanoid.WalkSpeed = originalWalkSpeed
		localPlayer.Character.Humanoid.JumpHeight = originalJumpHeight
	end)
end

local function MapsFeatures(imageButton)

	local mapsApplication = applicationsFrame:FindFirstChild(imageButton.Name)

	local mainCloseButton = mapsApplication:WaitForChild("Main"):FindFirstChild("CloseButton")
	local trackingCloseButton = mapsApplication:WaitForChild("Tracking"):WaitForChild("CloseButton")
	local searchIconButton = mapsApplication:WaitForChild("Main"):WaitForChild("chat"):WaitForChild("searchIcon")

	mainCloseButton.Activated:Connect(function()
		ApplicationClose()
	end)

	trackingCloseButton.Activated:Connect(function()
		OverlayClose(imageButton)
	end)
	
	searchIconButton.Activated:Connect(function()
		ChangeOverlay(mapsApplication:WaitForChild("Tracking"), imageButton, "Right")
	end)
end

local function FoodFeatures(imageButton)

	local foodApplication = applicationsFrame:FindFirstChild(imageButton.Name)

	local mainCloseButton = foodApplication:WaitForChild("Main"):FindFirstChild("CloseButton")

	mainCloseButton.Activated:Connect(function()
		ApplicationClose()
	end)
end

local function WeatherFeatures(imageButton)

	local weatherApplication = applicationsFrame:FindFirstChild(imageButton.Name)

	local mainCloseButton = weatherApplication:WaitForChild("Main"):FindFirstChild("CloseButton")

	mainCloseButton.Activated:Connect(function()
		ApplicationClose()
	end)
end

local function TravelFeatures(imageButton)
	
	local selectedCar = nil
	local travelApplication = applicationsFrame:FindFirstChild(imageButton.Name)

	local mainCloseButton = travelApplication:WaitForChild("Main"):FindFirstChild("CloseButton")
	
	local buyCarFrame = travelApplication:WaitForChild("Main"):FindFirstChild("buyCar")
	local carListings = travelApplication:WaitForChild("Main"):FindFirstChild("carsListings"):WaitForChild("ScrollingFrame")

	mainCloseButton.Activated:Connect(function()
		ApplicationClose()
		
		spring.stop(buyCarFrame)
		buyCarFrame.Visible = false
		buyCarFrame.Position = UDim2.fromScale(0.484, 1.2)
	end)
	
	for carListCount, carlist in carListings:GetChildren() do
		
		if carlist:IsA("ImageButton") then
			
			carlist.Activated:Connect(function()
				
				if selectedCar ~= carlist.Name then
					spring.stop(buyCarFrame)
					buyCarFrame.Position = UDim2.fromScale(0.484, 1.2)
					buyCarFrame.Visible = true
					spring.target(buyCarFrame, 0.75, 0.75, {
						Position = UDim2.fromScale(0.484, 0.787)
					})
				end
			end)
		end
	end
end

local function HomeFeatures(imageButton)

	local homeApplication = applicationsFrame:FindFirstChild(imageButton.Name)

	local mainCloseButton = homeApplication:WaitForChild("Main"):FindFirstChild("CloseButton")

	mainCloseButton.Activated:Connect(function()
		ApplicationClose()
	end)
	
	homeApplication:WaitForChild("Main"):WaitForChild("startScreen"):WaitForChild("findHomeButton").Activated:Connect(function()
		ChangeOverlay(homeApplication:WaitForChild("PlotPicker"), imageButton, "Left")
	end)
	
	homeApplication:WaitForChild("PlotPicker"):WaitForChild("CloseButton").Activated:Connect(function()
		ChangeOverlay(homeApplication:WaitForChild("Main"), imageButton, "Right")
	end)
	
	homeApplication:WaitForChild("PlotPicker"):WaitForChild("startScreen"):WaitForChild("getPlotButton").Activated:Connect(function()
		ChangeOverlay(homeApplication:WaitForChild("PlotPurchase"), imageButton, "Up")
	end)
	
	homeApplication:WaitForChild("PlotPurchase"):WaitForChild("CloseButton").Activated:Connect(function()
		ChangeOverlay(homeApplication:WaitForChild("PlotPicker"), imageButton, "Down")
	end)
	
	homeApplication:WaitForChild("PlotPurchase"):WaitForChild("buyStuff"):WaitForChild("buyHouse").Activated:Connect(function()
		ChangeOverlay(homeApplication:WaitForChild("PlotSettings"), imageButton, "Left")
	end)
	
	homeApplication:WaitForChild("PlotSettings"):WaitForChild("CloseButton").Activated:Connect(function()
		ChangeOverlay(homeApplication:WaitForChild("PlotPurchase"), imageButton, "Right")
	end)
end

local function MusicFeatures(imageButton)

	local musicApplication = applicationsFrame:FindFirstChild(imageButton.Name)

	local mainCloseButton = musicApplication:WaitForChild("Main"):FindFirstChild("CloseButton")

	mainCloseButton.Activated:Connect(function()
		ApplicationClose()
	end)

end

local function GamesFeatures(imageButton)

	local gamesApplication = applicationsFrame:FindFirstChild(imageButton.Name)

	local mainCloseButton = gamesApplication:WaitForChild("Main"):FindFirstChild("CloseButton")

	mainCloseButton.Activated:Connect(function()
		ApplicationClose()
	end)

end

local function SettingsFeatures(imageButton)

	local settingsApplication = applicationsFrame:FindFirstChild(imageButton.Name)

	local mainFrame = settingsApplication:WaitForChild("Main")
	local mainFrameLoop = mainFrame:WaitForChild("contentFrame")
	local mainCloseButton = mainFrame:FindFirstChild("CloseButton")

	mainCloseButton.Activated:Connect(function()
		ApplicationClose()
	end)
	
	for buttonCount, button in mainFrameLoop:GetChildren() do
		if button:IsA("TextButton") then
			local overlayFrame = settingsApplication:FindFirstChild(string.gsub(button.Name, "Button", ""))

			button.Activated:Connect(function()
				ChangeOverlay(overlayFrame, imageButton, "Left")
			end)
			
			overlayFrame:WaitForChild("CloseButton").Activated:Connect(function()
				ChangeOverlay(mainFrame, imageButton, "Right")
			end)
		end
	end

end

local function ShopFeatures(imageButton)

	local shopApplication = applicationsFrame:FindFirstChild(imageButton.Name)

	local mainCloseButton = shopApplication:WaitForChild("Main"):FindFirstChild("CloseButton")

	mainCloseButton.Activated:Connect(function()
		ApplicationClose()
	end)

end

local function VideoFeatures(imageButton)

	local videoApplication = applicationsFrame:FindFirstChild(imageButton.Name)

	local mainCloseButton = videoApplication:WaitForChild("Main"):FindFirstChild("CloseButton")

	mainCloseButton.Activated:Connect(function()
		ApplicationClose()
	end)

end

local function PhotosFeatures(imageButton)

	local photoApplication = applicationsFrame:FindFirstChild(imageButton.Name)

	local mainCloseButton = photoApplication:WaitForChild("Main"):FindFirstChild("CloseButton")

	mainCloseButton.Activated:Connect(function()
		ApplicationClose()
	end)

end

for imageButtonCount, imageButton in pairs(buttonsFrame:GetChildren()) do
	if imageButton:IsA("TextButton") then
		imageButton.Activated:Connect(function()
			if CurrentApplication then
				ApplicationClose()
			end
			CurrentApplication = imageButton.Name
			ApplicationOpen()
		end)
		
		--// CUSTOM FEATURES
		
		
		if applicationsFrame:FindFirstChild(imageButton.Name) then

			if imageButton.Name == "Snap" then
				SnapFeatures(imageButton)	
				
			elseif imageButton.Name == "Maps" then
				MapsFeatures(imageButton)
				
			elseif imageButton.Name == "Food" then
				FoodFeatures(imageButton)

			elseif imageButton.Name == "Weather" then
				WeatherFeatures(imageButton)

			elseif imageButton.Name == "Travel" then
				TravelFeatures(imageButton)
				
			elseif imageButton.Name == "Home" then
				HomeFeatures(imageButton)
				
			elseif imageButton.Name == "Music" then
				MusicFeatures(imageButton)
				
			elseif imageButton.Name == "Games" then
				GamesFeatures(imageButton)
				
			elseif imageButton.Name == "Settings" then
				SettingsFeatures(imageButton)
				
			elseif imageButton.Name == "Shop" then
				ShopFeatures(imageButton)
				
			elseif imageButton.Name == "Video" then
				VideoFeatures(imageButton)
				
			elseif imageButton.Name == "Photos" then
				PhotosFeatures(imageButton)
				
			end
		else
			warn("APPLICATION FOLDER FOR: '"..imageButton.Name.."' NOT FOUND!")
		end
	end
end



local function askForMessageHistory(targetPlayerName)
	local template = messages:FindFirstChild("template")
	
	if not template then
		warn("TEMPLATE cannot be found; message history not loading!")
	end
	
	local messageHistoryFunction = messageHistoryFunction:InvokeServer(targetPlayerName)
	
	if not messageHistoryFunction then
		warn("No message history found with the player: @"..targetPlayerName)
		return nil
	else
		return messageHistoryFunction
	end
end

local function addPlayerContact(player)
	local userId = player.UserId
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size60x60
	local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

	if not isReady then
		warn(player.Name.."'s THUMBNAIL is not loading!")
	end


	local playerContact = contactTemplate:Clone()
	playerContact.Visible = true
	playerContact.Parent = templateFrame

	playerContact.ImageLabel.Image = content
	playerContact.TextLabel.Text = player.Name
	
	playerContact.send.Activated:Connect(function()		
		selectedContact = player
		
		chatFrame.playerIcon.Image = content
		chatFrame.playerName.Text = player.Name
		
		local history = askForMessageHistory(player.Name)
		
		if history then
			
			for messageCount, message in messages:GetChildren() do
				if message:IsA("Frame") and message.Name ~= "template" then
					message:Destroy()
				end
			end
			
			for textCount, text in history do
				local message = messageTemplate:Clone()
				message.Visible = true
				message.Name = text
				message.Parent = messages

				message.TextLabel.Text = text
				message.ImageLabel.Image = content
			end
		end
		
		ChangeOverlay(messageFrame, applicationsFrame:WaitForChild("Snap"))
	end)
end

for playerCount, player in pairs(Players:GetPlayers()) do
	if player ~= localPlayer then
		addPlayerContact(player)
	end
end

Players.PlayerAdded:Connect(function(player)
	addPlayerContact(player)
end)

sendButton.Activated:Connect(function()
	if chatBox.Text == "" then
		messageEvent:FireServer(selectedContact, chatBox.Text)
		chatBox.Text = ""
	end
end)

messageEvent.OnClientEvent:Connect(function(targetPlayer)
	
	if selectedContact then
		
		local userId = targetPlayer.UserId
		local thumbType = Enum.ThumbnailType.HeadShot
		local thumbSize = Enum.ThumbnailSize.Size60x60
		local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
		
		local newHistory = askForMessageHistory(targetPlayer.Name)

		if newHistory then
			
			for messageCount, message in messages:GetChildren() do
				if message:IsA("Frame") and message.Name ~= "template" then
					message:Destroy()
				end
			end
			
			for textCount, text in newHistory do
				local message = messageTemplate:Clone()
				message.Visible = true
				message.Name = text
				message.Parent = messages

				message.TextLabel.Text = text
				message.ImageLabel.Image = content
			end
		end
	end
end)

local playerCharacter
local playerPhone

local function getCamera()
	if not playerPhone then return end
	
	if camera == "front" then
		return playerPhone.frontCamera
	else
		return playerPhone.backCamera
	end
end

RunService.RenderStepped:Connect(function(deltaTime)
	if takingPicture then
		cameraFrame.map:ClearAllChildren()

		local clone = workspace.Items:Clone()
		clone.Parent = cameraFrame.map
		
		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			blackFadeButton.Modal = false
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			blackFadeButton.Modal = true
		end
		
		playerCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
		playerPhone = playerCharacter:FindFirstChild("Phone")
		
		VPcamera.CFrame = getCamera().CFrame
	end
end)
