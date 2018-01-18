AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	local powerups = {"jump","speed","bullettime"}--,"stealth"}
	self.Powerup = table.Random(powerups)
	
	if self.Powerup == "jump" then
		self:SetModel("models/props_junk/Shoe001a.mdl")
		self:SetModelScale(5)
		
	elseif self.Powerup == "speed" then
		self:SetModel("models/props_junk/garbage_coffeemug001a.mdl")
		self:SetAngles(Angle(30,0,0))
		self:SetModelScale(5)
		
	elseif self.Powerup == "bullettime" then
		self:SetModel("models/seagull.mdl")
		self:SetSequence("idle01")
		self:SetModelScale(3)
		
	elseif self.Powerup == "stealth" then
		self:SetModel("models/props_junk/wood_crate001a.mdl")
		self:SetModelScale(1.5)
	end
	
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:DrawShadow(false)
	
	print(self:LocalToWorld(Vector(0,0,-20)))
	self.Ply = nil
end

function ENT:Think()
	self:SetAngles(self:GetAngles() + Angle(0,FrameTime() * 300,0))
	
	for k,v in pairs(ents.FindByClass("Player")) do
		if (!IsValid(v) or !v:Alive()) then return end
		
		if v:GetPos():Distance(self:LocalToWorld(Vector(0,0,-20))) < 10 then
			print("what",v,v:GetPos():Distance(self:LocalToWorld(Vector(0,0,-20))),self,self:LocalToWorld(Vector(0,0,-20)))
			self.Ply = v
		end
	end

	if IsValid(self.Ply) and !self.Ply.HasPowerup then
		self.Ply.HasPowerup = true
		if self.Powerup == "jump" then
			self.Ply:ChatPrint("You got the jump powerup!")
			self.Ply:SetJumpPower(600)
			timer.Simple(5, function() self.Ply:SetJumpPower(200) self.Ply.HasPowerup = false end)	
		
		elseif self.Powerup == "speed" then
			self.Ply:ChatPrint("You got the speed powerup!")
			self.Ply:SetWalkSpeed(400)
			self.Ply:SetRunSpeed(500)
			timer.Simple(5, function() self.Ply:SetWalkSpeed(200) self.Ply:SetRunSpeed(300) self.Ply.HasPowerup = false end)	
		
		elseif self.Powerup == "bullettime" then
			self.Ply:ChatPrint("You got the bullet time powerup!")
			RunConsoleCommand("host_timescale",0.4)
			timer.Simple(3, function() RunConsoleCommand("host_timescale",1) self.Ply.HasPowerup = false end)	
			
		end

		self:EmitSound("items/battery_pickup.wav")
		self:SetRenderMode(RENDERMODE_NONE)
		timer.Simple(5.1, function() self:Remove() end)
	end
end
