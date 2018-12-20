Zone = Zone or {}
ZoneInfo = ZoneInfo or { }
Zone.zone_connect = function(cmd, zonetask) 
    unilight.info("大厅服务器回调：新的区连进来了 " .. zonetask.GetGameId() .. ":" .. zonetask.GetZoneId())
       ZoneInfo[tostring(zonetask.GetGameId())..zonetask.GetZoneId()] = zonetask
end

Zone.zone_disconnect = function(cmd, zonetask) 
    unilight.info("大厅服务器回调：区掉线了了 " .. zonetask.GetGameId() .. ":" .. zonetask.GetZoneId())
    ZoneInfo[tostring(zonetask.GetGameId())..zonetask.GetZoneId()] = nil
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
    zonetask.SendString(s)
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
    local zonetask = ZoneInfo[tostring(gameid)..zoneid]
    if zonetask ~= nil then
        zonetask.SendString(s)
    end
end