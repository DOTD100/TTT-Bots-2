--- Executioner: traitor with a contract target, uses HitmanHunt behavior.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_EXECUTIONER then return false end

TEAM_JESTER = TEAM_JESTER or "jesters"

local allyTeams = {
    [TEAM_TRAITOR] = true,
    [TEAM_JESTER] = true,
}

local _bh = TTTBots.Behaviors
local _prior = TTTBots.Behaviors.PriorityNodes

local bTree = {
    _prior.FightBack,
    _bh.BurnCorpse,
    _bh.PlaceRadio,
    _bh.HitmanHunt,
    _bh.Defib,
    _bh.PlantBomb,
    _bh.UseTraitorTrap,
    _bh.InvestigateCorpse,
    _prior.Restore,
    _bh.Stalk,
    _bh.FollowPlan,
    _bh.Interact,
    _prior.Minge,
    _prior.Investigate,
    _prior.Patrol
}

local executioner = TTTBots.RoleData.New("executioner", TEAM_TRAITOR)
executioner:SetDefusesC4(false)
executioner:SetPlantsC4(true)
executioner:SetCanHaveRadar(true)
executioner:SetCanCoordinate(false)
executioner:SetStartsFights(true)
executioner:SetTeam(TEAM_TRAITOR)
executioner:SetUsesSuspicion(false)
executioner:SetKnowsLifeStates(true)
executioner:SetBTree(bTree)
executioner:SetAlliedTeams(allyTeams)
executioner:SetLovesTeammates(true)
executioner:SetCanSnipe(true)
executioner:SetCanHide(true)
TTTBots.Roles.RegisterRole(executioner)

return true
