

---@class BSidekick
TTTBots.Behaviors.CreateSidekick = {}

local lib = TTTBots.Lib

---@class BSidekick
local CreateSidekick = TTTBots.Behaviors.CreateSidekick
CreateSidekick.Name = "Sidekick"
CreateSidekick.Description = "Sidekick a player (or random player) and ultimately kill them."
CreateSidekick.Interruptible = true


local STATUS = TTTBots.STATUS

---@class Bot
---@field SidekickTarget Player?
---@field SidekickScore number?

-- Target management (shared pattern via factory)
local _t = lib.MakeTargetFunctions({ targetField = "SidekickTarget", scoreField = "SidekickScore" })
CreateSidekick.RateIsolation        = _t.RateIsolation
CreateSidekick.FindTarget            = _t.FindTarget
CreateSidekick.SetTarget             = _t.SetTarget
CreateSidekick.GetTarget             = _t.GetTarget
CreateSidekick.ClearTarget           = _t.ClearTarget
CreateSidekick.ValidateTarget        = _t.ValidateTarget
CreateSidekick.CheckForBetterTarget  = _t.CheckForBetterTarget

--- Validate the behavior before we can start it (or continue running)
---@param bot Bot
---@return boolean
function CreateSidekick.Validate(bot)
    if not IsValid(bot) then return false end
    if bot.attackTarget ~= nil then return false end
    local inv = bot:BotInventory()
    if not (inv and inv:GetJackalGun()) then return false end
    local chance = math.random(0, 100) <= 2
    return CreateSidekick.ValidateTarget(bot) or (TTTBots.Match.IsRoundActive() and chance)
end

--- Called when the behavior is started. Return STATUS.RUNNING to continue running.
---@param bot Bot
---@return BStatus
function CreateSidekick.OnStart(bot)
    if not CreateSidekick.ValidateTarget(bot) then
        CreateSidekick.SetTarget(bot)
    end

    return STATUS.RUNNING
end

--- Called when OnStart or OnRunning returns STATUS.RUNNING.
---@param bot Bot
---@return BStatus
function CreateSidekick.OnRunning(bot)
    if not CreateSidekick.ValidateTarget(bot) then return STATUS.FAILURE end
    local target = CreateSidekick.GetTarget(bot)
    local targetPos = target:GetPos()
    local targetEyes = target:EyePos()

    if not (math.random(1, TTTBots.Tickrate * 2) == 1 and bot:Visible(target)) then
        CreateSidekick.CheckForBetterTarget(bot)
        if CreateSidekick.GetTarget(bot) ~= target then return STATUS.RUNNING end
    end

    local isClose = bot:Visible(target) and bot:GetPos():Distance(targetPos) <= 150
    local loco = bot:BotLocomotor()
    local inv = bot:BotInventory()
    if not (loco and inv) then return STATUS.FAILURE end
    loco:SetGoal(targetPos)
    if not isClose then return STATUS.RUNNING end
    loco:LookAt(targetEyes)
    loco:SetGoal()

    local witnesses = lib.GetAllWitnessesBasic(targetPos, TTTBots.Roles.GetNonAllies(bot), bot)
    if #witnesses <= 1 then
        inv:PauseAutoSwitch()
        local equipped = inv:EquipJackalGun()
        if not equipped then return STATUS.RUNNING end
        local bodyPos = TTTBots.Behaviors.AttackTarget.GetTargetBodyPos(target)
        loco:LookAt(bodyPos)
        local eyeTrace = bot:GetEyeTrace()
        if eyeTrace and eyeTrace.Entity == target then
            loco:StartAttack()
        end
        return STATUS.RUNNING
    else
        inv:ResumeAutoSwitch()
        loco:StopAttack()
    end

    return STATUS.RUNNING
end

---@param bot Bot
function CreateSidekick.OnSuccess(bot)
end

---@param bot Bot
function CreateSidekick.OnFailure(bot)
end

---@param bot Bot
function CreateSidekick.OnEnd(bot)
    CreateSidekick.ClearTarget(bot)
    local loco = bot:BotLocomotor()
    if not loco then return end
    loco:StopAttack()
    bot:SetAttackTarget(nil)
    timer.Simple(1, function()
        if not IsValid(bot) then return end
        local inv = bot:BotInventory()
        if not (inv) then return end
        inv:ResumeAutoSwitch()
    end)
end
