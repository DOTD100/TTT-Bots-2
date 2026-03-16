--- ClearBreakables: proactively attack breakable entities blocking the bot's path.

---@class BBreaker
TTTBots.Behaviors.ClearBreakables = {}

-- local lib = TTTBots.Lib

---@class BBreaker
local Breaker = TTTBots.Behaviors.ClearBreakables
Breaker.Name = "ClearBreakables"
Breaker.Description = "Clear breakables near to the player"
Breaker.Interruptible = true

local STATUS = TTTBots.STATUS

local function TraceForBreakable(bot)
    local trce = util.TraceLine({
        start = bot:EyePos(),
        endpos = bot:EyePos() + bot:GetAimVector() * 64,
        filter = bot,
    })

    local ent = trce.Entity
    if not trce.Hit or not IsValid(ent) then return nil end
    if not TTTBots.Components.ObstacleTracker.BreakablesSet[ent] then return nil end
    if ent:Health() <= 0 or ent:Health() >= 500 then return nil end

    return ent
end

function Breaker.Validate(bot)
    if not IsValid(bot) then return false end
    return TraceForBreakable(bot) ~= nil
end

function Breaker.OnStart(bot)
    return STATUS.RUNNING
end

function Breaker.OnRunning(bot)
    local target = TraceForBreakable(bot)
    if not target then return STATUS.FAILURE end

    local loco = bot:BotLocomotor()
    local inv = bot.components.inventory

    loco:LookAt(target:GetPos(), 0.5)
    inv:EquipMelee()
    inv:PauseAutoSwitch()
    loco:StartAttack()
    loco:SetPriorityGoal(target:GetPos(), 8)

    return STATUS.RUNNING
end

function Breaker.OnSuccess(bot) end
function Breaker.OnFailure(bot) end

function Breaker.OnEnd(bot)
    bot.components.inventory:ResumeAutoSwitch()
    bot:BotLocomotor():StopAttack()
end
