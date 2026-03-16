--- Hitman: traitor with an assigned contract target to hunt.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_HITMAN then return false end

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

local hitman = TTTBots.RoleData.New("hitman", TEAM_TRAITOR)
hitman:SetDefusesC4(false)
hitman:SetPlantsC4(true)
hitman:SetCanHaveRadar(true)
hitman:SetCanCoordinate(false)
hitman:SetStartsFights(true)
hitman:SetTeam(TEAM_TRAITOR)
hitman:SetUsesSuspicion(false)
hitman:SetKnowsLifeStates(true)
hitman:SetBTree(bTree)
hitman:SetAlliedTeams(allyTeams)
hitman:SetLovesTeammates(true)
hitman:SetCanSnipe(true)
hitman:SetCanHide(true)
TTTBots.Roles.RegisterRole(hitman)

return true
