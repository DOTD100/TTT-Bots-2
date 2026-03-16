--- Loot Goblin: neutral role that cannot deal damage, wins by surviving.
--- 50% model scale, reduced speed. All bots should hunt them on sight.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_LOOTGOBLIN then return false end

TEAM_NEUTRAL = TEAM_NEUTRAL or "neutral"
TEAM_JESTER = TEAM_JESTER or "jesters"

local lib = TTTBots.Lib

local allyTeams = {
    [TEAM_NEUTRAL] = true,
    [TEAM_JESTER] = true,
}

local _bh = TTTBots.Behaviors
local _prior = TTTBots.Behaviors.PriorityNodes

-- Loot Goblin can't deal damage, so no fighting back or investigating.
-- Pure survival: flee and hide.
local bTree = {
    _prior.Restore,
    _prior.Patrol
}

local lootgoblin = TTTBots.RoleData.New("lootgoblin", TEAM_NEUTRAL)
lootgoblin:SetDefusesC4(false)
lootgoblin:SetPlantsC4(false)
lootgoblin:SetCanCoordinate(false)
lootgoblin:SetStartsFights(false)
lootgoblin:SetTeam(TEAM_NEUTRAL)
lootgoblin:SetUsesSuspicion(false)
lootgoblin:SetKnowsLifeStates(false)
lootgoblin:SetBTree(bTree)
lootgoblin:SetAlliedTeams(allyTeams)
lootgoblin:SetLovesTeammates(false)
lootgoblin:SetCanSnipe(false)
lootgoblin:SetCanHide(true)
TTTBots.Roles.RegisterRole(lootgoblin)

local function IsLootGoblin(ply)
    if not (IsValid(ply) and ply:IsPlayer()) then return false end
    local ok, role = pcall(ply.GetRoleStringRaw, ply)
    return ok and role == "lootgoblin"
end

-- All bots can attack the Loot Goblin regardless of team/jester protection.
hook.Add("TTTBotsCanAttack", "TTTBots.lootgoblin.allowAttack", function(bot, target)
    if IsLootGoblin(target) then
        return true
    end
end)

-- Adjust aim point for the Loot Goblin's 50% model scale.
-- Bone positions may not reflect the scaled model, so we scale the offset
-- from the target's feet to compensate.
local LOOTGOBLIN_SCALE = 0.5

hook.Add("TTTBotsGetAimPoint", "TTTBots.lootgoblin.aimAdjust", function(bot, target, aimPoint)
    if not IsLootGoblin(target) then return end

    local feetPos = target:GetPos()
    local offset = aimPoint - feetPos
    return feetPos + offset * LOOTGOBLIN_SCALE
end)

-- All bots hunt Loot Goblins on sight. No team restrictions.
timer.Create("TTTBots.LootGoblin.HuntTarget", 1, 0, function()
    if not TTTBots.Match.IsRoundActive() then return end

    local goblins = {}
    for _, ply in ipairs(TTTBots.Match.AlivePlayers or {}) do
        if IsValid(ply) and IsLootGoblin(ply) then
            goblins[#goblins + 1] = ply
        end
    end
    if #goblins == 0 then return end

    for _, bot in pairs(TTTBots.Bots) do
        if not (IsValid(bot) and lib.IsPlayerAlive(bot)) then continue end
        if bot.attackTarget ~= nil then continue end
        if IsLootGoblin(bot) then continue end

        for _, goblin in ipairs(goblins) do
            if not IsValid(goblin) then continue end
            if not lib.IsPlayerAlive(goblin) then continue end
            local dist = bot:GetPos():Distance(goblin:GetPos())
            local goblinHead = goblin:GetPos() + (goblin:EyePos() - goblin:GetPos()) * LOOTGOBLIN_SCALE
            if dist < 1500 and lib.CanSeeArc(bot, goblinHead, 90) then
                bot:SetAttackTarget(goblin)
                break
            end
        end
    end
end)

-- Loot Goblin bots flee from all nearby visible players.
timer.Create("TTTBots.LootGoblin.FleeNearby", 0.5, 0, function()
    if not TTTBots.Match.IsRoundActive() then return end

    for _, bot in pairs(TTTBots.Bots) do
        if not (IsValid(bot) and lib.IsPlayerAlive(bot)) then continue end
        if not IsLootGoblin(bot) then continue end

        local loco = bot:BotLocomotor()
        if not loco then continue end

        local FLEE_RADIUS = 800
        local closestDist = math.huge
        local closestPly = nil

        for _, ply in ipairs(TTTBots.Match.AlivePlayers or {}) do
            if not IsValid(ply) then continue end
            if ply == bot then continue end
            if not lib.IsPlayerAlive(ply) then continue end

            local dist = bot:GetPos():Distance(ply:GetPos())
            if dist < FLEE_RADIUS and dist < closestDist and lib.CanSeeArc(bot, ply:EyePos(), 120) then
                closestDist = dist
                closestPly = ply
            end
        end

        if closestPly then
            local fleeSpot = lib.FindFleeSpot(bot, closestPly:GetPos(), FLEE_RADIUS)
            if fleeSpot then
                loco:SetGoal(fleeSpot)
            end
        end
    end
end)

return true
