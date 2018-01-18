ENT.Base = "base_point"
ENT.Type = "point"

function ENT:KeyValue(k,v)
	local vec     = string.Explode(",", v)
	local realvec = Vector(vec[1],vec[2],vec[3])
	
	if k == "thrower1" then
		GAMEMODE:SetThrowerPositions(1,realvec)
	end
	
	if k == "thrower2" then
		GAMEMODE:SetThrowerPositions(2,realvec)
	end
end