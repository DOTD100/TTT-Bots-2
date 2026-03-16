--- Speedrunner: public evil with enhanced speed, must kill everyone before timer runs out.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_SPEEDRUNNER then return false end

TEAM_SPEEDRUNNER = TEAM_SPEEDRUNNER or "speedrunner"
TEAM_JESTER = TEAM_JESTER or "jesters"

local allyTeams = {
    [TEAM_SPEEDRUNNER] = true,
    [TEAM_JESTER] = true,
}

local _bh = TTTBots.Behaviors
local _prior = TTTBots.Behaviors.PriorityNodes

local bTree = {
    _prior.FightBack,
    _bh.FuseHunt,
    _bh.Stalk,
    _prior.Restore,
    _prior.Minge,
    _prior.Investigate,
    _prior.Patrol
}

local speedrunner = TTTBots.RoleData.New("speedrunner", TEAM_SPEEDRUNNER)
speedrunner:SetDefusesC4(false)
speedrunner:SetPlantsC4(false)
speedrunner:SetCanHaveRadar(true)
speedrunner:SetCanCoordinate(false)
speedrunner:SetStartsFights(true)
speedrunner:SetTeam(TEAM_SPEEDRUNNER)
speedrunner:SetUsesSuspicion(false)
speedrunner:SetKnowsLifeStates(true)
speedrunner:SetBTree(bTree)
speedrunner:SetAlliedTeams(allyTeams)
speedrunner:SetLovesTeammates(true)
speedrunner:SetCanSnipe(true)
speedrunner:SetCanHide(false)
TTTBots.Roles.RegisterRole(speedrunner)

return true
