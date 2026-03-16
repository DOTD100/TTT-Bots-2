--- Hidden: invisible solo predator that hunts with a knife.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_HIDDEN then return false end

TEAM_HIDDEN = TEAM_HIDDEN or "hidden"
TEAM_JESTER = TEAM_JESTER or "jesters"

local allyTeams = {
    [TEAM_HIDDEN] = true,
    [TEAM_JESTER] = true,
}

local _bh = TTTBots.Behaviors
local _prior = TTTBots.Behaviors.PriorityNodes

local bTree = {
    _prior.FightBack,
    _bh.HiddenHunt,
    _bh.Stalk,
    _prior.Minge,
    _prior.Patrol
}

local hidden = TTTBots.RoleData.New("hidden", TEAM_HIDDEN)
hidden:SetDefusesC4(false)
hidden:SetPlantsC4(false)
hidden:SetCanHaveRadar(false)
hidden:SetCanCoordinate(false)
hidden:SetStartsFights(true)
hidden:SetTeam(TEAM_HIDDEN)
hidden:SetUsesSuspicion(false)
hidden:SetKnowsLifeStates(true)
hidden:SetAutoSwitch(false)
hidden:SetBTree(bTree)
hidden:SetAlliedTeams(allyTeams)
hidden:SetLovesTeammates(false)
hidden:SetCanSnipe(false)
hidden:SetCanHide(true)
TTTBots.Roles.RegisterRole(hidden)

return true
