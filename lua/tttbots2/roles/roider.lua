--- Roider: traitor that can only deal damage with melee (crowbar).

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_ROIDER then return false end

local _bh = TTTBots.Behaviors
local _prior = TTTBots.Behaviors.PriorityNodes

local RoiderFightBack = {
    _bh.ClearBreakables,
    _bh.RoiderAttack,
}

local bTree = {
    RoiderFightBack,
    _prior.Restore,
    _bh.UseTraitorTrap,
    _bh.Stalk,
    _bh.Interact,
    _prior.Investigate,
    _prior.Minge,
    _bh.Decrowd,
    _prior.Patrol,
}

local roider = TTTBots.RoleData.New("roider", TEAM_TRAITOR)
roider:SetDefusesC4(false)
roider:SetPlantsC4(false)
roider:SetStartsFights(true)
roider:SetTeam(TEAM_TRAITOR)
roider:SetUsesSuspicion(false)
roider:SetBTree(bTree)
roider:SetCanHaveRadar(false)
roider:SetCanCoordinate(true)
roider:SetAlliedTeams({ [TEAM_TRAITOR] = true, [TEAM_JESTER or "jesters"] = true })
roider:SetCanSnipe(false)
roider:SetCanHide(true)
roider:SetLovesTeammates(true)
roider:SetAutoSwitch(false)
roider:SetPreferredWeapon("weapon_zm_improvised")
TTTBots.Roles.RegisterRole(roider)

return true
