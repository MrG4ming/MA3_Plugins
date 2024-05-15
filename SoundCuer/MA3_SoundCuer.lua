local function openMsgBox(sounds)
	-- create inputs:
	local inputs = {
		{name = "Store in Sequence", value = "1", whiteFilter = "0123456789"}
	}

	-- create states
	local states = {
		--{name = "State A", state = true, group = 1}
	}

	for i = 1, #sounds:Children() do
--		Printf("Iteration: "..i)
		
		local sound = sounds:Children()[i]
		
		local soundName = sound["Name"]
		local soundNumber = sound["No"]

		table.insert(states, {name = soundName, state = true, group = soundNumber})
		
--		Echo("Name: "..sound["Name"])
--		Echo("Number: "..sound["No"])
		
--		Printf(" ")
--		Printf(cSound:Dump())
	end


	local msgOptions = {
			title = "Please select sounds for Cue",
			commands = {{value = 0, name = "Cancel"}, {value = 1, name = "Ok"}},
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
		
	-- open messagebox:
	local resultTable = MessageBox(msgOptions)
	
	return resultTable
end


local function createSequence(seqNum, sounds, resultTable)
	--Printf(tostring(resultTable.states[1]))
	--Printf("Name of sequence 1: " .. DataPool().Sequences[seqNum].Name)
	if DataPool().Sequences[seqNum] == nil then
		Printf("Is nil")
		Cmd("Store Sequence "..seqNum.." /CreateSecondCue")
	end
	Cmd("set seq "..seqNum.." cue \"OffCue\" property \"Command\" \"Off Sound 1 Thru\"")
	--DataPool().Sequences:Insert(seqNum)
	
	for i = 1, #sounds:Children() do
		Printf("Iteration: "..i)
		
		local sound = sounds:Children()[i]
		local state = resultTable.states[sound["Name"]]
		
		Printf("State: "..tostring(resultTable.states[sound["Name"]]))
		
		if tostring(state) then
			if DataPool().Sequences[seqNum][i+2] == nil then
				Cmd("Store Sequence "..seqNum.." Cue "..i.." /CreateSecondCue")
			end
			Cmd("set seq "..seqNum.." cue "..i.." property \"Command\" \"Off Sound 1 Thru; Go+ Sound "..sound["No"].."\"")
			Cmd("set seq "..seqNum.." cue "..i.." property \"Name\" \""..sound["Name"]:gsub("%[",""):gsub("%]","").."\"")
		end
	end
end


local function main()
	Cmd("clearall")
	
	local sounds = ShowData()["MediaPools"]["Sounds"]
	
	-- start of dump
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
	Printf(" ")
	Printf("-------------------")
	--DataPool().Sequences[1]:Dump()
	Printf("================End of Dump==================")
	-- end of dump
	
	
	local resultTable = openMsgBox(sounds)
	
	-- print results:
	Printf("Success = "..tostring(resultTable.success))
	--exit on Cancel:
	Printf("Result = "..resultTable.result)
	if tonumber(resultTable.result) == 0 then
		return
	end
	--Printf("States = "..tostring(resultTable.states[1]))
	
--	for k,v in pairs(resultTable.inputs) do
--        Printf("Input '%s' = '%s'",k,v)
--    end
	
	--local seqNum = 1
	local seqNum = tonumber(resultTable.inputs['Store in Sequence'])
	Printf("Sequence Number: "..seqNum)
	
	createSequence(seqNum, sounds, resultTable)
	
end

return main
