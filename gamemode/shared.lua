GM.Name = "DodgeBarrel"
GM.Author = "David Ralphsky"

DeriveGamemode("base")

function GM:Initialize()
	self.BaseClass.Initialize(self)
end


team.SetUp(1, "Throwers", Color( 255, 0, 0 ))
team.SetUp(2, "Punters", Color( 0, 0, 255 ))