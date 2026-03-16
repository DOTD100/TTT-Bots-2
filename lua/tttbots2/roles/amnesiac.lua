--- Amnesiac: starts as innocent, confirms a corpse to transform into that role.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_AMNESIAC then return false end

TEAM_INNOCENT = TEAM_INNOCENT or "innocents"

local lib = TTTBots.Lib

local allyTeams = {
    [TEAM_INNOCENT] = true,
}

local _bh = TTTBots.Behaviors
local _prior = TTTBots.Behaviors.PriorityNodes

local bTree = {
    _prior.FightBack,
    { _bh.Defuse },
    _prior.Restore,
    { _bh.Interact },
    { _bh.InvestigateCorpse },
    { _bh.InvestigateNoise },
    _prior.Minge,
    _prior.Patrol
}

local amnesiac = TTTBots.RoleData.New("amnesiac", TEAM_INNOCENT)
amnesiac:SetDefusesC4(true)
amnesiac:SetPlantsC4(false)
amnesiac:SetCanCoordinate(false)
amnesiac:SetStartsFights(false)
amnesiac:SetTeam(TEAM_INNOCENT)
amnesiac:SetUsesSuspicion(true)
amnesiac:SetKnowsLifeStates(false)
amnesiac:SetBTree(bTree)
amnesiac:SetAlliedTeams(allyTeams)
amnesiac:SetLovesTeammates(true)
amnesiac:SetCanSnipe(false)
amnesiac:SetCanHide(false)
TTTBots.Roles.RegisterRole(amnesiac)

-- Amnesiac bots always investigate corpses (their primary objective).
local function IsAmnesiac(ply)
    if not (IsValid(ply) and ply:IsPlayer()) then return false end
    local ok, role = pcall(ply.GetSubRole, ply)
    return ok and role == ROLE_AMNESIAC
end

local originalGetShould = TTTBots.Behaviors.InvestigateCorpse.GetShouldInvestigateCorpses
TTTBots.Behaviors.InvestigateCorpse.GetShouldInvestigateCorpses = function(bot)
    if IsAmnesiac(bot) then
        return true
    end
    return originalGetShould(bot)
end

-- Clean up state when the Amnesiac confirms a body and transforms.
hook.Add("TTT2UpdateSubrole", "TTTBots.amnesiac.conversion", function(ply, oldRole, newRole)
    if not (IsValid(ply) and ply:IsBot()) then return end
    if oldRole ~= ROLE_AMNESIAC then return end
    if newRole == ROLE_AMNESIAC then return end

    ply.corpseTarget = nil

    if ply.attackTarget then
        ply:SetAttackTarget(nil)
    end

    local chatter = ply:BotChatter()
    if chatter then
        chatter:On("AmnesiacTransformed", {}, false)
    end
end)

return true
