--- Shanker: traitor with free radar, backstabs isolated targets with shanker knife.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_SHANKER then return false end

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
    _bh.Shank,
    _bh.Defib,
    _bh.PlantBomb,
    _bh.UseTraitorTrap,
    _prior.Restore,
    _bh.Stalk,
    _bh.FollowPlan,
    _bh.Interact,
    _prior.Minge,
    _prior.Investigate,
    _prior.Patrol
}

local shanker = TTTBots.RoleData.New("shanker", TEAM_TRAITOR)
shanker:SetDefusesC4(false)
shanker:SetPlantsC4(true)
shanker:SetCanHaveRadar(true)
shanker:SetCanCoordinate(true)
shanker:SetStartsFights(true)
shanker:SetTeam(TEAM_TRAITOR)
shanker:SetUsesSuspicion(false)
shanker:SetKnowsLifeStates(true)
shanker:SetBTree(bTree)
shanker:SetAlliedTeams(allyTeams)
shanker:SetLovesTeammates(true)
shanker:SetCanSnipe(false)
shanker:SetCanHide(true)
TTTBots.Roles.RegisterRole(shanker)

return true
