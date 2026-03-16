--- Brainwasher: traitor who recruits players into Slaves using the Slave Deagle.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_BRAINWASHER then return false end

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
    _bh.Brainwash,
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

local brainwasher = TTTBots.RoleData.New("brainwasher", TEAM_TRAITOR)
brainwasher:SetDefusesC4(false)
brainwasher:SetPlantsC4(true)
brainwasher:SetCanHaveRadar(true)
brainwasher:SetCanCoordinate(true)
brainwasher:SetStartsFights(true)
brainwasher:SetTeam(TEAM_TRAITOR)
brainwasher:SetUsesSuspicion(false)
brainwasher:SetKnowsLifeStates(true)
brainwasher:SetBTree(bTree)
brainwasher:SetAlliedTeams(allyTeams)
brainwasher:SetLovesTeammates(true)
brainwasher:SetCanSnipe(false)
brainwasher:SetCanHide(true)
TTTBots.Roles.RegisterRole(brainwasher)

return true
