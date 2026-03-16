--- Beggar: jester-team role that converts to innocent or traitor via shop item pickup.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_BEGGAR then return false end

TEAM_JESTER = TEAM_JESTER or "jesters"

local allyTeams = {
    [TEAM_JESTER] = true,
    [TEAM_TRAITOR] = true,
}

local _bh = TTTBots.Behaviors
local _prior = TTTBots.Behaviors.PriorityNodes

local bTreePreConvert = {
    _bh.BeggarScavenge,
    _prior.Restore,
    _bh.Interact,
    _prior.Minge,
    _prior.Investigate,
    _prior.Patrol
}

local beggar = TTTBots.RoleData.New("beggar", TEAM_JESTER)
beggar:SetDefusesC4(false)
beggar:SetPlantsC4(false)
beggar:SetCanHaveRadar(false)
beggar:SetCanCoordinate(false)
beggar:SetStartsFights(false)
beggar:SetTeam(TEAM_JESTER)
beggar:SetUsesSuspicion(false)
beggar:SetKnowsLifeStates(false)
beggar:SetBTree(bTreePreConvert)
beggar:SetAlliedTeams(allyTeams)
beggar:SetLovesTeammates(false)
beggar:SetCanSnipe(false)
beggar:SetCanHide(false)
TTTBots.Roles.RegisterRole(beggar)

-- Post-conversion behavior trees.
local function GetInnocentTree()
    return {
        _prior.FightBack,
        _bh.Defuse,
        _bh.InvestigateCorpse,
        _prior.Restore,
        _prior.Minge,
        _prior.Investigate,
        _prior.Patrol
    }
end

local function GetTraitorTree()
    return {
        _prior.FightBack,
        _bh.Stalk,
        _bh.PlantBomb,
        _bh.UseTraitorTrap,
        _bh.Defib,
        _prior.Restore,
        _bh.FollowPlan,
        _bh.Interact,
        _prior.Minge,
        _prior.Investigate,
        _prior.Patrol
    }
end

-- Per-bot btree override for converted beggars.
local origGetTreeFor = TTTBots.Behaviors._origGetTreeFor or TTTBots.Behaviors.GetTreeFor
TTTBots.Behaviors._origGetTreeFor = origGetTreeFor

function TTTBots.Behaviors.GetTreeFor(bot)
    if bot.tttbots_btreeOverride then
        return bot.tttbots_btreeOverride
    end
    return origGetTreeFor(bot)
end

-- Detect team changes from shop item pickup.
hook.Add("Think", "TTTBots.Beggar.ConversionCheck", function()
    if not TTTBots.Match.IsRoundActive() then return end

    local now = CurTime()
    if (TTTBots._beggarLastCheck or 0) + 1 > now then return end
    TTTBots._beggarLastCheck = now

    for _, bot in ipairs(player.GetBots()) do
        if not (IsValid(bot) and bot:IsPlayer()) then continue end
        if not (bot.GetSubRole and bot:GetSubRole() == ROLE_BEGGAR) then continue end

        local team = bot:GetTeam()
        if team == TEAM_JESTER or team == "jesters" or team == TEAM_NONE or team == "none" then continue end
        if bot.beggarConvertedTeam == team then continue end
        bot.beggarConvertedTeam = team

        if team == TEAM_TRAITOR then
            bot.tttbots_btreeOverride = GetTraitorTree()
            print(string.format("[TTT Bots 2] Beggar %s converted to TRAITOR team!", bot:Nick()))
        else
            bot.tttbots_btreeOverride = GetInnocentTree()
            print(string.format("[TTT Bots 2] Beggar %s converted to %s team!", bot:Nick(), team))
        end
    end
end)

-- Reset per-bot overrides each round.
hook.Add("TTTBeginRound", "TTTBots.Beggar.RoundReset", function()
    for _, bot in ipairs(player.GetBots()) do
        bot.beggarConvertedTeam = nil
        bot.tttbots_btreeOverride = nil
    end
end)

return true
