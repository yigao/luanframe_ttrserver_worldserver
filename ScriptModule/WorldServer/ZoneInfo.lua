Zone = Zone or {}
ZoneInfo = ZoneInfo or { }
ZoneInfo.ZoneTaskMap = {}
Zone.zone_connect = function(cmd, zonetask) 
    unilight.info("大厅服务器回调：新的区连进来了 ")
    --ZoneInfo.ZoneTaskMap[zonetask.serverId] = zonetask.unLinkId
end

Zone.zone_disconnect = function(cmd, zonetask) 
    unilight.info("大厅服务器回调：区掉线了了 ")
    ZoneInfo.ZoneTaskMap[zonetask.serverId] = nil
end

Zone.zone_change_props = function(cmd, zonetask)

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
    local unlinkId = ZoneInfo.ZoneTaskMap[gameid]
    TcpServer.sendByServerID(unlinkId, s)
end

ZoneInfo.SendCmdToFirst = function(doinfo, data)
    if type(doinfo) ~= "string" or type(data) ~= "table" then
        unilight.error("Zone.SendCmdToMe param error.........type(doinfo):"..type(doinfo).." type(data)" .. type(data))
        return
    end
    local send = {}
    send["do"] = doinfo
    send["data"] = data
    local s = json.encode(send)
    unilight.info("SendCmdToFirst:" .. s)
    for k, v in pairs(ZoneInfo.ZoneTaskMap) do
        TcpServer.sendByServerID(v, s)
        return
    end
end

ZoneInfo.SendCmdToAll = function(doinfo, data, gameid, zoneid)
    if type(doinfo) ~= "string" or type(data) ~= "table" then
        unilight.error("Zone.SendCmdToMe param error.........type(doinfo):"..type(doinfo).." type(data)" .. type(data))
        return
    end
    local send = {}
    send["do"] = doinfo
    send["data"] = data
    local s = json.encode(send)
    unilight.info("SendCmdToAll:" .. s)
    for k, v in pairs(ZoneInfo.ZoneTaskMap) do
        if k ~= gameid then
            TcpServer.sendByServerID(v, s)
        end
    end
end