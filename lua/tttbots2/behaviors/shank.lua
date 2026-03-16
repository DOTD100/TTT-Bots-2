--- Shank behavior: hunt isolated players, backstab them, then flee.

---@class BShank
TTTBots.Behaviors.Shank = {}

local lib = TTTBots.Lib

---@class BShank
local Shank = TTTBots.Behaviors.Shank
Shank.Name = "Shank"
Shank.Description = "Backstab isolated targets with the shanker knife."
Shank.Interruptible = true

Shank.STRIKE_RANGE = 120
Shank.APPROACH_RANGE = 500
Shank.FLEE_DISTANCE = 800
Shank.FLEE_TIME = 6
Shank.MAX_WITNESSES = 1
Shank.BEHIND_DOT_THRESHOLD = 0
Shank.PATIENCE_TIME = 30

local STATUS = TTTBots.STATUS

---@param bot Bot
---@return Weapon|nil
function Shank.GetShankerKnife(bot)
    return lib.FindWeaponByPattern(bot, {
        "shankknife"
    })
end

--- Returns true if the bot is behind the target.
---@param bot Bot
---@param target Player
---@return boolean isBehind
function Shank.IsBehindTarget(bot, target)
    local toBot = (bot:GetPos() - target:GetPos()):GetNormalized()
    local targetForward = target:GetForward()
    toBot.z = 0
    targetForward.z = 0
    toBot:Normalize()
    targetForward:Normalize()

    local dot = targetForward:Dot(toBot)
    return dot < Shank.BEHIND_DOT_THRESHOLD
end

--- Returns a position behind the target for flanking.
---@param target Player
---@return Vector
function Shank.GetPositionBehind(target)
    local behindDir = -target:GetForward()
    behindDir.z = 0
    behindDir:Normalize()
    return target:GetPos() + behindDir * 80
end

---@param bot Bot
---@return boolean
function Shank.Validate(bot)
    if not TTTBots.Match.IsRoundActive() then return false end
    if not IsValid(bot) then return false end
    if bot.attackTarget ~= nil then return false end
    if bot.shankPhase == "flee" then return true end

    return Shank.GetShankerKnife(bot) ~= nil
end

---@param bot Bot
---@return BStatus
function Shank.OnStart(bot)
    bot.shankStartTime = CurTime()
    bot.shankPhase = "stalk" -- stalk -> approach -> strike -> flee
    bot.shankTarget = nil
    bot.shankFleeStart = nil

    local target = lib.FindIsolatedTarget(bot)
    if target and IsValid(target) and lib.IsPlayerAlive(target) then
        bot.shankTarget = target
    end

    return STATUS.RUNNING
end

---@param bot Bot
---@return BStatus
function Shank.OnRunning(bot)
    local loco = bot:BotLocomotor()
    if not loco then return STATUS.FAILURE end
    local inv = bot:BotInventory()

    local phase = bot.shankPhase or "stalk"

    -- FLEE: run away after a kill
    if phase == "flee" then
        local fleeSpot = bot.shankFleeSpot
        if not fleeSpot then return STATUS.SUCCESS end

        loco:SetGoal(fleeSpot)

        local elapsed = CurTime() - (bot.shankFleeStart or CurTime())
        if elapsed > Shank.FLEE_TIME then return STATUS.SUCCESS end
        if bot:GetPos():Distance(fleeSpot) < 100 then return STATUS.SUCCESS end

        return STATUS.RUNNING
    end

    -- Validate target, find a new one if needed
    local target = bot.shankTarget
    if not (target and IsValid(target) and lib.IsPlayerAlive(target)) then
        local newTarget = lib.FindIsolatedTarget(bot)
        if not (newTarget and IsValid(newTarget) and lib.IsPlayerAlive(newTarget)) then
            return STATUS.FAILURE
        end
        bot.shankTarget = newTarget
        target = newTarget
    end

    local botPos = bot:GetPos()
    local targetPos = target:GetPos()
    local targetEyes = target:EyePos()
    local dist = botPos:Distance(targetPos)
    local canSee = bot:Visible(target)
    local isBehind = Shank.IsBehindTarget(bot, target)
    local elapsed = CurTime() - (bot.shankStartTime or CurTime())

    local nonAllies = TTTBots.Roles.GetNonAllies(bot)
    local witnesses = lib.GetAllWitnessesBasic(botPos, nonAllies, bot)
    local witnessCount = #witnesses

    -- STALK: approach the target from a distance
    if phase == "stalk" then
        if not canSee then
            local memory = bot.components and bot.components.memory
            if memory then
                local knownPos = memory:GetKnownPositionFor(target)
                if knownPos then
                    loco:SetGoal(knownPos)
                end
            else
                loco:SetGoal(targetPos)
            end
            return STATUS.RUNNING
        end

        loco:SetGoal(targetPos)

        if dist <= Shank.APPROACH_RANGE then
            bot.shankPhase = "approach"
        end

        return STATUS.RUNNING
    end

    -- APPROACH: get behind the target and close distance
    if phase == "approach" then
        if not canSee then
            bot.shankPhase = "stalk"
            return STATUS.RUNNING
        end

        -- Back off if too many witnesses
        if witnessCount > Shank.MAX_WITNESSES then
            bot.shankPhase = "stalk"
            return STATUS.RUNNING
        end

        -- Equip the shanker knife
        local knife = Shank.GetShankerKnife(bot)
        if knife and IsValid(knife) then
            local activeWep = bot:GetActiveWeapon()
            if not (IsValid(activeWep) and activeWep == knife) then
                pcall(bot.SelectWeapon, bot, knife:GetClass())
                if inv then inv:PauseAutoSwitch() end
            end
        end

        -- In range and behind, transition to strike
        if isBehind and dist <= Shank.STRIKE_RANGE then
            bot.shankPhase = "strike"
            return STATUS.RUNNING
        end

        -- Behind but not close enough, close the gap
        if isBehind then
            loco:SetGoal(targetPos)
            loco:LookAt(targetEyes)
            return STATUS.RUNNING
        end

        -- Not behind yet, circle to their back
        local behindPos = Shank.GetPositionBehind(target)
        loco:SetGoal(behindPos)

        -- Patience ran out, rush them
        if elapsed > Shank.PATIENCE_TIME then
            bot.shankPhase = "strike"
            return STATUS.RUNNING
        end

        return STATUS.RUNNING
    end

    -- STRIKE: attack the target
    if phase == "strike" then
        if not (target and IsValid(target) and lib.IsPlayerAlive(target)) then
            Shank.StartFlee(bot, targetPos)
            return STATUS.RUNNING
        end

        loco:LookAt(targetEyes)

        -- Target turned around and is too far for melee, switch to gun
        local targetFacingUs = not Shank.IsBehindTarget(bot, target)
        if targetFacingUs and dist > 80 then
            if inv then inv:ResumeAutoSwitch() end
            bot:SetAttackTarget(target)
            return STATUS.SUCCESS
        end

        -- Keep using the knife
        local knife = Shank.GetShankerKnife(bot)
        if knife and IsValid(knife) then
            local activeWep = bot:GetActiveWeapon()
            if not (IsValid(activeWep) and activeWep == knife) then
                pcall(bot.SelectWeapon, bot, knife:GetClass())
            end
        end

        if dist > 70 then
            loco:SetGoal(targetPos)
        else
            loco:StopMoving()
        end
        loco:LookAt(targetEyes)
        loco:StartAttack()

        return STATUS.RUNNING
    end

    return STATUS.FAILURE
end

--- Trigger the flee phase after a kill.
---@param bot Bot
---@param killPos Vector
function Shank.StartFlee(bot, killPos)
    bot.shankPhase = "flee"
    bot.shankFleeStart = CurTime()

    local inv = bot:BotInventory()
    if inv then inv:ResumeAutoSwitch() end

    local loco = bot:BotLocomotor()
    if loco then loco:StopAttack() end

    bot.shankFleeSpot = lib.FindFleeSpot(bot, killPos, Shank.FLEE_DISTANCE)
end

---@param bot Bot
function Shank.OnSuccess(bot)
end

---@param bot Bot
function Shank.OnFailure(bot)
end

---@param bot Bot
function Shank.OnEnd(bot)
    bot.shankTarget = nil
    bot.shankPhase = nil
    bot.shankStartTime = nil
    bot.shankFleeStart = nil
    bot.shankFleeSpot = nil
    local loco = bot:BotLocomotor()
    if loco then
        loco:StopAttack()
    end
    local inv = bot:BotInventory()
    if inv then inv:ResumeAutoSwitch() end
end

-- Shanker bots always flee after killing someone.
hook.Add("PlayerDeath", "TTTBots.Behavior.Shank.FleeOnKill", function(victim, weapon, attacker)
    if not (IsValid(attacker) and attacker:IsPlayer() and attacker:IsBot()) then return end
    if not TTTBots.Match.IsRoundActive() then return end

    if not ROLE_SHANKER then return end
    if not (attacker.GetSubRole and attacker:GetSubRole() == ROLE_SHANKER) then return end

    Shank.StartFlee(attacker, victim:GetPos())
end)
