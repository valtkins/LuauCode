local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Janitor = require(Knit.Util.Janitor)
local CollectionService = game:GetService("CollectionService")

local SpawnZone = {}

SpawnZone.__index = SpawnZone

-- The CollectionService tag to bind:
SpawnZone.Tag = "SpawnZone"
SpawnZone.SpawnLimit = 5

function SpawnZone.new(adornee)
	local self = setmetatable({}, SpawnZone)
	
	self._janitor = Janitor.new()
	self.adornee = adornee
	
	self.adornee.Transparency = 1
	
	self.spawnedItems = {}
	self.zone = self.adornee.Parent.Parent.Name
	
	
	self.SpawnLimit = math.ceil((self.adornee.Size.X*self.adornee.Size.Y)/448*1.5) --448
	
	self:LoadSpawnedItems()
	
	--self.interactEvent = self._janitor:Add(Instance.new("BindableEvent",self.adornee))

	return self
end

function SpawnZone:spawnLoadItem()
	wait(math.random(10,20))
	local availableItems = game.ReplicatedStorage.Assets.SpawnZoneItems[self.zone]:GetChildren()
	
	local totalWeight = 0
	for _, item in pairs(availableItems) do
		totalWeight += item:GetAttribute("Weight")
	end
	
	local chosenWeight = math.random(1,totalWeight)
	
	local chosenItem = nil
	
	local itemLocalWeight = 0
	for _, item in pairs(availableItems) do
		local itemWeight = item:GetAttribute("Weight")
		if chosenWeight <= itemLocalWeight+itemWeight then
			chosenItem = item
			break
		else
			itemLocalWeight += itemWeight
		end
	end
	
	local item = chosenItem
	local stepCount = item.Value
	local itemName = item.Name
	
	local item = game.ReplicatedStorage.Assets.SpawnItems:FindFirstChild(itemName)
	if item then
		local posX = self.adornee.Position.X
		local posZ = self.adornee.Position.Z
		local sizeX = self.adornee.Size.X
		local sizeZ = self.adornee.Size.Z
		
		local minX,maxX = posX - sizeX/2 , posX + sizeX/2
		local minZ,maxZ = posZ - sizeZ/2 , posZ + sizeZ/2
		
		local randomPos = Vector3.new(math.random(minX*10,maxX*10)/10,self.adornee.Position.Y,math.random(minZ*10,maxZ*10)/10)
		
		local cl = item:Clone()
		cl.Parent = self.adornee
	
		if cl:GetAttribute("stepAmount") then
			cl:SetAttribute("stepAmount",stepCount)
			CollectionService:AddTag(cl,"StepGiver")
		elseif cl:GetAttribute("diamondAmount") then
			cl:SetAttribute("diamondAmount",stepCount)
			CollectionService:AddTag(cl,"DiamondGiver")
		end
		cl:SetPrimaryPartCFrame(CFrame.new(randomPos))
	end
end

function SpawnZone:LoadSpawnedItems()
	self._janitor:Add(self.adornee.ChildRemoved:Connect(function()
		self:spawnLoadItem()
	end))
	
	for x=1, self.SpawnLimit do
		spawn(function()
			self:spawnLoadItem()
		end)
	end
end


function SpawnZone:Destroy()
	self._janitor:Destroy()
end

return SpawnZone
