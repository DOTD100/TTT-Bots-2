--- Shinigami: innocent that respawns after death with a knife and health drain.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_SHINIGAMI then return false end

local _bh = TTTBots.Behaviors
local _prior = TTTBots.Behaviors.PriorityNodes

local bTree = {
    _prior.FightBack,
    _bh.Defuse,
    _prior.Restore,
    _bh.Stalk,
    _bh.Interact,
    _prior.Investigate,
    _prior.Minge,
    _bh.Decrowd,
    _prior.Patrol
}

local shinigami = TTTBots.RoleData.New("shinigami", TEAM_INNOCENT)
shinigami:SetDefusesC4(true)
shinigami:SetTeam(TEAM_INNOCENT)
shinigami:SetBTree(bTree)
shinigami:SetCanHide(true)
shinigami:SetCanSnipe(true)
shinigami:SetUsesSuspicion(true)
shinigami:SetAlliedRoles({})
shinigami:SetAlliedTeams({})
TTTBots.Roles.RegisterRole(shinigami)

return true
