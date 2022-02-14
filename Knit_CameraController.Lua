-- [[USER CAMERA CONTROLS FOR PC/MOBILE ]]

local Knit = require(game:GetService("ReplicatedStorage").Knit)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local CameraShaker = require(game.ReplicatedStorage.Assets.Code.CameraShaker)
local ContextActionService = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")

local CameraController = Knit.CreateController {
	Name = "CameraController";
	Client = {};
}

local actionList = {
	["MoveUp"] = Enum.KeyCode.W,
	["MoveDown"] = Enum.KeyCode.S,
	["MoveLeft"] = Enum.KeyCode.A,
	["MoveRight"] = Enum.KeyCode.D
}
local actionFunctions = {}

local default_CameraPosition = workspace.CameraModel.PrimaryPart.Position
local default_CameraZoom = 15

local cameraPosition = default_CameraPosition
local cameraZoom = default_CameraZoom

local cameraZoomBounds = {5,100}
local touchDragSpeed = 0.15


local movingUp = false
local movingDown = false
local movingLeft = false
local movingRight = false

local speedVector = 0.4
local cameraMoveVector = 8

function CameraController:UpdateCamera()
	self.model:SetPrimaryPartCFrame(CFrame.new(cameraPosition)*Vector3.new(0,0,cameraZoom))
end

function CameraController:cameraZoom(inout)
	
	local tweenSpeed = 0.05
	
	if inout == "in" then
		local goal = {}
		
		local CFrameValue = Instance.new("CFrameValue")
		CFrameValue.Value = self.model.PrimaryPart.CFrame
		
		CFrameValue.Changed:connect(function()
			self.model:SetPrimaryPartCFrame(CFrameValue.Value)
		end)
		
		local pos1 = self.model.PrimaryPart.Position
		local pos2 = self.model.To.Position
		
		goal.Value = CFrame.new((pos2 - pos1).Unit * math.min(cameraMoveVector, (pos2 - pos1).Magnitude) + pos1)
		
		local tweenInfo = TweenInfo.new(
			tweenSpeed, -- Time
			Enum.EasingStyle.Linear, -- EasingStyle
			Enum.EasingDirection.Out
		)
		local tween = TweenService:Create(CFrameValue, tweenInfo, goal)
		tween:Play()
		tween.Completed:connect(function()
			CFrameValue:Destroy()
		end)
		
	else
		local goal = {}

		local CFrameValue = Instance.new("CFrameValue")
		CFrameValue.Value = self.model.PrimaryPart.CFrame

		CFrameValue:GetPropertyChangedSignal("Value"):connect(function()
			self.model:SetPrimaryPartCFrame(CFrameValue.Value)
		end)

		local pos1 = self.model.PrimaryPart.Position
		local pos2 = self.model.To.Position

		goal.Value = CFrame.new((pos2 - pos1).Unit * -math.min(cameraMoveVector, (pos2 - pos1).Magnitude) + pos1)

		local tweenInfo = TweenInfo.new(
			tweenSpeed, -- Time
			Enum.EasingStyle.Linear, -- EasingStyle
			Enum.EasingDirection.Out
		)
		local tween = TweenService:Create(CFrameValue, tweenInfo, goal)
		tween:Play()
		tween.Completed:connect(function()
			CFrameValue:Destroy()
		end)
	end
end




UIS.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		if input.Position.Z > 0 then
			CameraController:cameraZoom("in")
		else
			CameraController:cameraZoom("out")
		end
	end
end)



lastTouchTranslation = nil
local function TouchMove(touchPositions, totalTranslation, velocity, state)
	local model = workspace.CameraModel
	if state == Enum.UserInputState.Change or state == Enum.UserInputState.End then
		local difference = (totalTranslation - lastTouchTranslation)/(cameraZoom*10)
		local moveDirection = game.Players.LocalPlayer.Character.Humanoid.MoveDirection/2
		model:SetPrimaryPartCFrame(model.PrimaryPart.CFrame + Vector3.new(difference.X/2+(difference.Y/2),0,difference.Y/2+(-difference.X/2)))
		CameraController:UpdateCamera()
	end
	lastTouchTranslation = totalTranslation
end

UIS.TouchPan:Connect(TouchMove)

local lastTouchScale = nil
local function TouchZoom(touchPositions, scale, velocity, state)
	if state == Enum.UserInputState.Change or state == Enum.UserInputState.End then
		local difference = scale - lastTouchScale
		cameraZoom = cameraZoom * (1 + difference)
		if cameraZoomBounds ~= nil then
			cameraZoom = math.min(math.max(cameraZoom, cameraZoomBounds[1]), cameraZoomBounds[2])
		else
			cameraZoom = math.max(cameraZoom, 0)
		end
		CameraController:UpdateCamera()
	end
	lastTouchScale = scale
end
UIS.TouchPinch:Connect(TouchZoom)


actionFunctions["MoveUp"] = function(_,state)
	if state == Enum.UserInputState.Begin then
		movingUp = true
	elseif state == Enum.UserInputState.End then
		movingUp = false
	end

end
actionFunctions["MoveDown"] = function(_,state)
	if state == Enum.UserInputState.Begin then
		movingDown = true
	elseif state == Enum.UserInputState.End then
		movingDown = false
	end

end
actionFunctions["MoveLeft"] = function(_,state)
	if state == Enum.UserInputState.Begin then
		movingLeft = true
	elseif state == Enum.UserInputState.End then
		movingLeft = false
	end

end
actionFunctions["MoveRight"] = function(_,state)
	if state == Enum.UserInputState.Begin then
		movingRight = true
	elseif state == Enum.UserInputState.End then
		movingRight = false
	end

end
RunService.Heartbeat:Connect(function(step)
	local model = workspace.CameraModel
	if movingUp == true then
		model:SetPrimaryPartCFrame(CFrame.new(model.PrimaryPart.Position)+Vector3.new(speedVector,0,speedVector))
	end
	if movingDown == true then
		model:SetPrimaryPartCFrame(CFrame.new(model.PrimaryPart.Position)+Vector3.new(-speedVector,0,-speedVector))
	end
	if movingLeft == true then
		model:SetPrimaryPartCFrame(CFrame.new(model.PrimaryPart.Position)+Vector3.new(speedVector,0,-speedVector))
	end
	if movingRight == true then
		model:SetPrimaryPartCFrame(CFrame.new(model.PrimaryPart.Position)+Vector3.new(-speedVector,0,speedVector))
	end
end)

function CameraController:SetViewArena()
	self.camera.CameraType = Enum.CameraType.Scriptable
	self.camera.FieldOfView = 30
	local model = workspace.CameraModel
	
	self.cameraEvent = RunService.RenderStepped:Connect(function()
		if model then
			self.camera.CFrame = CFrame.new(model.From.Position, model.To.Position)
		end
	end)
	
end

function CameraController:RunningControls()
	for action, keycode in pairs(actionList) do
		ContextActionService:BindAction(action, actionFunctions[action], true, keycode)
	end
end

function CameraController:KnitStart()
	local plr = game.Players.LocalPlayer
	
	self.plr = plr
	self.defaultFOV = workspace.CurrentCamera.FieldOfView
	self.camera = workspace.CurrentCamera
	
	--local mouse = plr:GetMouse()
	--mouse.Icon = "rbxassetid://8377924368"
	self.model = workspace.CameraModel
	
	self:SetViewArena()
	self:RunningControls()
	
end


return CameraController
