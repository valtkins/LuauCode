local module = {}

function module:init()

	-- have a list of classes
	-- randomize them MON-FRI

	-- announce class started
	-- teleport button
	-- start minigame

	-- display grade, do rewards!

	local SchoolMinigames = require(script.Parent.SchoolMinigames)

	local amountClasses = 5
	local classList = {}

	local classes = {
		"Math",
		"Potion Brewing",
		"P.E",
		"Cooking",
		"Physics"
	}

	local function setUpClasses()

		-- so lets do... 8,9,10,11 AM and 1PM class (12PM-1PM lunch)
		classList = {}
		local day = workspace:GetAttribute("Day") 

		if day ~= "SUN" and day ~= "SAT" then

			local existingList = {}
			for _, class in pairs(classes) do
				table.insert(existingList, class)
			end
			for x=1, amountClasses do
				local chosen = math.random(1,#existingList)
				print(existingList[chosen])
				table.insert(classList,existingList[chosen])
				table.remove(existingList,chosen)
			end

			-- classList is the randomized classes for the day! :))

		end
	end

	local function changeClass()
		workspace:SetAttribute("NextClass", "None")
		if #classList >= 1 then
			local hour = workspace:GetAttribute("MilitaryHour")
			local classTimes = { 8,9,10,11,13 } -- 8am, 9am, 10am, 11am, 1pm classes

			local pos = table.find(classTimes, hour)
			if pos then
				if classList[pos+1] then
					workspace:SetAttribute("NextClass", classList[pos+1])
				else
					workspace:SetAttribute("NextClass", "None")
				end
				local chosenClass = classList[pos]
				workspace:SetAttribute('ClassName', chosenClass)
				SchoolMinigames:startMinigame(chosenClass)
				-- display the class for users!



			elseif hour == 12 then
				workspace:SetAttribute("ClassName","Lunch")
				local pos = table.find(classTimes, hour+1)
				if pos then
					workspace:SetAttribute("NextClass", classList[pos])
				end
			else
				workspace:SetAttribute("ClassName","Free Time")
				if hour < 8 then
					workspace:SetAttribute("NextClass", classList[1])
				end
			end
		else
			workspace:SetAttribute("ClassName","Free Time")
		end
	end
	
	if workspace:GetAttribute("Day") then
		workspace:GetAttributeChangedSignal("Day"):Connect(function()
			setUpClasses()
		end)
		workspace:GetAttributeChangedSignal("MilitaryHour"):Connect(function()
			changeClass()
		end)

		
		setUpClasses()
		changeClass()
	else
		warn("Workspace has no attribute 'Day' check DayNightCycle")
	end


end


return module
