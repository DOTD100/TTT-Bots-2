--- Fuse: traitor that must kill every ~60 seconds or self-destructs.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_FUSE then return false end

TEAM_JESTER = TEAM_JESTER or "jesters"

local allyTeams = {
    [TEAM_TRAITOR] = true,
    [TEAM_JESTER] = true,
}

local _bh = TTTBots.Behaviors
local _prior = TTTBots.Behaviors.PriorityNodes

local bTree = {
    _prior.FightBack,
    _bh.FuseHunt,
    _bh.Stalk,
    _bh.PlantBomb,
    _bh.UseTraitorTrap,
    _prior.Restore,
    _bh.FollowPlan,
    _prior.Minge,
    _prior.Investigate,
    _prior.Patrol
}

local fuse = TTTBots.RoleData.New("fuse", TEAM_TRAITOR)
fuse:SetDefusesC4(false)
fuse:SetPlantsC4(true)
fuse:SetCanHaveRadar(true)
fuse:SetCanCoordinate(true)
fuse:SetStartsFights(true)
fuse:SetTeam(TEAM_TRAITOR)
fuse:SetUsesSuspicion(false)
fuse:SetKnowsLifeStates(true)
fuse:SetBTree(bTree)
fuse:SetAlliedTeams(allyTeams)
fuse:SetLovesTeammates(true)
fuse:SetCanSnipe(true)
fuse:SetCanHide(false)
TTTBots.Roles.RegisterRole(fuse)

return true
