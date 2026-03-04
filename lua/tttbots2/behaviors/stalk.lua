

---@class BStalk
TTTBots.Behaviors.Stalk = {}

local lib = TTTBots.Lib

---@class Bot
---@field StalkTarget Player? The target to stalk
---@field StalkScore number The isolation score of the target

---@class BStalk
local Stalk = TTTBots.Behaviors.Stalk
Stalk.Name = "Stalk"
Stalk.Description = "Stalk a player (or random player) and ultimately kill them."
Stalk.Interruptible = true


local STATUS = TTTBots.STATUS

-- Target management (shared pattern via factory)
local _t = lib.MakeTargetFunctions({ targetField = "StalkTarget", scoreField = "StalkScore" })
Stalk.RateIsolation        = _t.RateIsolation
Stalk.FindTarget            = _t.FindTarget
Stalk.SetTarget             = _t.SetTarget
Stalk.GetTarget             = _t.GetTarget
Stalk.ClearTarget           = _t.ClearTarget
Stalk.ValidateTarget        = _t.ValidateTarget
Stalk.CheckForBetterTarget  = _t.CheckForBetterTarget

--- Validate the behavior before we can start it (or continue running)
--- Returning false when the behavior was just running will still call OnEnd.
---@param bot Bot
---@return boolean
function Stalk.Validate(bot)
    if not IsValid(bot) then return false end
    if bot.attackTarget ~= nil then return false end -- Do not stalk if we're killing someone already.
    return Stalk.ValidateTarget(bot) or TTTBots.Match.IsRoundActive()
end

--- Called when the behavior is started. Useful for instantiating one-time variables per cycle. Return STATUS.RUNNING to continue running.
---@param bot Bot
---@return BStatus
function Stalk.OnStart(bot)
    if not Stalk.ValidateTarget(bot) then
        Stalk.SetTarget(bot)
    end

    return STATUS.RUNNING
end

--- Called when OnStart or OnRunning returns STATUS.RUNNING. Return STATUS.RUNNING to continue running.
---@param bot Bot
---@return BStatus
function Stalk.OnRunning(bot)
    -- Stalk.CheckForBetterTarget(bot)
    if not Stalk.ValidateTarget(bot) then return STATUS.FAILURE end
    local target = Stalk.GetTarget(bot)
    local targetPos = target:GetPos()
    local targetEyes = target:EyePos()

    local isClose = bot:Visible(target) and bot:GetPos():Distance(targetPos) <= 150
    local loco = bot:BotLocomotor()
    if not loco then return STATUS.FAILURE end
    loco:SetGoal(targetPos)
    if not isClose then return STATUS.RUNNING end
    loco:LookAt(targetEyes)
    loco:SetGoal()

    local witnesses = lib.GetAllWitnessesBasic(targetPos, TTTBots.Roles.GetNonAllies(bot), bot)
    if #witnesses <= 1 then
        if math.random(1, 3) == 1 then -- Just some extra randomness for fun!
            bot:SetAttackTarget(target)
            return STATUS.SUCCESS
        end
    end

    return STATUS.RUNNING
end

--- Called when the behavior returns a success state. Only called on success, however.
---@param bot Bot
function Stalk.OnSuccess(bot)
end

--- Called when the behavior returns a failure state. Only called on failure, however.
---@param bot Bot
function Stalk.OnFailure(bot)
end

--- Called when the behavior succeeds or fails. Useful for cleanup, as it is always called once the behavior is a) interrupted, or b) returns a success or failure state.
---@param bot Bot
function Stalk.OnEnd(bot)
    Stalk.ClearTarget(bot)
end
