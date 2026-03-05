--- Brainwasher-specific behavior: Sneakily recruit a target using the Slave Deagle.
--- Based on CreateSidekick -- finds isolated targets and shoots them when few witnesses are around.
--- The Brainwasher must be careful not to be seen converting players.

---@class BBrainwash
TTTBots.Behaviors.Brainwash = {}

local lib = TTTBots.Lib

---@class BBrainwash
local Brainwash = TTTBots.Behaviors.Brainwash
Brainwash.Name = "Brainwash"
Brainwash.Description = "Sneakily recruit a player using the Slave Deagle."
Brainwash.Interruptible = true

local STATUS = TTTBots.STATUS

-- Target management (shared pattern via factory, with extra validation for role checks)
local _t = lib.MakeTargetFunctions({
    targetField = "BrainwashTarget",
    scoreField = "BrainwashScore",
    validateExtra = function(bot, target)
        -- Don't try to brainwash someone who's already a slave or brainwasher
        if ROLE_SLAVE and target:GetSubRole() == ROLE_SLAVE then return false end
        if ROLE_BRAINWASHER and target:GetSubRole() == ROLE_BRAINWASHER then return false end
        -- Don't target teammates
        if target:GetTeam() == bot:GetTeam() then return false end
        return true
    end,
})
Brainwash.RateIsolation        = _t.RateIsolation
Brainwash.FindTarget            = _t.FindTarget
Brainwash.SetTarget             = _t.SetTarget
Brainwash.GetTarget             = _t.GetTarget
Brainwash.ClearTarget           = _t.ClearTarget
Brainwash.ValidateTarget        = _t.ValidateTarget
Brainwash.CheckForBetterTarget  = _t.CheckForBetterTarget

--- Validate: only runs when the bot has the slavedeagle and a valid target (or should start looking).
---@param bot Bot
---@return boolean
function Brainwash.Validate(bot)
    if not IsValid(bot) then return false end
    if bot.attackTarget ~= nil then return false end
    local inv = bot:BotInventory()
    if not (inv and inv:GetSlaveDeagle()) then return false end
    return Brainwash.ValidateTarget(bot) or (TTTBots.Match.IsRoundActive() and lib.TestPercent(3))
end

---@param bot Bot
---@return BStatus
function Brainwash.OnStart(bot)
    if not Brainwash.ValidateTarget(bot) then
        Brainwash.SetTarget(bot)
    end
    return STATUS.RUNNING
end

---@param bot Bot
---@return BStatus
function Brainwash.OnRunning(bot)
    if not Brainwash.ValidateTarget(bot) then return STATUS.FAILURE end
    local target = Brainwash.GetTarget(bot)
    local targetPos = target:GetPos()
    local targetEyes = target:EyePos()

    -- Occasionally check for a better target
    if not (math.random(1, TTTBots.Tickrate * 2) == 1 and bot:Visible(target)) then
        Brainwash.CheckForBetterTarget(bot)
        if Brainwash.GetTarget(bot) ~= target then return STATUS.RUNNING end
    end

    local isClose = bot:Visible(target) and bot:GetPos():Distance(targetPos) <= 150
    local loco = bot:BotLocomotor()
    local inv = bot:BotInventory()
    if not (loco and inv) then return STATUS.FAILURE end
    loco:SetGoal(targetPos)
    if not isClose then return STATUS.RUNNING end
    loco:LookAt(targetEyes)
    loco:SetGoal()

    -- Only shoot when few witnesses are around (must be sneaky)
    local witnesses = lib.GetAllWitnessesBasic(targetPos, TTTBots.Roles.GetNonAllies(bot), bot)
    if #witnesses <= 1 then
        inv:PauseAutoSwitch()
        local equipped = inv:EquipSlaveDeagle()
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
function Brainwash.OnSuccess(bot)
end

---@param bot Bot
function Brainwash.OnFailure(bot)
end

---@param bot Bot
function Brainwash.OnEnd(bot)
    Brainwash.ClearTarget(bot)
    local loco = bot:BotLocomotor()
    if not loco then return end
    loco:StopAttack()
    bot:SetAttackTarget(nil)
    timer.Simple(1, function()
        if not IsValid(bot) then return end
        local inv = bot:BotInventory()
        if not inv then return end
        inv:ResumeAutoSwitch()
    end)
end
