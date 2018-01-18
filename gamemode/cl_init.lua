function GM:HUDShouldDraw(name)
	if (name == "CHudDamageIndicator" ) then
		return false
	end
	return true
end