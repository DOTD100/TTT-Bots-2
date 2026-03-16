--- Necromancer: independent role that revives dead players as zombies.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_NECROMANCER then return false end

TEAM_JESTER = TEAM_JESTER or "jesters"
TEAM_NECRO = TEAM_NECRO or "necros"

local allyTeams = {
    [TEAM_NECRO] = true,
    [TEAM_JESTER] = true,
}

local _bh = TTTBots.Behaviors
local _prior = TTTBots.Behaviors.PriorityNodes

local bTree = {
    _prior.FightBack,
    _bh.NecroRevive,
    _prior.Restore,
    _bh.Stalk,
    _prior.Minge,
    _prior.Investigate,
    _prior.Patrol
}

local necromancer = TTTBots.RoleData.New("necromancer", TEAM_NECRO)
necromancer:SetDefusesC4(false)
necromancer:SetPlantsC4(false)
necromancer:SetCanCoordinate(false)
necromancer:SetStartsFights(true)
necromancer:SetTeam(TEAM_NECRO)
necromancer:SetUsesSuspicion(false)
necromancer:SetKnowsLifeStates(true)
necromancer:SetBTree(bTree)
necromancer:SetAlliedTeams(allyTeams)
necromancer:SetLovesTeammates(true)
necromancer:SetCanSnipe(false)
necromancer:SetCanHide(true)
TTTBots.Roles.RegisterRole(necromancer)

return true
