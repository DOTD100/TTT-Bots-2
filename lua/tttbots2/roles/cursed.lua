--- Cursed: no team, cannot deal damage, swaps roles by tagging another player.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_CURSED then return false end

TEAM_JESTER = TEAM_JESTER or "jesters"

local allyTeams = {
    [TEAM_JESTER] = true,
}

local _bh = TTTBots.Behaviors
local _prior = TTTBots.Behaviors.PriorityNodes

local bTree = {
    _prior.FightBack,
    _bh.CursedTag,
    _prior.Restore,
    _prior.Minge,
    _prior.Investigate,
    _prior.Patrol
}

local cursed = TTTBots.RoleData.New("cursed", TEAM_NONE)
cursed:SetDefusesC4(false)
cursed:SetPlantsC4(false)
cursed:SetCanCoordinate(false)
cursed:SetStartsFights(false)
cursed:SetTeam(TEAM_NONE)
cursed:SetUsesSuspicion(false)
cursed:SetKnowsLifeStates(false)
cursed:SetBTree(bTree)
cursed:SetAlliedTeams(allyTeams)
cursed:SetLovesTeammates(false)
cursed:SetCanSnipe(false)
cursed:SetCanHide(false)
TTTBots.Roles.RegisterRole(cursed)

-- Clear locomotor goal on death since the Cursed always resurrects.
hook.Add("PlayerDeath", "TTTBots_CursedDeathCleanup", function(victim, _, _)
    if not IsValid(victim) then return end
    if not victim:IsBot() then return end
    if not victim.GetRoleStringRaw then return end

    local ok, role = pcall(victim.GetRoleStringRaw, victim)
    if not ok or role ~= "cursed" then return end

    local loco = victim:BotLocomotor()
    if loco then
        loco:SetGoal()
        loco:StopAttack()
    end
end)

return true
