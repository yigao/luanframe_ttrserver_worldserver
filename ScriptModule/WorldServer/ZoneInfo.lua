Zone = Zone or {}
ZoneInfo = ZoneInfo or { }
Zone.zone_connect = function(cmd, zonetask) 
    unilight.info("大厅服务器回调：新的区连进来了 ")
    --ZoneInfo[zonetask.serverId] = zonetask.unLinkId
end

Zone.zone_disconnect = function(cmd, zonetask) 
    unilight.info("大厅服务器回调：区掉线了了 ")
    ZoneInfo[zonetask.serverId] = nil
end

Zone.zone_change_props = function(cmd, zonetask)
    unilight.info("-----" .. cmd.GetMaxonlinenum() .. "" .. zonetask.GetGameId())
    unilight.info("-----" .. cmd.GetPriority() .. "" .. zonetask.GetZoneId())
end

ZoneInfo.SendCmdToMe = function(doinfo, data, zonetask)
    --if type(doinfo) ~= "string" or type(data) ~= "table" then
    --   unilight.error("Zone.SendCmdToMe param error.........type(doinfo):"..type(doinfo).." type(data)" .. type(data))
    --   return
    --end
    local send = {}
    send["do"] = doinfo
    send["data"] = data
    local s = json.encode(send)
    unilight.info("SendCmdToMe:" .. s)
    TcpServer.sendByServerID(zonetask.unLinkId, s)
end

ZoneInfo.SendCmdToMeById = function(doinfo, data, gameid, zoneid)
    if type(doinfo) ~= "string" or type(data) ~= "table" then
        unilight.error("Zone.SendCmdToMe param error.........type(doinfo):"..type(doinfo).." type(data)" .. type(data))
        return
    end
    local send = {}
    send["do"] = doinfo
    send["data"] = data
    local s = json.encode(send)
    unilight.info("SendCmdToMeById:" .. s)
    local unlinkId = ZoneInfo[gameid]
    TcpServer.sendByServerID(unlinkId, s)
end