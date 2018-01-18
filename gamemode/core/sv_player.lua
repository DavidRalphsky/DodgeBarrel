function GM:PlayerInitialSpawn(ply)
	if GAMEMODE:GameInProgress() then ply:SetTeam(3) return false end

	if #player.GetAll() > 1 then
		ply:SetTeam(2)
		GAMEMODE:StartGame()
	end
end

function GM:PlayerDisconnected(ply)
	if #player.GetAll() < 2 then
		GAMEMODE:StopGame()
	end
end

function GM:PlayerSpawn(ply)
	ply:UnSpectate()
	ply:StripWeapons()
	ply:StripAmmo()
	ply:SetWalkSpeed(200)
	ply:SetRunSpeed(300)
	ply:SetJumpPower(200)
	
	ply:SetNoCollideWithTeammates(true)
	if (ply:Team() == 1) then
		-- Thrower
		ply:SetHealth(1)
		ply:SetModel("models/player/combine_super_soldier.mdl")
		ply:Give("weapon_physcannon")
		
		ply:SetPos(Vector(0, -300+(team.NumPlayers(1)*-100), 100))
		ply:SetEyeAngles(Angle(0,90,0))
		
	elseif(ply:Team() == 2) then
		-- Players
		ply:SetPos(ply:GetPos() + Vector(0,0,200))
		ply:SetModel("models/player/group01/male_0"..math.random(1,9)..".mdl")
		
		if GAMEMODE:GetGamemode() != 2 then
			ply:Give("weapon_physcannon")
		else
			ply:Give("weapon_357")
			ply:SetAmmo(100, "357")
		end
	
	elseif ply:Team() == 3 then
		ply:Spectate(OBS_MODE_ROAMING)
		ply:SetPos(Vector(0, 900, 500))
	end
end

function GM:PlayerHurt(ply,att)
	if IsValid(ply) then
			
		if ply:Team()==1 then
			ply:EmitSound("npc/metropolice/die"..math.random(1, 4)..".wav")
		else
			ply:EmitSound("vo/npc/male01/pain0"..math.random(1,9)..".wav")
		end
		
		local hitby = att.HitBy
	end
end

function GM:PlayerShouldTakeDamage(ply,ent)
	if (IsValid(ply) and IsValid(ent) and ent:IsPlayer()) then return false end
	return true
end

function GM:PostPlayerDeath(ply)
	ply:SetTeam(3)
	timer.Simple(3, function() if IsValid(ply) then ply:Spawn() end end)
end

function GM:PlayerDeathThink(ply)
	return false
end

function GM:CanPlayerSuicide()
	return false
end

function GM:PlayerNoClip()
	return false
end