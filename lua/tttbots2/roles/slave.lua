--- Slave: converted player who follows and assists the Brainwasher master.

if not TTTBots.Lib.IsTTT2() then return false end
if not ROLE_SLAVE then return false end

local _bh = TTTBots.Behaviors
local _prior = TTTBots.Behaviors.PriorityNodes

local bTree = {
    _prior.FightBack,
    _bh.Defib,
    _bh.UseTraitorTrap,
    _prior.Restore,
    _bh.FollowMaster,
    _bh.InvestigateCorpse,
    _prior.Minge,
    _prior.Investigate,
    _prior.Patrol
}

local slave = TTTBots.RoleData.New("slave", TEAM_TRAITOR)
slave:SetDefusesC4(false)
slave:SetPlantsC4(false)
slave:SetCanHaveRadar(false)
slave:SetCanCoordinate(false)
slave:SetStartsFights(true)
slave:SetTeam(TEAM_TRAITOR)
slave:SetUsesSuspicion(false)
slave:SetKnowsLifeStates(true)
slave:SetBTree(bTree)
slave:SetLovesTeammates(true)
slave:SetAlliedTeams({ [TEAM_TRAITOR] = true, [TEAM_JESTER or "jesters"] = true })
slave:SetCanSnipe(false)
slave:SetCanHide(false)
TTTBots.Roles.RegisterRole(slave)

TTTBots.Lib.RegisterMasterMinionHooks("slave", "brainwasher", "TTTBots_Slave")

-- When the Brainwasher dies, reverted Slaves get KOS-level suspicion on traitors.
hook.Add("PostPlayerDeath", "TTTBots_SlaveRevertOnMasterDeath", function(deadPly)
    if not IsValid(deadPly) then return end
    if deadPly:GetSubRole() ~= ROLE_BRAINWASHER then return end

    local slaveMode = GetConVar("ttt2_slave_mode")
    if not slaveMode or slaveMode:GetInt() ~= 1 then return end

    timer.Simple(0.5, function()
        if not TTTBots.Match.IsRoundActive() then return end

        for _, bot in pairs(TTTBots.Bots) do
            if not (IsValid(bot) and bot ~= NULL and TTTBots.Lib.IsPlayerAlive(bot)) then continue end

            local roleStr = bot:GetRoleStringRaw()
            if roleStr ~= "innocent" then continue end

            if not bot.tttbots_wasSlaveOf then continue end
            if bot.tttbots_wasSlaveOf ~= deadPly then continue end

            local morality = bot.components and bot.components.morality
            if not morality then continue end

            for _, ply in pairs(player.GetAll()) do
                if not (IsValid(ply) and ply:IsPlayer() and TTTBots.Lib.IsPlayerAlive(ply)) then continue end
                if ply == bot then continue end

                local plyTeam = ply:GetTeam()
                if plyTeam == TEAM_TRAITOR then
                    morality.suspicions[ply] = math.max(morality:GetSuspicion(ply), 10)
                    morality:AnnounceIfThreshold(ply)
                    morality:SetAttackIfTargetSus(ply)
                end
            end

            bot.tttbots_wasSlaveOf = nil
        end
    end)
end)

-- Track when a bot becomes a Slave to record their master.
hook.Add("TTT2UpdateSubrole", "TTTBots_TrackSlaveConversion", function(ply, oldRole, newRole)
    if not IsValid(ply) then return end
    if not ply:IsBot() then return end

    if newRole == ROLE_SLAVE then
        local master = ply:GetNWEntity("binded_slave", nil)
        if IsValid(master) then
            ply.tttbots_wasSlaveOf = master
        end
    end
end)

-- Clean up tracking flags at round start.
hook.Add("TTTBeginRound", "TTTBots_SlaveTrackingClear", function()
    timer.Simple(0.5, function()
        for _, bot in pairs(TTTBots.Bots) do
            if IsValid(bot) and bot ~= NULL then
                bot.tttbots_wasSlaveOf = nil
            end
        end
    end)
end)

return true
