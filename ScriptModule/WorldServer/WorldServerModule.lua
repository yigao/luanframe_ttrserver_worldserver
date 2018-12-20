WorldServerModule = {}

StartOver = StartOver or function()

end

InitTimer = InitTimer or function()
    -- body
end

WorldServerModule.worldServerModule = nil

function WorldServerModule.Init()
    unilight.initmongodb('mongodb://14.17.104.12:28900', "ttr-1")
    Do.dbready()

    local pluginManager = LuaNFrame:GetPluginManager()
    WorldServerModule.worldServerModule = pluginManager:GetWorldServerModule()
    
    TcpServer.addRecvCallBack(NF_SERVER_TYPES.NF_ST_WORLD, 0, "WorldServerModule.GameRecvHandleJson")
    TcpServer.addEventCallBack(NF_SERVER_TYPES.NF_ST_WORLD, "WorldServerModule.WorldServerNetEvent")

    unilight.response = function(w, req)
		req.st = os.time()
		local s = table2json(req)
		w.SendString(s)
		unilight.debug("[send] " .. s)
    end
    
    --初始化排行榜
    if RankListMgr ~= nil then
        RankListMgr:Init()
    end
    --好友管理系统初始化
    if FriendManager ~= nil then
        FriendManager:Init()
    end
    --StartOver()

    InitTimer()
end

function WorldServerModule.WorldServerNetEvent(nEvent, unLinkId)
    local cmd = {}
    if nEvent == NF_MSG_TYPE.eMsgType_CONNECTED then
    end
    if nEvent == NF_MSG_TYPE.eMsgType_DISCONNECTED then
        local cmd = {}
        local zonetask = {
            unLinkId = unLinkId,
        }
        local gameServer = WorldServerModule.worldServerModule:GetGameByLink(unLinkId)
        if gameServer ~= nil then
            zonetask.serverId = gameServer.ServerId
        else
            zonetask.serverId = 0
        end
        Zone.zone_disconnect(cmd, zonetask)
    end
end

--特殊协议
function WorldServerModule.GameRecvHandleJson(unLinkId, valueId, nMsgId, strMsg)
    local table_msg = json2table(strMsg)
    if type(table_msg["do"]) == "string" then
        if table_msg["do"] == "Cmd.UserUpdate_C" then
        else
            unilight.debug(tostring(valueId) .. " | recv game msg |" .. strMsg)
        end
    end
    --协议规则
    if table_msg ~= nil then
        local cmd = table_msg["do"]
        if type(cmd) == "string" then
            local i, j = string.find(cmd, "Cmd.")
            local strcmd = string.sub(cmd, j+1, -1)
            if strcmd ~= "" then
                strcmd = "Cmd" .. strcmd
                if type(Zone[strcmd]) == "function" then

                    local gameServer = WorldServerModule.worldServerModule:GetGameByLink(unLinkId)
                    local serverId = gameServer.ServerId
                    ZoneInfo.ZoneTaskMap[serverId] = unLinkId
                    local zonetask = {
                        unLinkId = unLinkId,
                        serverId = serverId,

                        GetGameId = function()
                            return serverId
                        end,

                        GetZoneId = function()
                            return serverId
                        end,
                    }
                    Zone[strcmd](table_msg, zonetask)
                end
            end
        end
    end
    -- body
end

function WorldServerModule.AfterInit()

end


function WorldServerModule.Execute()

end

function WorldServerModule.BeforeShut()

end

function WorldServerModule.Shut()

end

Zone.CmdTestZoneConnectSendMsg_S = function(cmd,zonetask)
	unilight.info("收到游戏服数据:TestZoneConnectSendMsg_S:")

	local data = {}
	ZoneInfo.SendCmdToMe("Cmd.TestLobbySenMsgCmd_S", data, zonetask)
end

Zone.CmdSendMsgToLobby2_S = function(cmd, zonetask)
	unilight.debug("Zone.CmdSendMsgToLobby2_S test Finish")
end
