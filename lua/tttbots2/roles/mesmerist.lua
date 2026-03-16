--- Mesmerist: traitor who revives dead players as Thralls using a special defib.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_MESMERIST then return false end

TEAM_JESTER = TEAM_JESTER or "jesters"

local allyTeams = {
    [TEAM_TRAITOR] = true,
    [TEAM_JESTER] = true,
}

local _bh = TTTBots.Behaviors
local _prior = TTTBots.Behaviors.PriorityNodes

local bTree = {
    _prior.FightBack,
    _bh.MesmeristRevive,
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

local mesmerist = TTTBots.RoleData.New("mesmerist", TEAM_TRAITOR)
mesmerist:SetDefusesC4(false)
mesmerist:SetPlantsC4(true)
mesmerist:SetCanHaveRadar(true)
mesmerist:SetCanCoordinate(true)
mesmerist:SetStartsFights(true)
mesmerist:SetTeam(TEAM_TRAITOR)
mesmerist:SetUsesSuspicion(false)
mesmerist:SetKnowsLifeStates(true)
mesmerist:SetBTree(bTree)
mesmerist:SetAlliedTeams(allyTeams)
mesmerist:SetLovesTeammates(true)
mesmerist:SetCanSnipe(false)
mesmerist:SetCanHide(true)
TTTBots.Roles.RegisterRole(mesmerist)

return true
