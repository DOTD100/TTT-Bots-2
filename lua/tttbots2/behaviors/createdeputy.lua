---@class BDeputy
TTTBots.Behaviors.CreateDeputy = {}

local lib = TTTBots.Lib

---@class BDeputy
local CreateDeputy = TTTBots.Behaviors.CreateDeputy
CreateDeputy.Name = "Deputy"
CreateDeputy.Description = "Deputize a player (or random bot)."
CreateDeputy.Interruptible = true


local STATUS = TTTBots.STATUS

---@class Bot
---@field DeputyTarget Player?

-- Target management (shared pattern via factory, with custom finder for nearby players)
local _t = lib.MakeTargetFunctions({
    targetField = "DeputyTarget",
    findTarget = function(bot)
        local players = lib.GetAllWitnessesBasic(bot:GetPos(), nil, bot)
        return lib.GetClosest(players, bot:GetPos())
    end,
})
CreateDeputy.FindTarget            = _t.FindTarget
CreateDeputy.SetTarget             = _t.SetTarget
CreateDeputy.GetTarget             = _t.GetTarget
CreateDeputy.ClearTarget           = _t.ClearTarget
CreateDeputy.ValidateTarget        = _t.ValidateTarget

--- Validate the behavior before we can start it (or continue running)
---@param bot Bot
---@return boolean
function CreateDeputy.Validate(bot)
    if not IsValid(bot) then return false end
    if bot.attackTarget ~= nil then return false end
    local inv = bot:BotInventory()
    if not (inv and inv:GetSheriffGun()) then return false end
    local chance = math.random(0, 100) <= 4
    return CreateDeputy.ValidateTarget(bot) or (TTTBots.Match.IsRoundActive() and chance)
end

--- Called when the behavior is started.
---@param bot Bot
---@return BStatus
function CreateDeputy.OnStart(bot)
    if not CreateDeputy.ValidateTarget(bot) then
        CreateDeputy.SetTarget(bot)
    end

    return STATUS.RUNNING
end

--- Called when OnStart or OnRunning returns STATUS.RUNNING.
---@param bot Bot
---@return BStatus
function CreateDeputy.OnRunning(bot)
    if not CreateDeputy.ValidateTarget(bot) then return STATUS.FAILURE end
    local target = CreateDeputy.GetTarget(bot)
    local targetPos = target:GetPos()
    local targetEyes = target:EyePos()

    local isClose = bot:Visible(target) and bot:GetPos():Distance(targetPos) <= 150
    local loco = bot:BotLocomotor()
    local inv = bot:BotInventory()
    if not (loco and inv) then return STATUS.FAILURE end
    loco:SetGoal(targetPos)
    if not isClose then return STATUS.RUNNING end
    loco:LookAt(targetEyes)
    loco:SetGoal()

    inv:PauseAutoSwitch()
    local equipped = inv:EquipSheriffGun()
    if not equipped then return STATUS.RUNNING end
    local bodyPos = TTTBots.Behaviors.AttackTarget.GetTargetBodyPos(target)
    loco:LookAt(bodyPos)
    local eyeTrace = bot:GetEyeTrace()
    if eyeTrace and eyeTrace.Entity == target then
        loco:StartAttack()
    end
    return STATUS.RUNNING
end

---@param bot Bot
function CreateDeputy.OnSuccess(bot)
end

---@param bot Bot
function CreateDeputy.OnFailure(bot)
end

---@param bot Bot
function CreateDeputy.OnEnd(bot)
    CreateDeputy.ClearTarget(bot)
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
