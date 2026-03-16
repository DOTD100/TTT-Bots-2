--- Swapper: jester-team role that swaps roles with whoever kills them.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_SWAPPER then return false end

TEAM_JESTER = TEAM_JESTER or "jesters"

local allyTeams = {
    [TEAM_JESTER] = true,
}

local _bh = TTTBots.Behaviors
local _prior = TTTBots.Behaviors.PriorityNodes

local bTree = {
    _prior.FightBack,
    _prior.Restore,
    _bh.Stalk,
    _bh.Interact,
    _prior.Minge,
    _prior.Investigate,
    _prior.Patrol
}

local swapper = TTTBots.RoleData.New("swapper", TEAM_JESTER)
swapper:SetDefusesC4(false)
swapper:SetPlantsC4(false)
swapper:SetCanCoordinate(false)
swapper:SetStartsFights(true)
swapper:SetTeam(TEAM_JESTER)
swapper:SetUsesSuspicion(false)
swapper:SetKnowsLifeStates(false)
swapper:SetBTree(bTree)
swapper:SetAlliedTeams(allyTeams)
swapper:SetLovesTeammates(false)
swapper:SetCanSnipe(false)
swapper:SetCanHide(false)
TTTBots.Roles.RegisterRole(swapper)

return true
