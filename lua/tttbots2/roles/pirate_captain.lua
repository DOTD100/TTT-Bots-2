--- Pirate Captain: leader of the pirate team who binds pirates to another team via a Contract.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_PIRATE_CAPTAIN then return false end

TEAM_JESTER = TEAM_JESTER or "jesters"
TEAM_PIRATE = TEAM_PIRATE or TEAM_PIR or "pirates"

local allyTeams = {
    [TEAM_PIRATE] = true,
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

local captain = TTTBots.RoleData.New("pirate_captain", TEAM_PIRATE)
captain:SetDefusesC4(false)
captain:SetPlantsC4(false)
captain:SetCanCoordinate(false)
captain:SetStartsFights(true)
captain:SetTeam(TEAM_PIRATE)
captain:SetUsesSuspicion(false)
captain:SetKnowsLifeStates(true)
captain:SetBTree(bTree)
captain:SetAlliedTeams(allyTeams)
captain:SetLovesTeammates(true)
captain:SetCanSnipe(true)
captain:SetCanHide(true)
TTTBots.Roles.RegisterRole(captain)

return true
