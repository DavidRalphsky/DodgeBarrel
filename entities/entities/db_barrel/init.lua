AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/oildrum001_explosive.mdl")

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	self:SetLagCompensated(true) -- I don't know if this does anything. Could be a placebo.

	if (SERVER) then self:PhysicsInit(SOLID_VPHYSICS) end

	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then phys:Wake()	end
	
	self:EnableCustomCollisions(true)
	self.PuntTimes = 0
	self.HitBy = nil
end

local function Explode(self,mag)
	local boom = ents.Create("env_explosion")
	boom:SetPos(self:GetPos())
	boom:Spawn()
	boom:SetKeyValue("iMagnitude", mag)
	boom:Fire("Explode", "0", "0")
	boom.HitBy = self.HitBy	
	self:Remove()
end

local elev = 150
function ENT:PhysicsCollide(data, phys)	
	if GAMEMODE:GetGamemode() == 3 then elev = 200 end
	if self.Hit then
		if data.HitPos.z < elev then
			self.Hit = false
			Explode(self,"150")
		end
		
		if data.HitPos.z > elev and data.HitEntity:GetModel() == "models/props_c17/oildrum001_explosive.mdl" then
			PrintMessage(HUD_PRINTCENTER,"INTERCEPTION") -- NOICE
			self:EmitSound("physics/metal/metal_sheet_impact_hard2.wav")
		end
	end
end

function ENT:OnTakeDamage(dmg)	
	if GAMEMODE:GetGamemode() == 2 and dmg:GetAttacker():IsPlayer() and self:GetPos().z > 150 then
		Explode(self,"0") -- Blow up, but don't kill anyone pls
	end
end
