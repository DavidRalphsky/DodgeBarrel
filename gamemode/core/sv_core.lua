local gameinprogress = false
local thrower		 = nil
local gamemode       = 1
local tvec1			 = Vector(0,0,0)
local tvec2			 = Vector(0,0,0)

function GM:GameInProgress()
	return gameinprogress
end

function GM:GetGamemode()
	return gamemode
end

function GM:SetThrowerPositions(k,vec)
	if k == 1 then
		tvec1 = vec
	elseif k == 2 then
		tvec2 = vec
	end
end

function GM:MakeThrowers()
	local players = player.GetAll()
	
	thrower = players[math.random(1,#players)]
	thrower:SetTeam(1)
	thrower:Spawn()
	table.RemoveByValue(players,thrower)
	
	if #players > 3 then
		thrower2 = players[math.random(1,#players)]
		thrower2:SetTeam(1)
		thrower2:Spawn()
		player.GetAll()
		
		PrintMessage(HUD_PRINTCENTER,thrower:Nick().." and "..thrower2:Nick().." are the Throwers!")
	else
	
	PrintMessage(HUD_PRINTCENTER,thrower:Nick().." is the Thrower!")
	end
end

function GM:StopTimers()
	timer.Destroy("PlatformTimer")
	timer.Destroy("PowerupTimer")
end

local barrels = {}
function GM:SpawnBarrels()
	for i=1, 15 do
		local barrel = ents.Create("db_barrel")
		barrel:SetPos(Vector(-287.074890 + (i*50), -194.359650, 64.031250))
		barrel:Spawn()
		
		barrels[#barrels+1] = barrel
	end
end

local platformprops = {}
function GM:SpawnPlatform()
	for k=1,12 do
		for i=1, 14 do
			local platform = ents.Create("prop_physics")
			platform:SetModel("models/hunter/plates/plate2x2.mdl")
			platform:SetPos(Vector(520 - ((k-1)*95), 1280 - ((i-1)*95), 150))
			platform:Spawn()
			platform:SetMoveType(MOVETYPE_NONE)
			
			local phys = platform:GetPhysicsObject()
			if (IsValid(phys)) then phys:EnableMotion(false) end
			
			platformprops[#platformprops+1] = platform
		end
	end
end

local powerupvecs = {Vector(-275, 650, 100), Vector(275, 650, 100)}
function GM:StartGame()
	if GAMEMODE:GameInProgress() == true then return end
	gameinprogress = true
	
	game.CleanUpMap()
	
	RunConsoleCommand("phys_timescale", 1)
	
	GAMEMODE:SpawnBarrels()
	
	if GAMEMODE:GetGamemode() == 3 then 
		GAMEMODE:SpawnPlatform() 
		timer.Create("PlatformTimer", 1, 168, function() 
											local prop = table.Random(platformprops)
											if !IsValid(prop) then return end
											prop:SetColor(Color(255,0,0))
											timer.Simple(1, function()
																if !IsValid(prop) then return end
																prop:Remove()
																table.RemoveByValue(platformprops,prop)
																end)
											end)
	end
	
	--[[timer.Create("PowerupTimer", 15, 0, function() 
											local powerup = ents.Create("db_powerup")
											powerup:SetPos(table.Random(powerupvecs))
											powerup:Spawn()
											
											timer.Simple(10, function() if IsValid(powerup) then powerup:Remove() end end)
											end)--]]
	
	for k,v in pairs(player.GetAll()) do 
		v:SetTeam(2) 
		v:Spawn() 
		v.HasPowerup = false 
	end

	GAMEMODE:MakeThrowers()	
end

function GM:StopGame()
	PrintMessage(HUD_PRINTCENTER,"Game stopped!")
	gameinprogress = "stop"
	GAMEMODE:StopTimers()
end

function GM:GravGunPunt(ply,_ent)
	if !IsValid(ply) then return end
	
	if _ent:GetModel()=="models/props_c17/oildrum001_explosive.mdl" then
		if !_ent.Hit then 
			_ent.Hit = true 
		end
		
		local ent = ply:GetEyeTrace().Entity
		
		if !IsValid(ent) or ent:GetModel()!="models/props_c17/oildrum001_explosive.mdl" then ent = _ent end

		local phys = ent:GetPhysicsObject()
		if ply:Team()==2 then
			phys:ApplyForceCenter(ply:GetAimVector()*35000)
		else
			phys:ApplyForceCenter(ply:GetAimVector()*25000)
		end

		ent.PuntTimes = ent.PuntTimes + 1
		ent.HitBy = ply 
		
		--ent:SetModelScale(1+ent.PuntTimes*1.1)
		--local mesh = ent:GetPhysicsObject():GetMesh()
		--ent:PhysicsFromMesh(mesh)
	end
	
	return true
end

function GM:GravGunPickupAllowed(ply,ent)
	if ply:Team()==2 then return false end
	if ent.Hit then return false end
	
	return true
end

function GM:Think()
	if GAMEMODE:GameInProgress() == "stop" then return end
		
	if GAMEMODE:GameInProgress() then
		if GAMEMODE:GetGamemode() == 3 then
			for k,v in pairs(player.GetAll()) do
				if v:GetPos().z < 70 and v:Team() == 2 then
					v:Kill()
				end
			end
		end
	
		if team.NumPlayers(1) == 0 then
			RunConsoleCommand("phys_timescale", 0)
			PrintMessage(HUD_PRINTCENTER,"The Throwers lose!")
			
			timer.Simple(5, function() GAMEMODE:StartGame() end)
			gameinprogress = false
			GAMEMODE:StopTimers()
		end
		
		if team.NumPlayers(2) == 0 then
			RunConsoleCommand("phys_timescale", 0)
			PrintMessage(HUD_PRINTCENTER,"Throwers win!")
			
			timer.Simple(5, function() GAMEMODE:StartGame() end)
			gameinprogress = false
			GAMEMODE:StopTimers()
		end
		
		for k,v in pairs(barrels) do
			if !IsValid(v) then
				table.RemoveByValue(barrels,v)
			end
		end
		
		if table.Count(barrels) == 0 then
			if GAMEMODE:GetGamemode() == 2 then PrintMessage(HUD_PRINTCENTER,"The Throwers lose!") end			
			if GAMEMODE:GetGamemode() != 2 then GAMEMODE:SpawnBarrels() return end

			timer.Simple(5, function() GAMEMODE:StartGame() end)
			gameinprogress = false			
		end
	end 
end

concommand.Add("db_startgame", function(ply,cmd,args)
	if !ply:IsAdmin() then print("You must be an admin to use that command!") return end
	
	if !GAMEMODE:GameInProgress() then
		print("Starting game!")
		GAMEMODE:StartGame()
	
	else
		print("Game already in progress!")
	end
end)

concommand.Add("db_setgamemode", function(ply,cmd,args)
	if !ply:IsAdmin() then print("You must be an admin to use that command!") return end
	if tonumber(args[1]) == NULL or tonumber(args[1]) > 3 or tonumber(args[1]) < 0 then return end 	
	
	gamemode = tonumber(args[1])
	print("Gamemode set to "..args[1])
end)
