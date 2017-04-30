AddCSLuaFile("cl_init.lua")

local function addResourceDir(path)
	local files, folders = file.Find(path .. "/*", "GAME")

	for k, v in pairs(files) do
		resource.AddFile(path .. "/" .. v)

		if string.EndsWith(v, ".mdl") then
			util.PrecacheModel(path .. "/" .. v)
		elseif string.EndsWith(v, ".wav") then
			Sound(path .. "/" .. v)
		end
	end

	for k, v in pairs(folders) do
		addResourceDir(path .. "/" .. v)
	end
end

addResourceDir("sound/pikmin")
addResourceDir("models/pikmin")
addResourceDir("materials/models/pikmin")
addResourceDir("materials/pikmin")

for k, v in pairs(file.Find("models/weapons/v_olimar.*", "GAME")) do
	resource.AddFile("models/weapons/" .. v)
	util.PrecacheModel("weapons/" .. v) --Precache all sounds
end

for k, v in pairs(file.Find("models/weapons/w_olimar.*", "GAME")) do
	resource.AddFile("models/weapons/" .. v)
	util.PrecacheModel("weapons/" .. v) --Precache all sounds
end

resource.AddFile("materials/VGUI/entities/pikmin.vtf")
resource.AddFile("materials/VGUI/entities/pikmin.vmt")
resource.AddFile("materials/weapons/pikmincommand.vtf")
resource.AddFile("materials/weapons/pikmincommand.vmt")

local function DontToolMe(ply, tr, tool)
	if tr and IsValid(tr.Entity) and tr.Entity:isPikmin() then
		if tool == "duplicator" then return false end
	end
end

--dunno why this is a thing
hook.Add("CanTool", "DontDupeOnions", DontToolMe)

local function DontPickMeUp(ply, ent)
	if IsValid(ent) and ent:isPikmin() then return false end
end

hook.Add("GravGunPickupAllowed", "DontPickupOnions", DontPickMeUp)

local function PikGravPunt(ply, ent)
	if (ent:GetClass() == "pikmin") then
		ent:SetAnim("thrown")
		ply:EmitSound("pikmin/throw.wav")
		ent.JustThrown = true --Going to check if they should follow us while in the air...
		ent.ShouldSpin = true
		ent.CanMove = false

		timer.Simple(2.5, function()
			if (ValidEntity(ent)) then
				ent.CanMove = true
				ent.JustThrown = false
			end
		end)
	end
end

hook.Add("GravGunPunt", "ThrowAnimOnPunt", PikGravPunt)

local function PikDontHitPlayer(ply, thing)
	if (thing:GetClass() == "pikmin") then return false end

	return true
end

--Pikmin are chargin' me!
hook.Add("PlayerShouldTakeDamage", "OMGPIKMINDONTHURTMEH", PikDontHitPlayer)

local function PikEntityRemoved(ent)
	if (ent:IsNPC()) then
		for k, v in pairs(ents.FindByClass("pikmin")) do
			if (v.Attacking and v.Victim == ent) then
				local quickpos = (v:GetPos() + Vector(0, 0, 7.5))
				v.Attacking = false
				v.AtkTarget = nil
				v:SetParent()
				v:SetPos(quickpos)
				v.Victim = nil

				if (v.Dismissed) then
					v:SetAnim("dismissed")
				end
			end
		end
	end
end

hook.Add("EntityRemoved", "PikEntityRemoved", PikEntityRemoved)