local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Janitor = require(Knit.Util.Janitor)
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Sounds = game.ReplicatedStorage.Assets.Audio

local ClientTreasureChest = {}

ClientTreasureChest.__index = ClientTreasureChest

-- The CollectionService tag to bind:
ClientTreasureChest.Tag = "TreasureChest"

function Format(Int)
	return string.format("%02i", Int)
end

function convertToHMS(Seconds)
	local Minutes = (Seconds - Seconds%60)/60
	Seconds = Seconds - Minutes*60
	local Hours = (Minutes - Minutes%60)/60
	Minutes = Minutes - Hours*60
	return Format(Hours)..":"..Format(Minutes)..":"..Format(Seconds)
end

function ClientTreasureChest:ChestUpdate(st,UI)
	local isReady = true
	local timeNow = os.time()
	local data = HttpService:JSONDecode(st.ChestTimer.Value)
	local timeDelta = nil

	if data.Timers[self.ID] then
		timeDelta = data.Timers[self.ID]
		local diff = timeNow - timeDelta
		if diff >= 60 * 60 * 6 then

		else
			isReady = false
		end
	end

	if isReady == true then
		UI.tim.Text = "Ready to collect!"
	else

		spawn(function()
			local timeTo = timeDelta
			local waitTime = (60*60*6)
			local br = false
			while waitTime > (os.time()-timeTo) do
				wait(1)
				local diff = (60*60*6) - (os.time() - timeTo)
				UI.tim.Text = convertToHMS(diff)

				local conn = self.Bindable.Event:Connect(function()
					br = true
				end)

				if br == true then
					conn:Disconnect()
					break
				end
			end
		end)
	end
end

function ClientTreasureChest.new(adornee)
	local debounce = false
	local self = setmetatable({}, ClientTreasureChest)
	self._janitor = Janitor.new()
	self.adornee = adornee
	repeat wait() until self.adornee.PrimaryPart
	
	
	self.ID = self.adornee:GetAttribute("ID")
	self.RewardAmount = self.adornee:GetAttribute("RewardAmount")
	local UI = self.adornee.Lights.Ring.Tag
	UI.tim.Text = "Ready to collect!"
	UI.amount.Text = self.RewardAmount.." DIAMONDS"
	
	local plr = game.Players.LocalPlayer
	local st = game.ReplicatedStorage.PlayerStats:WaitForChild(plr.Name)
	
	self.Bindable = Instance.new("BindableEvent")
	
	if st then
		st.ChestTimer.Changed:Connect(function()
			self:ChestUpdate(st,UI)
		end)
		self:ChestUpdate(st,UI)
	end
	
	--self:PlayAnimation()
	
	self.adornee.PrimaryPart.Touched:Connect(function(hit)
		if hit and hit.Parent and game.Players.LocalPlayer == game.Players:FindFirstChild(hit.Parent.Name) and debounce == false then
			debounce = true
			local isGiven = self.adornee.TouchEvent:InvokeServer()
			if isGiven == true then
				
				plr.Backpack.Sounds.ChestOpen:Play()
				self:PlayAnimation()
				
				-- play animation
				-- do the timer thing
				--[[self:PlayHideAnimation()
				self:PlayUIAnimation(self.adornee:GetAttribute("notificationColor"))
				local cl = Sounds.ring2:Clone()
				cl.Parent = workspace
				cl.PlayOnRemove = true
				cl:Destroy()
				
				local interval = 10
				for x=1, self.refreshRate*interval do
					textLabel.Text = self.refreshRate - x/interval
					wait(1/interval)
				end]]
			else
				
			end
			
			--textLabel.Text = "+"..self.stepAmount.." Steps"
			wait(1)
			debounce = false
		end
	end)

	return self
end

function ClientTreasureChest:PlayAnimation()
	local function ShakePart(part)
		local cycleDuration = 0.1
		local totalDuration = 1
		local volatility = 2

		local savedPosition = part.Position
		local tweeninfo = TweenInfo.new(
			cycleDuration,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out,
			0,
			false,
			0
		)
		for i = 0, totalDuration - cycleDuration, cycleDuration do
			local tween = TweenService:Create(
				part,
				tweeninfo,
				{Position = savedPosition + Vector3.new(math.random(),math.random(),math.random()).Unit * volatility}
			)
			tween:Play()
			tween.Completed:Wait()
		end
		TweenService:Create(
			part,
			tweeninfo,
			{Position = savedPosition}
		):Play()
	end
	self.adornee.Treasure.Chest.ParticleEmitter:Emit(100)
	ShakePart(self.adornee.Treasure.Chest)
end

function ClientTreasureChest:Destroy()
	--self.tween:Cancel()
	self._janitor:Destroy()
end

return ClientTreasureChest
