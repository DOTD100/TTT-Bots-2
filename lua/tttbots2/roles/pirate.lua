--- Pirate: crew member who follows the Captain and fights for their bound team.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_PIRATE then return false end

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
    _prior.Minge,
    _prior.Investigate,
    _prior.Patrol
}

local pirate = TTTBots.RoleData.New("pirate", TEAM_PIRATE)
pirate:SetDefusesC4(false)
pirate:SetPlantsC4(false)
pirate:SetCanCoordinate(false)
pirate:SetStartsFights(true)
pirate:SetTeam(TEAM_PIRATE)
pirate:SetUsesSuspicion(false)
pirate:SetKnowsLifeStates(true)
pirate:SetBTree(bTree)
pirate:SetAlliedTeams(allyTeams)
pirate:SetLovesTeammates(true)
pirate:SetCanSnipe(true)
pirate:SetCanHide(true)
TTTBots.Roles.RegisterRole(pirate)

TTTBots.Lib.RegisterMasterMinionHooks("pirate", "pirate_captain", "TTTBots_Pirate")
TTTBots.Lib.RegisterMasterMinionHooks("pirate_captain", "pirate", "TTTBots_PirateCaptain")

return true
