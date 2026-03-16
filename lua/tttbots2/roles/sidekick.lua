if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_SIDEKICK then return false end

TEAM_JACKAL = TEAM_JACKAL or "jackal"
TEAM_JESTER = TEAM_JESTER or "jesters"
TEAM_SIDEKICK = TEAM_SIDEKICK or "sidekick"

local allyTeams = {
    [TEAM_JACKAL] = true,
    [TEAM_JESTER] = true,
}

local _bh = TTTBots.Behaviors
local _prior = TTTBots.Behaviors.PriorityNodes
local bTree = {
    _prior.FightBack,
    _prior.Restore,
    _bh.FollowMaster,
    _prior.Minge,
    _prior.Patrol
}

local sidekick = TTTBots.RoleData.New("sidekick", TEAM_SIDEKICK)
sidekick:SetDefusesC4(false)
sidekick:SetCanCoordinate(false)
sidekick:SetStartsFights(true)
sidekick:SetUsesSuspicion(false)
sidekick:SetTeam(TEAM_SIDEKICK)
sidekick:SetAlliedTeams(allyTeams)
sidekick:SetBTree(bTree)
sidekick:SetLovesTeammates(true)
TTTBots.Roles.RegisterRole(sidekick)

-- Sidekick helps jackal when shooting/attacked
TTTBots.Lib.RegisterMasterMinionHooks("sidekick", "jackal", "TTTBots_Sidekick")

return true
