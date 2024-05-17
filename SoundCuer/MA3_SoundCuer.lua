-------------- Returns Numerrator for Numbering things (e.i. 0001 instead of 1) --------------
local function getNumerator(i)
	local numerator = tostring(i)
	for a = 1, 4-string.len(tostring(i)) do
		numerator = "0"..numerator
	end
	numerator = numerator..". "
	
	return numerator
end

-------------- First MsgBox: Choice of further Action
local function openMsgBoxSelection(sounds)
	local inputs = {
		{name = "1. Store in Sequence", value = "1", whiteFilter = "0123456789"},
		{name = "2. Sequence name"}
	}

	local states = {
		--{name = "State A", state = true, group = 1}
		
	}
	
	local selectors = {
        { name="Type of Selection", selectedValue=1, values={["All available"]=1,["Range"]=2,["Self"]=3}, type=1}
    }


	local msgOptions = {
			title = "Please select your configuration for the Selection",
			commands = {{value = 0, name = "Cancel"}, {value = 1, name = "Ok"}},
			states = states,
			inputs = inputs,
			selectors = selectors,
			backColor = "Global.Default",
			icon = "logo_small",
			titleTextColor = "Global.Text",
			messageTextColor = "Global.Text"
		}
		
		
	-- open messagebox:
	local resultTable = MessageBox(msgOptions)
	
	return resultTable
end

-------------- All Sounds Selection --------------
local function openMsgBoxAll(sounds)
	local states = {
		--{name = "State A", state = true, group = 1}	
	}
	
	for i = 1, #sounds:Children() do
		
		local sound = sounds:Children()[i]
		
		local soundName = sound["Name"]
		local soundNumber = sound["No"]
				
		table.insert(states, {name = getNumerator(i)..soundName, state = true, group = soundNumber})
		
	end

	local msgOptions = {
			title = "Customize your Selection",
			commands = {{value = 0, name = "Cancel"}, {value = 1, name = "Ok"}},
			states = states,
			inputs = inputs,
			selectors = selectors,
			backColor = "Global.Default",
			icon = "logo_small",
			titleTextColor = "Global.Text",
			messageTextColor = "Global.Text"
		}
		
	-- open messagebox:
	local resultTable = MessageBox(msgOptions)
	
	return resultTable
end

-------------- Range Sound Selection --------------
local function openMsgBoxRange(sounds)
	local inputs = {
		{name = "1. Start", value = "1", whiteFilter = "0123456789"},
		{name = "2. End", value = "2", whiteFilter = "0123456789"}
	}
	
	local states = {
		--{name = "State A", state = true, group = 1}	
	}

	local msgOptions = {
			title = "Set Range",
			commands = {{value = 0, name = "Cancel"}, {value = 1, name = "Ok"}},
			states = states,
			inputs = inputs,
			selectors = selectors,
			backColor = "Global.Default",
			icon = "logo_small",
			titleTextColor = "Global.Text",
			messageTextColor = "Global.Text"
		}
		
	-- open messagebox:
	local rangeResultTable = MessageBox(msgOptions)
		
	---------- Second Part - Range Sound Selection ----------
	
	local states = {
		--{name = "State A", state = true, group = 1}	
	}
	
-- Add Sounds to Selection/States
	for i = 1, #sounds:Children() do
		local sound = sounds:Children()[i]
		
		local soundName = sound["Name"]
		local soundNumber = sound["No"]
		
		if tonumber(rangeResultTable.inputs['1. Start']) <= i and i <= (tonumber(rangeResultTable.inputs['2. End'])) then
			table.insert(states, {name = getNumerator(i)..soundName, state = true, group = soundNumber})
		else
			table.insert(states, {name = getNumerator(i)..soundName, state = false, group = soundNumber})
		end
	end


	local msgOptions = {
			title = "Customize your Selection",
			commands = {{value = 0, name = "Cancel"}, {value = 1, name = "Ok"}},
			states = states,
			--inputs = inputs,
			selectors = selectors,
			backColor = "Global.Default",
			icon = "logo_small",
			titleTextColor = "Global.Text",
			messageTextColor = "Global.Text"
		}
		
	-- open messagebox:
	local selectionResultTable = MessageBox(msgOptions)
	
	return selectionResultTable

end

local function openMsgBoxSelf(sounds)
	local states = {
		--{name = "State A", state = true, group = 1}	
	}
	
	for i = 1, #sounds:Children() do
		local sound = sounds:Children()[i]
		
		local soundName = sound["Name"]
		local soundNumber = sound["No"]

		table.insert(states, {name = getNumerator(i)..soundName, state = false, group = soundNumber})
	end

	local msgOptions = {
			title = "Customize your Selection",
			commands = {{value = 0, name = "Cancel"}, {value = 1, name = "Ok"}},
			states = states,
			inputs = inputs,
			selectors = selectors,
			backColor = "Global.Default",
			icon = "logo_small",
			titleTextColor = "Global.Text",
			messageTextColor = "Global.Text"
		}
		
	-- open messagebox:
	local selectionResultTable = MessageBox(msgOptions)
	
	return selectionResultTable
end


-------------- Sequence Creator based on previous Selection --------------
local function createSequence(seqNum, sounds, resultTable, seqName)

	if DataPool().Sequences[seqNum] == nil then
		Cmd("Store Sequence "..seqNum.." /CreateSecondCue")
		Cmd("Label Sequence "..seqNum.." "..seqName)
	else 
		
		Cmd("Delete Sequence "..seqNum)
		Cmd("Store Sequence "..seqNum.." /CreateSecondCue")
		Cmd("Label Sequence "..seqNum.." "..seqName)
	end
	
	
	Cmd("set seq "..seqNum.." cue \"OffCue\" property \"Command\" \"Off Sound 1 Thru\"")
	--DataPool().Sequences:Insert(seqNum)
	
	for i = 1, #sounds:Children() do
		Printf("Iteration: "..i)
		
		local sound = sounds:Children()[i]
		local state = resultTable.states[sound["Name"]]
		
		Printf("State: "..tostring(resultTable.states[sound["Name"]]))
		
		if tostring(state) == "true" then
			if DataPool().Sequences[seqNum][i+2] == nil then
				Cmd("Store Sequence "..seqNum.." Cue "..i.." /CreateSecondCue")
			end	
			Cmd("set seq "..seqNum.." cue "..i.." property \"Command\" \"Off Sound 1 Thru; Go+ Sound "..sound["No"].."\"")
			Cmd("set seq "..seqNum.." cue "..i.." property \"Name\" \""..sound["Name"]:gsub("%[",""):gsub("%]","").."\"")
		end
	end
	
	sound2 = sounds:Children()[1]
	
	if tostring(resultTable.states[sound2["Name"]]) == "false" then
	Printf("check2")
		Cmd("Delete Sequence "..seqNum.." Cue 1")
	end
end

-------------- Sequence Override MsgBox when Sequence already exists --------------
local function openMsgBoxOverride()

	local msgOptions = {
			title = "Attention: Sequence is not empty",
			message = "The chosen Sequence is not empty. Would you like to override or change Sequence?",
			commands = {{value = 2, name = "Cancel"},{value = 0, name = "Override"}, {value = 1, name = "Change Sequence"}},
			states = states,
			inputs = inputs,
			selectors = selectors,
			backColor = "Global.Default",
			-- timeout = 10000, --milliseconds
			-- timeoutResultCancel = false,
			icon = "logo_small",
			titleTextColor = "Global.Text",
			messageTextColor = "Global.Text"
		}
	
	local resultTable = MessageBox(msgOptions)
	return resultTable
	
end

-------------- Parse Sound Choose Variant User Input --------------
local function chooseSounds(resultTable, sounds)

	if "1" == tostring(resultTable.selectors['Type of Selection']) then
		
		local selAll = openMsgBoxAll(sounds)
		
		if tonumber(selAll.result) == 0 then
			return
		end
		
		local seqNum = tonumber(resultTable.inputs['1. Store in Sequence'])
		local seqName = "\""..tostring(resultTable.inputs['2. Sequence name']).."\""
		
		createSequence(seqNum, sounds, selAll, seqName)
		
	elseif tostring(resultTable.selectors['Type of Selection']) == "2" then
			
		local selRange = openMsgBoxRange(sounds)
		
		if tonumber(selRange.result) == 0 then
			return
		end
		
		local seqNum = tonumber(resultTable.inputs['1. Store in Sequence'])
		local seqName = "\""..tostring(resultTable.inputs['2. Sequence name']).."\""		
		
		createSequence(seqNum, sounds, selRange, seqName)
			
	else 
		
		local selSelf = openMsgBoxSelf(sounds)
		
		if tonumber(selSelf.result) == 0 then
			return
		end

		local seqNum = tonumber(resultTable.inputs['1. Store in Sequence'])
		local seqName = "\""..tostring(resultTable.inputs['2. Sequence name']).."\""
		Printf("Sequence Number: "..seqNum)
	
		createSequence(seqNum, sounds, selSelf, seqName)
		
	end 

end

local function debugDump()
-------------- Start of Dump --------------
	Printf("===============Start of Dump=================")
	ShowData():Dump()
	Printf("-----------------------")
	--local sounds = ShowData()["MediaPools"]["Sounds"]
	sounds:Dump()
	Printf("-----------------------")
	
	for i = 1, #sounds:Children() do
		Printf("Iteration: "..i)
		
		local cSound = sounds:Children()[i]
		
		Echo("Name: "..cSound["Name"])
		Echo("Number: "..cSound["No"])
		
		Printf(" ")
--		Printf(cSound:Dump())
	end
	
	Printf(" ")
	--Printf(" ")
	--Printf("-------------------")
	--DataPool().Sequences[1]:Dump()
	Printf("================End of Dump==================")
-------------- End of Dump --------------
end

local function main()
	Cmd("clearall")
	
	--debugDump() --Only for Debugging
	
	local sounds = ShowData()["MediaPools"]["Sounds"]
		
	::changeSequence::
	local resultTable = openMsgBoxSelection(sounds)
	
	if tonumber(resultTable.result) == 0 then
		return
	end
	
	if DataPool().Sequences[tonumber(resultTable.inputs['1. Store in Sequence'])] == nil then
		
		chooseSounds(resultTable, sounds)
		return main
		
	else
		-------------- Manage Sequence Override --------------
		local msgOverride = openMsgBoxOverride()
		
		if tonumber(msgOverride.result) == 2 then
			return
		end
		
		if tonumber(msgOverride.result) == 1 then
			goto changeSequence
		end
		
		if tonumber(msgOverride.result) == 0 then
			chooseSounds(resultTable, sounds)
		end
		
	end
	
	Printf("Success!")
end

return main
