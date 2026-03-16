--- Bandit: lone wolf, last man standing. Everyone is the enemy.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_BANDIT then return false end

TEAM_BANDIT = TEAM_BANDIT or "bandit"
TEAM_JESTER = TEAM_JESTER or "jesters"

local allyTeams = {
    [TEAM_BANDIT] = true,
    [TEAM_JESTER] = true,
}

local _bh = TTTBots.Behaviors
local _prior = TTTBots.Behaviors.PriorityNodes
local bTree = {
    _prior.FightBack,
    _bh.Defuse,
    _bh.Defib,
    _prior.Restore,
    _bh.Stalk,
    _bh.InvestigateCorpse,
    _prior.Minge,
    _prior.Investigate,
    _prior.Patrol
}

local bandit = TTTBots.RoleData.New("bandit", TEAM_BANDIT)
bandit:SetDefusesC4(true)
bandit:SetPlantsC4(false)
bandit:SetCanCoordinate(false)
bandit:SetCanHaveRadar(false)
bandit:SetStartsFights(true)
bandit:SetUsesSuspicion(false)
bandit:SetTeam(TEAM_BANDIT)
bandit:SetBTree(bTree)
bandit:SetKnowsLifeStates(true)
bandit:SetAlliedTeams(allyTeams)
bandit:SetCanSnipe(true)
bandit:SetCanHide(true)
bandit:SetLovesTeammates(true)
TTTBots.Roles.RegisterRole(bandit)

return true
