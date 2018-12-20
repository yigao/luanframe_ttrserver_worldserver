
-- 获得好友互访数据
Zone.CmdGetFriendVisitInfo_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.GetFriendVisitInfo_S"

    local uid = cmd.data.cmd_uid

    --检查客户端数据输入
    if cmd["data"] == nil or type(cmd["data"].uid) ~= "number" then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return;
    end

    local f_uid = cmd["data"].uid
    local friendData = FriendManager:GetOrNewFriendInfo(uid)
    local friendvisitData = friendData:GetFriendVisit()

    local f_friendData = FriendManager:GetFriendInfo(f_uid)
    if f_friendData == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.ID_NOT_FOUND,
            desc = "该玩家不存在",
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    local f_travelData = f_friendData:GetUserTravel()
    local f_friendvisitData = f_friendData:GetFriendVisit()

    local visit_friend = {
        uid = f_uid,
        head = f_friendData:GetHead(),
        name = f_friendData:GetName(),
        star = f_friendData:GetStar(),
        sex = f_friendData:GetSex(),
        money = f_friendData:GetMoney(),
        product = f_friendData:GetProduct(),
        travel_level = f_travelData:GetLevel(),
        cur_mapid = f_friendvisitData:GetCurMapId(),
        today_encouraged_number = f_friendvisitData:GetEncouragedNumber(),
        today_beteased_number = f_friendvisitData:GetBeteasedNumber(),
        is_today_mischief = friendvisitData:IsTodayMischief(f_uid),
        is_today_inspire = friendvisitData:IsTodayInspire(f_uid),
        builds = {},
        travel_member = {},
    }

    local f_friendvisitData_builds = f_friendvisitData:GetBuilds()
    for id, build in pairs(f_friendvisitData_builds) do
        local tmp = {
            id = build.id,
            lv = build.lv,
            buildlv = build.buildlv,
        }
        table.insert(visit_friend.builds, tmp)
    end

    local self_travel = {
        uid = f_friendData:GetUid(),
        head = f_travelData:GetTravelHead(),
        name = f_friendData:GetName(),
        star = f_friendData:GetStar(),
        sex = f_friendData:GetSex(),
        travel_level = f_travelData:GetLevel(),
    }

    table.insert(visit_friend.travel_member, self_travel)

    f_travelData:MembersForEach(
        function(m_uid, m_t)
            local m_friendData = FriendManager:GetFriendInfo(m_uid)
            if m_friendData ~= nil then
                local m_travelData = m_friendData:GetUserTravel()
                local tmp = {
                    uid = m_friendData:GetUid(),
                    head = m_travelData:GetTravelHead(),
                    name = m_friendData:GetName(),
                    star = m_friendData:GetStar(),
                    sex = m_friendData:GetSex(),
                    travel_level = m_travelData:GetLevel(),
                }
                table.insert(visit_friend.travel_member, tmp)
            end

        end
    )

    FriendManager.NotifyMainTaskAddProgress(zonetask, friendData, TaskConditionEnum.VisitFriendEvent, 1)

    res["data"] = {
        cmd_uid = uid,
        resultCode = 0,
        desc = "",
        friend = visit_friend,
    }

    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
    return
end

--鼓舞好友,单词用错先保留
Zone.CmdMischiefFriend_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.MischiefFriend_S"

    local uid = cmd.data.cmd_uid

    --检查客户端数据输入
    if cmd["data"] == nil or type(cmd["data"].uid) ~= "number" then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return;
    end

    local f_uid = cmd["data"].uid
    local friendData = FriendManager:GetOrNewFriendInfo(uid)

    --玩家可能不在线,设置离线数据被该标志
    friendData:SetOfflineChange()

    local friendvisitData = friendData:GetFriendVisit()
    local travelData = friendData:GetUserTravel()

    if friendData:GetUserFriend(f_uid) == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.FRIEND_VISIT_NOT_FRIEND,
            desc = "",
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    if friendvisitData:MischiefNumberIsLimit() then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.FRIEND_VISIT_TO_VISIT_LIMIT,
            desc = "",
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    if friendvisitData:IsTodayMischief(f_uid) then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.FRIEND_VISIT_TODAY_MISCHIEF,
            desc = "",
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    local f_friendData = FriendManager:GetFriendInfo(f_uid)
    if f_friendData == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.ID_NOT_FOUND,
            desc = "",
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    local f_friendvisitData = f_friendData:GetFriendVisit()
    local f_travelData = f_friendData:GetUserTravel()

    --玩家可能不在线,设置离线数据被该标志
    f_friendData:SetOfflineChange()

    if f_friendvisitData:EncouragedNumberIsLimit() then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.FRIEND_VISIT_ENCOURAGED_LIMIT,
            desc = "",
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    local targetmoney = 0
    local targetproduct = 0

    targetmoney = f_friendData:GetMoney()
    targetproduct = f_friendData:GetProduct()

    local money = math.min(friendData:GetProduct(), targetproduct)*120 + f_friendData:GetStar() * 100
    money = math.ceil(money)
    if money <= 0 then
        money = 1
    end

    FriendManager.AddUserMoney(zonetask, friendData, static_const.Static_MoneyType_Gold, money)
    FriendManager.AddUserMoney(zonetask, f_friendData, static_const.Static_MoneyType_Gold, money)

    travelData:AddRelationShip(f_uid)
    f_travelData:AddRelationShip(uid)

    friendvisitData:SetLastMischiefTime(os.time())
    friendvisitData.last_mischief_money = money

    friendvisitData:AddMischiefNumber()
    friendvisitData:RecordMischiefFriend(f_uid)

    f_friendvisitData:AddEncouragedNumber()

    --鼓舞或捣蛋好友，通知下对方
    f_friendData:Give(zonetask, friendData, MsgTypeEnum.FriendVisitMischiefFriend, {tostring(money),})

    FriendManager.NotifyMainTaskAddProgress(zonetask, friendData, TaskConditionEnum.InspireFriendEvent, 1)

    res["data"] = {
        cmd_uid = uid,
        resultCode = 0,
        desc = "",
        count = friendvisitData:GetMischiefNumber(),
        money = money,
    }
    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
    return;
end

--捣蛋好友, 单词用错先保留
Zone.CmdInspireFriend_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.InspireFriend_S"

    local uid = cmd.data.cmd_uid

    --检查客户端数据输入
    if cmd["data"] == nil or type(cmd["data"].uid) ~= "number" or type(cmd["data"].buildid) ~= "number" then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return;
    end

    local f_uid = cmd["data"].uid
    local buildid = cmd["data"].buildid
    local friendData = FriendManager:GetOrNewFriendInfo(uid)
    local friendvisitData = friendData:GetFriendVisit()
    local travelData = friendData:GetUserTravel()

    --玩家可能不在线,设置离线数据被该标志
    friendData:SetOfflineChange()

    if friendData:GetUserFriend(f_uid) == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.FRIEND_VISIT_NOT_FRIEND,
            desc = "不是好友不能访问",
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    if friendvisitData:IsTodayInspire(f_uid) then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.FRIEND_VISIT_TODAY_INSPIRE,
            desc = "",
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    --是否可以看视屏
    local see_sceen = friendvisitData:IsTodayInspireSeeSceen(f_uid)

    --主要考虑到看视屏赠送了一次
    if friendvisitData:InspireNumberIsLimit() then
        if see_sceen == true then
            res["data"] = {
                cmd_uid = uid,
                resultCode = ERROR_CODE.FRIEND_VISIT_TO_VISIT_LIMIT,
                desc = "",
            }
            ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
            return
        end
    end

    local f_friendData = FriendManager:GetFriendInfo(f_uid)
    if f_friendData == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.ID_NOT_FOUND,
            desc = "该玩家不存在",
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    --玩家可能不在线,设置离线数据被该标志
    f_friendData:SetOfflineChange()

    local f_travelData = f_friendData:GetUserTravel()
    local f_friendvisitData = f_friendData:GetFriendVisit()

    if f_friendvisitData:BeteasedNumberIsLimit() then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.FRIEND_VISIT_BETEASED_LIMIT,
            desc = "",
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    --查看使用猜中
    local guest = false
    local reward_buildid = f_friendvisitData:GetLastInpireBuildId()
    if buildid == reward_buildid then
        guest = true
        f_friendvisitData:GetRandBuilds()
    end

    local money = 0
    
    if guest == true then 
       money = math.min(friendData:GetProduct(), f_friendData:GetProduct())*360 + f_friendData:GetStar() * 100
    else
    money = math.min(friendData:GetProduct(), f_friendData:GetProduct())*60 + f_friendData:GetStar() * 100
    end
    money = math.ceil(money)
    if money <= 0 then
        money = 1
    end

    FriendManager.AddUserMoney(zonetask, friendData, static_const.Static_MoneyType_Gold, money)
    FriendManager.SubUserMoney(zonetask, f_friendData, static_const.Static_MoneyType_Gold, money)

    friendvisitData:SetLastInspireTime(os.time())

    if see_sceen == true then
        friendvisitData:AddInspireNumber()
        f_friendvisitData:AddBeteasedNumber()
    end

    friendvisitData:RecordInspireFriend(f_uid)

    --鼓舞或捣蛋好友，通知下对方
    f_friendData:Give(zonetask, friendData, MsgTypeEnum.FriendVisitInspireFriend, {tostring(money),})

    FriendManager.NotifyMainTaskAddProgress(zonetask, friendData, TaskConditionEnum.MischiefFriendEvent, 1)

    res["data"] = {
        cmd_uid = uid,
        resultCode = 0,
        desc = "",
        count = friendvisitData:GetInspireNumber(),
        money = money,
        see_sceen = see_sceen,
        reward_buildid = reward_buildid,
        guest = guest,
    }
    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
    return;
end

--鼓舞看视频完回调
Zone.CmdMischiefFriend_Screen_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.MischiefFriend_Screen_S"

    local uid = cmd.data.cmd_uid

    --检查客户端数据输入
    if cmd["data"] == nil or type(cmd["data"].uid) ~= "number" then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return;
    end

    local f_uid = cmd["data"].uid
    local friendData = FriendManager:GetOrNewFriendInfo(uid)
    local friendvisitData = friendData:GetFriendVisit()
    local travelData = friendData:GetUserTravel()

    --玩家可能不在线,设置离线数据被该标志
    friendData:SetOfflineChange()

    local f_friendData = FriendManager:GetFriendInfo(f_uid)
    if f_friendData == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.ID_NOT_FOUND,
            desc = "该玩家不存在",
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    --玩家可能不在线,设置离线数据被该标志
    f_friendData:SetOfflineChange()

    local f_travelData = f_friendData:GetUserTravel()
    local f_friendvisitData = f_friendData:GetFriendVisit()

    local money = friendvisitData.last_mischief_money

    FriendManager.AddUserMoney(zonetask, friendData, static_const.Static_MoneyType_Gold, money)
    FriendManager.AddUserMoney(zonetask, f_friendData, static_const.Static_MoneyType_Gold, money)

    travelData:AddRelationShip(f_uid)
    f_travelData:AddRelationShip(uid)

    res["data"] = {
        cmd_uid = uid,
        resultCode = 0,
        desc = "",
        count = friendvisitData:GetMischiefNumber(),
        money = money*2,
    }
    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
    return;
end

--//捣蛋看视频完回调
Zone.CmdInspireFriend_Screen_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.InspireFriend_Screen_S"

    local uid = cmd.data.cmd_uid

    --检查客户端数据输入
    if cmd["data"] == nil or type(cmd["data"].uid) ~= "number" then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return;
    end

    local f_uid = cmd["data"].uid
    local friendData = FriendManager:GetOrNewFriendInfo(uid)
    local friendvisitData = friendData:GetFriendVisit()

    --玩家可能不在线,设置离线数据被该标志
    friendData:SetOfflineChange()

    friendvisitData:AgainInspireFriend(f_uid)

    res["data"] = {
        cmd_uid = uid,
        resultCode = 0,
        desc = "",
        count = friendvisitData:GetInspireNumber(),
        money = 0,
    }
    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
    return;
end

