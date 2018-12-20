Zone.CmdReqGetWorldRankListInfo_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.ReqGetWorldRankListInfo_S"
    local uid = cmd.data.cmd_uid
    --检查客户端输入
    if cmd["data"] == nil or type(cmd["data"].rank_type) ~= "number" or 
    type(cmd["data"].start_index) ~= "number" or 
    type(cmd["data"].end_index) ~= "number" then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    local rankType = cmd["data"].rank_type
    local startIndex = cmd["data"].start_index
    local endIndex = cmd["data"].end_index

    if startIndex > endIndex then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return    
    end

    local friendData = FriendManager:GetOrNewFriendInfo(uid);
    local travelData = friendData:GetUserTravel()

    local data = RankListMgr:ReqGetData(rankType)

    if data == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据rankType出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    res["data"] = {cmd_uid = uid,}
    res["data"].rank_node = {}
    res["data"].rank_type = rankType

    local rankList = RankListMgr:GetRankList(rankType)
    if rankList ~= nil then
        local self_node = rankList:GetNode(uid)
        if self_node ~= nil then
            res["data"].self_node = {
                uid = self_node:GetUid(),
                value = self_node:GetLastValue(),
                name = friendData:GetName(),
                head = friendData:GetHead(),
                sex = friendData:GetSex(),
                star = friendData:GetStar(),
                signature =  friendData:GetSignature(), 
                area =  friendData:GetArea(), 
                horoscope =  friendData:GetHoroscope(),
                friend_ship = travelData:GetRelationShip(self_node:GetUid()),
                rank = self_node:GetRank(),
            } 
        end
    end

    if startIndex > GlobalConst.Ranking_shows then
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    if endIndex > GlobalConst.Ranking_shows then
        endIndex = GlobalConst.Ranking_shows
    end

    for index=startIndex, endIndex do
        local node = data[index]
        if node == nil then 
            ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
            return
        end
        local node_friendData = FriendManager:GetFriendInfo(node:GetUid());
        if node_friendData ~= nil then
            local tmp = {
                uid = node:GetUid(),
                value = node:GetLastValue(),
                name = node_friendData:GetName(),
                head = node_friendData:GetHead(),
                sex = node_friendData:GetSex(),
                star = node_friendData:GetStar(),
                signature =  node_friendData:GetSignature(), 
                area =  node_friendData:GetArea(), 
                horoscope =  node_friendData:GetHoroscope(),
                friend_ship = travelData:GetRelationShip(node:GetUid()),
                rank = node:GetRank(),
            }
            table.insert(res["data"].rank_node, tmp)
        end
    end

    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
    return
end