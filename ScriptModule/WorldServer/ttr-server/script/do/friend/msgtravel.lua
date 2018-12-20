
-- 客户端获得旅行团信息
Zone.CmdGetUserTravelInfo_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.GetUserTravelInfo_S"

    local uid = cmd.data.cmd_uid
    local friendData = FriendManager:GetOrNewFriendInfo(uid);
    local travelData = friendData:GetUserTravel()

    res["data"] = {cmd_uid = uid,}
    res["data"].level = travelData:GetLevel()
    res["data"].head = travelData:GetTravelHead()
    res["data"].capture_times = travelData:GetCaptureTimes()
    res["data"].unlock_slot_count = travelData:GetUnlockSlotCount() - travelData:GetMemberCount()
    res["data"].today_buy_capture_times = travelData:GetTodayBuyCaptureTimes()
    res["data"].anger = travelData:GetAnger()
    res["data"].anger_click_count = travelData:GetAngerClickCount()
    res["data"].head_backup = {}

    local head_backup = travelData:GetTravelHeadBackup()
    head_backup:ForEach(
        function(k,v)
            table.insert(res["data"].head_backup, k)
        end
    )

    res["data"].member = {}

    --轮询收集每个旅行团成员的数据
    travelData:MembersForEach(
        function(m_uid, m_time)
            if m_time + static_const.Static_Const_TRAVEL_Employ_MAX_TIME > os.time() then
                local member = { }
                member.uid = m_uid
                if m_uid == static_const.Static_Const_Friend_Travel_GOLD_GUEST_UID then
                    member.head = travelData:GetTravelHead()
                    member.name = static_const.Static_Const_Friend_Travel_GOLD_GUEST_NAME
                    member.star =  friendData:GetStar()
                    member.sex =  friendData:GetSex()
                    member.signature = friendData:GetSignature()
                    member.area =  friendData:GetArea()
                    member.horoscope =  friendData:GetHoroscope()
                    member.relation_ship = 0
                    member.travel_level = 0
                    member.level_time = (static_const.Static_Const_TRAVEL_Employ_MAX_TIME+m_time) - os.time()
                    table.insert(res["data"].member, member)
                else
                    local member_friendData = FriendManager:GetFriendInfo(m_uid); 
                    if member_friendData ~= nil then
                        local member_travelData = member_friendData:GetUserTravel()
                        member.head = member_travelData:GetTravelHead()
                        member.name = member_friendData:GetName()
                        member.star =  member_friendData:GetStar() 
                        member.sex =  member_friendData:GetSex() 
                        member.signature =  member_friendData:GetSignature()
                        member.area =  member_friendData:GetArea()
                        member.horoscope =  member_friendData:GetHoroscope()
                        member.relation_ship = travelData:GetRelationShip(m_uid)
                        member.travel_level = member_travelData:GetLevel()
                        member.level_time = (static_const.Static_Const_TRAVEL_Employ_MAX_TIME+m_time) - os.time()
                        table.insert(res["data"].member, member)
                    end
                end
            end
        end
    )

    --travelData:PrintUserTravel()
    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end

-- 打开好友雇佣界面信息
Zone.CmdGetTravelEmployFriend_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.GetTravelEmployFriend_S"

    local uid = cmd.data.cmd_uid
    local friendData = FriendManager:GetOrNewFriendInfo(uid);
    local travelData = friendData:GetUserTravel()

    res["data"] = {cmd_uid = uid,}
    res["data"].member = {}

    --轮询好友信息， 筹集数据
    friendData:UserFriendsForEach(
        function(f_uid, f_info)
            if travelData:IsExistMembers(f_uid) == false and f_uid ~= uid then
                local f_friendData = FriendManager:GetFriendInfo(f_uid)
                if f_friendData ~= nil then
                    local f_travelData = f_friendData:GetUserTravel()
                    local tmp = {}
                    tmp.uid = f_uid
                    tmp.head = f_travelData:GetTravelHead()
                    tmp.name = f_friendData:GetName()
                    tmp.star =  f_friendData:GetStar()
                    tmp.sex =  f_friendData:GetSex()
                    tmp.signature =  f_friendData:GetSignature()
                    tmp.area =  f_friendData:GetArea()
                    tmp.horoscope =  f_friendData:GetHoroscope()
                    tmp.travel_level = f_travelData:GetLevel()
                    tmp.relation_ship = f_travelData:GetRelationShip(uid)
                    tmp.cur_employ_uid = f_travelData:GetEmployUid()
                    tmp.cur_employ_name = f_travelData:GetEmployName()
                    tmp.employ_cd = 0

                    --这说明你不久前雇佣过对方
                    if uid == f_travelData:GetLastEmployUid() then
                        tmp.employ_cd = f_travelData:GetEmployCdLeftTime()
                    else
                        tmp.employ_cd = 0
                    end
                    table.insert(res["data"].member, tmp)     
                end
            end
        end
    )

    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end

-- 打开推荐雇佣界面信息
Zone.CmdGetTravelEmployRecommend_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.GetTravelEmployRecommend_S"

    local uid = cmd.data.cmd_uid
    local friendData = FriendManager:GetOrNewFriendInfo(uid);
    local travelData = friendData:GetUserTravel()

    res["data"] = {cmd_uid = uid,}
    res["data"].member = {}

    --首先放金牌客户
    if travelData:IsExistMembers(static_const.Static_Const_Friend_Travel_GOLD_GUEST_UID) == false then
        local tmp = {}
        tmp.uid = static_const.Static_Const_Friend_Travel_GOLD_GUEST_UID
        tmp.head = travelData:GetTravelHead()
        tmp.name = static_const.Static_Const_Friend_Travel_GOLD_GUEST_NAME
        tmp.star =  friendData:GetStar()
        tmp.sex =  friendData:GetSex()
        tmp.signature =  friendData:GetSignature()
        tmp.area =  friendData:GetArea()
        tmp.horoscope =  friendData:GetHoroscope()
        tmp.travel_level = 0
        tmp.relation_ship = 0
        tmp.cur_employ_uid = 0
        tmp.cur_employ_name = ""
        tmp.employ_cd = 0

        table.insert(res["data"].member, tmp)
    end

    --选择条件匹配的可推荐对象
    --玩家不能已经被雇佣
    --玩家不能是好友
    --玩家等级必须小
    --不能再CD时间里
    local count = 0
    for f_uid, f_friendData in pairs(FriendManager.userFriend.map) do
        if travelData:IsExistMembers(f_uid) == false and friendData:GetUserFriend(f_uid) == nil and f_uid ~= uid then
            local f_travelData = f_friendData:GetUserTravel()
            if travelData:GetLevel() >= f_travelData:GetLevel() and f_travelData:GetEmployUid() == 0 then
                --这说明你不久前雇佣过对方, 不在CD时间里
                if uid ~= f_travelData:GetLastEmployUid() or f_travelData:GetEmployCdLeftTime() == 0 then
                    local tmp = {}
                    tmp.uid = f_uid
                    tmp.head = f_travelData:GetTravelHead()
                    tmp.name = f_friendData:GetName()
                    tmp.star =  f_friendData:GetStar()
                    tmp.sex =  f_friendData:GetSex()
                    tmp.signature =  f_friendData:GetSignature()
                    tmp.area =  f_friendData:GetArea()
                    tmp.horoscope =  f_friendData:GetHoroscope()
                    tmp.travel_level = f_travelData:GetLevel()
                    tmp.relation_ship = f_travelData:GetRelationShip(uid)
                    tmp.cur_employ_uid = f_travelData:GetEmployUid()
                    tmp.cur_employ_name = f_travelData:GetEmployName()
                    tmp.employ_cd = 0

                    table.insert(res["data"].member, tmp)

                    if #res["data"].member >= static_const.Static_Const_TRAVEL_MAX_RECOMMEND_COUNT then
                        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
                        return
                    end
                end
            end
        end
    end

    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end

-- 雇佣或抓捕玩家
Zone.CmdEmployFriendToTravel_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.EmployFriendToTravel_S"
    local uid = cmd.data.cmd_uid
    if cmd["data"] == nil or type(cmd["data"].uid) ~= "number" then
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
    --玩家可能不在线,设置离线数据被该标志
    friendData:SetOfflineChange()

    if travelData:GetMemberCount() >= travelData:GetUnlockSlotCount() then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.TRAVEL_NO_POS,
            desc = "没有更多位置了，需解锁新位置"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    local employ_uid = cmd["data"].uid

    if employ_uid == uid then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    if travelData:IsExistMembers(employ_uid) == true then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.TRAVEL_CANNOT_EMPLY_TWICE,
            desc = "已经被你雇佣过了"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    --金牌客户处理
    if employ_uid == static_const.Static_Const_Friend_Travel_GOLD_GUEST_UID then
        --设置抓捕信息
        travelData:AddMember(employ_uid)
        travelData:StartEmployEndTimer(employ_uid)

        --从新计算一次旅行团加成
        travelData:CalcAddontion()
        FriendManager.UpdateCalcAddontion(friendData)

        --任务系统，任务完成情况
        FriendManager.NotifyDailyTaskAddProgress(zonetask, friendData, TaskConditionEnum.EmployFriendEvent, 1)
        FriendManager.NotifyAchieveTaskAddProgress(zonetask, friendData, TaskConditionEnum.EmployFriendEvent, 1)
        FriendManager.NotifyMainTaskAddProgress(zonetask, friendData, TaskConditionEnum.EmployFriendEvent, 1)

        res["data"] = {
            cmd_uid = uid,
            resultCode = 0,
            desc = "雇佣成功",
            capture_times = travelData:GetCaptureTimes(),
            today_buy_capture_times = travelData:GetTodayBuyCaptureTimes(),
            member = {
                uid = employ_uid,
                head = travelData:GetTravelHead(),
                name = static_const.Static_Const_Friend_Travel_GOLD_GUEST_NAME,
                star =  friendData:GetStar(),
                sex =  friendData:GetSex(),
                signature =  friendData:GetSignature(),
                area =  friendData:GetArea(),
                horoscope =  friendData:GetHoroscope(),
                travel_level = 0,
                relation_ship = 0,
                level_time = static_const.Static_Const_TRAVEL_Employ_MAX_TIME,
            },
            type = 0,
            isCapture = false,
        }

        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    local employ_friendData = FriendManager:GetFriendInfo(employ_uid)
    if employ_friendData == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "对方不存在"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    --玩家可能不在线,设置离线数据被该标志
    employ_friendData:SetOfflineChange()

    local employ_travelData = employ_friendData:GetUserTravel()

    if employ_travelData:GetLastEmployUid() == uid then
        if employ_travelData:GetEmployCdLeftTime() > 0 then
            res["data"] = {
                cmd_uid = uid,
                resultCode = ERROR_CODE.TRAVEL_IN_EMPLOY_CD,
                desc = "雇佣CD时间，暂时不能被你雇佣",
                capture_times = travelData:GetCaptureTimes(),
                today_buy_capture_times = travelData:GetTodayBuyCaptureTimes(),
            }
            ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
            return
        end
    end

    if employ_travelData:GetLevel() > travelData:GetLevel() then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.TRAVEL_LEVEL_LIMIT,
            desc = "",
            capture_times = travelData:GetCaptureTimes(),
            today_buy_capture_times = travelData:GetTodayBuyCaptureTimes(),
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    local isCapture = false
    --玩家正在别雇佣，抓捕他们 删除原有的雇佣信息，并通知对方
    if employ_travelData:GetEmployUid() ~= 0 then

        --抓捕逻辑,抓捕次数有限制
        if friendData:GetUserFriend(employ_uid) == nil then
            res["data"] = {
                cmd_uid = uid,
                resultCode = ERROR_CODE.TRAVEL_HAS_EMPLOYED_BY_OTHERS,
                desc = "被别的玩家雇佣",
                capture_times = travelData:GetCaptureTimes(),
                today_buy_capture_times = travelData:GetTodayBuyCaptureTimes(),
            }
            ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
            return
        end

        --任务系统，任务完成情况
        FriendManager.NotifyDailyTaskAddProgress(zonetask, friendData, TaskConditionEnum.CaptureFriendEvent, 1)
        FriendManager.NotifyMainTaskAddProgress(zonetask, friendData, TaskConditionEnum.CaptureFriendEvent, 1)

        --查看玩家当前抓捕次数
        if travelData:GetCaptureTimes() <= 0 then
            --扣钱和比较钱的操作
            if cmd.data.cur_diamond < travelData:GetTodayBuyCaptureTimes_NeedCost() then
                res["data"] = {
                    cmd_uid = uid,
                    resultCode = ERROR_CODE.DIAMOND_NOT_ENOUGH,
                    desc = "你的砖石不够",
                    capture_times = travelData:GetCaptureTimes(),
                    today_buy_capture_times = travelData:GetTodayBuyCaptureTimes(),
                }
                ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
                return
            end

            FriendManager.SubUserMoney(zonetask, friendData, static_const.Static_MoneyType_Diamond, travelData:GetTodayBuyCaptureTimes_NeedCost())
            travelData:AddTodayBuyCaptureTimes()
        end

        --减少一次抓捕次数
        travelData:DecCaptureTimes()

       local last_uid = employ_travelData:GetEmployUid()
       local last_friendData = FriendManager:GetFriendInfo(last_uid)
       if last_friendData ~= nil then
            --玩家可能不在线,设置离线数据被该标志
            last_friendData:SetOfflineChange()
            local last_travelData = last_friendData:GetUserTravel()

            if last_travelData:GetShieldCount() > 0 then
                last_travelData:SubShieldCount()

                last_friendData:Give(zonetask, friendData, MsgTypeEnum.FriendRobbedWithFailure)

                --任务系统，任务完成情况
                FriendManager.NotifyDailyTaskAddProgress(zonetask, last_friendData, TaskConditionEnum.StopCaptureEvent, 1)
                FriendManager.NotifyAchieveTaskAddProgress(zonetask, last_friendData, TaskConditionEnum.StopCaptureEvent, 1)

                if last_friendData:GetOnline() == true then
                    --在线的话通知对方
                    local notify_req = {}
                    notify_req["do"] = "Cmd.NotifyUserBuyShieldCount_S"
                    notify_req["data"] = {
                        cmd_uid = last_uid,
                        shield_count = last_travelData:GetShieldCount(),
                    }
                    ZoneInfo.SendCmdToMeById(notify_req["do"], notify_req["data"], last_friendData.gameid, last_friendData.zoneid)
                end

                res["data"] = {
                    cmd_uid = uid,
                    resultCode = 0,
                    desc = "",
                    capture_times = travelData:GetCaptureTimes(),
                    today_buy_capture_times = travelData:GetTodayBuyCaptureTimes(),
                    type = 1,
                    isCapture = true,
                    member = {
                        uid = employ_uid,
                        head = employ_travelData:GetTravelHead(),
                        name = employ_friendData:GetName(),
                        star =  employ_friendData:GetStar(),
                        sex =  employ_friendData:GetSex(),
                        signature =  employ_friendData:GetSignature(),
                        area =  employ_friendData:GetArea(),
                        horoscope =  employ_friendData:GetHoroscope(),
                        travel_level = employ_travelData:GetLevel(),
                        relation_ship = employ_travelData:GetRelationShip(uid),
                        level_time = 0,
                    },
                    visit = FriendManager.GetCaptureFriendVisitFriend(employ_friendData)
                }
                ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
                return
            end

            last_travelData:DelMember(employ_uid)
            --先干掉定时器
            last_travelData:StopEmployEndTimer(employ_uid)

            --玩家可能不在线,设置离线数据被该标志
            last_friendData:SetOfflineChange()

            --从新计算被抢了旅行团成员的旅行团加成
            last_travelData:CalcAddontion()
            FriendManager.UpdateCalcAddontion(last_friendData)

            isCapture = true

            --抓捕了对方好友，通知下对方
            last_friendData:Give(zonetask, friendData, MsgTypeEnum.FriendRobbed)

            --任务系统，任务完成情况
            FriendManager.NotifyDailyTaskAddProgress(zonetask, last_friendData, TaskConditionEnum.CaptureFriendEvent, 1)
            FriendManager.NotifyAchieveTaskAddProgress(zonetask, last_friendData, TaskConditionEnum.CaptureFriendEvent, 1)

            if last_friendData:GetOnline() == true then
                --在线的话通知对方
                local req = { }
                req["do"] = "Cmd.NotifyUserTravelCapture_S"
                req["data"] = {
                    cmd_uid = last_uid, 
                    uid = employ_uid,
                }
                ZoneInfo.SendCmdToMeById(req["do"], req["data"], last_friendData.gameid, last_friendData.zoneid)
            end
       end
    end

    --设置抓捕信息
    employ_travelData:SetEmployUid(uid)
    employ_travelData:SetEmployName(friendData:GetName())
    travelData:AddMember(employ_uid)
    travelData:StartEmployEndTimer(employ_uid)

    --玩家可能不在线,设置离线数据被该标志
    employ_friendData:SetOfflineChange()

    --从新计算一次旅行团加成
    travelData:CalcAddontion()
    FriendManager.UpdateCalcAddontion(friendData)

    --任务系统，任务完成情况
    if isCapture == false then
        FriendManager.NotifyDailyTaskAddProgress(zonetask, friendData, TaskConditionEnum.EmployFriendEvent, 1)
        FriendManager.NotifyAchieveTaskAddProgress(zonetask, friendData, TaskConditionEnum.EmployFriendEvent, 1)
        FriendManager.NotifyMainTaskAddProgress(zonetask, friendData, TaskConditionEnum.EmployFriendEvent, 1)
    end

    res["data"] = {
        cmd_uid = uid,
        resultCode = 0,
        desc = "雇佣成功",
        capture_times = travelData:GetCaptureTimes(),
        today_buy_capture_times = travelData:GetTodayBuyCaptureTimes(),
        member = {
            uid = employ_uid,
            head = employ_travelData:GetTravelHead(),
            name = employ_friendData:GetName(),
            star =  employ_friendData:GetStar(),
            sex =  employ_friendData:GetSex(),
            signature =  employ_friendData:GetSignature(),
            area =  employ_friendData:GetArea(),
            horoscope =  employ_friendData:GetHoroscope(),
            travel_level = employ_travelData:GetLevel(),
            relation_ship = employ_travelData:GetRelationShip(uid),
            level_time = static_const.Static_Const_TRAVEL_Employ_MAX_TIME,
        },
        type = 0,
        isCapture = isCapture,
    }

    if isCapture == true then
        res["data"].visit = FriendManager.GetCaptureFriendVisitFriend(employ_friendData)
    end

    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end

-- 清楚雇佣CD时间
Zone.CmdClearEmployFriendCD_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.ClearEmployFriendCD_S"
    local uid = cmd.data.cmd_uid
    if cmd["data"] == nil or type(cmd["data"].uid) ~= "number" then
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
    --玩家可能不在线,设置离线数据被该标志
    friendData:SetOfflineChange()
    
    local employ_uid = cmd["data"].uid

    --判断是否已经被你雇佣
    if travelData:IsExistMembers(employ_uid) == true then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.TRAVEL_CANNOT_EMPLY_TWICE,
            desc = "已经被你雇佣过了"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    if employ_uid == static_const.Static_Const_Friend_Travel_GOLD_GUEST_UID then

    end

    --判断对方是否存在
    local employ_friendData = FriendManager:GetFriendInfo(employ_uid)
    if employ_friendData == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "对方不存在"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    --玩家可能不在线,设置离线数据被该标志
    employ_friendData:SetOfflineChange()

    local employ_travelData = employ_friendData:GetUserTravel()

    --判断当前等级
    if employ_travelData:GetLevel() > travelData:GetLevel() then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.TRAVEL_LEVEL_LIMIT,
            desc = "该好友等级高过你，不能雇佣（抓捕）"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    --如果需要清理的话
    if employ_travelData:GetLastEmployUid() == uid then
        if employ_travelData:GetEmployCdLeftTime() > 0 then
            --扣钱和比较钱的操作
            if cmd.data.cur_diamond < GlobalConst.Travel_CD_Diamond then
                res["data"] = {
                    cmd_uid = uid,
                    resultCode = ERROR_CODE.DIAMOND_NOT_ENOUGH,
                    desc = "你的砖石不够"
                }
                ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
                return
            end

            FriendManager.SubUserMoney(zonetask, friendData, static_const.Static_MoneyType_Diamond, GlobalConst.Travel_CD_Diamond)
            --
            employ_travelData:SetLastEmployUid(0)
            employ_travelData:ClearEmployCd()
        end
    end

    res["data"] = {
        cmd_uid = uid,
        resultCode = 0,
        desc = "清理成功",
        uid = employ_uid,
    }
    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end

-- 解除雇佣关系
Zone.CmdRescissionEmployFriendShip_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.RescissionEmployFriendShip_S"
    local uid = cmd.data.cmd_uid
    if cmd["data"] == nil or type(cmd["data"].uid) ~= "number" then
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

    --玩家可能不在线,设置离线数据被该标志
    friendData:SetOfflineChange()

    local employ_uid = cmd["data"].uid

    if employ_uid == static_const.Static_Const_Friend_Travel_GOLD_GUEST_UID then
        --判断是否已经被你雇佣
        if travelData:IsExistMembers(employ_uid) == true then
            travelData:DelMember(employ_uid)
            --先干掉定时器
            travelData:StopEmployEndTimer(employ_uid)
        end

        --从新计算一次旅行团加成
        travelData:CalcAddontion()
        FriendManager.UpdateCalcAddontion(friendData)

        res["data"] = {
            cmd_uid = uid,
            resultCode = 0,
            desc = "",
            uid = employ_uid,
        }

        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    --判断对方是否存在
    local employ_friendData = FriendManager:GetFriendInfo(employ_uid)
    if employ_friendData == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "对方不存在"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    --玩家可能不在线,设置离线数据被该标志
    employ_friendData:SetOfflineChange()

    local employ_travelData = employ_friendData:GetUserTravel()

    --判断是否已经被你雇佣
    if travelData:IsExistMembers(employ_uid) == true then
        travelData:DelMember(employ_uid)
        --先干掉定时器
        travelData:StopEmployEndTimer(employ_uid)

        employ_travelData:SetEmployUid(0)
        employ_travelData:SetEmployName("")

        --玩家可能不在线,设置离线数据被该标志
        employ_friendData:SetOfflineChange()
    end
    
    --从新计算一次旅行团加成
    travelData:CalcAddontion()
    FriendManager.UpdateCalcAddontion(friendData)
    
    res["data"] = {
        cmd_uid = uid,
        resultCode = 0,
        desc = "",
        uid = employ_uid,
    }

    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end

-- 团长升级
Zone.CmdUserTravelLevelUp_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.UserTravelLevelUp_S"

    local uid = cmd.data.cmd_uid
    local friendData = FriendManager:GetOrNewFriendInfo(uid);
    local travelData = friendData:GetUserTravel()
    local level = travelData:GetLevel()

    --玩家可能不在线,设置离线数据被该标志
    friendData:SetOfflineChange()

    --升级自身需要的条件traveLevel
    local need = traveLevel.query(level+1)
    if need ~= nil then
        if friendData:GetStar() < need.star then
            res["data"] = {
                cmd_uid = uid,
                resultCode = ERROR_CODE.TRAVEL_STAR_NOT_ENOUGH,
                desc = "星级不够"
            }
            ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
            return
        end

        local money_table = string.split(need.cost, "_")
        local money_type, money =  money_table[1], money_table[2]
        if money_type == nil or money == nil then
            unilight.error("配置表数据出错.........")
            res["data"] = {
                cmd_uid = uid,
                resultCode = 1,
                desc = "",
            }
            ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
            return
        end

        if money_type == static_const.Static_MoneyType_Diamond then
            if cmd.data.cur_diamond < money then
                res["data"] = {
                    cmd_uid = uid,
                    resultCode = ERROR_CODE.MONEY_NOT_ENOUGH,
                    desc = "抱歉，你的钱不够"
                }
                ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
                return
            end
        elseif money_type == static_const.Static_MoneyType_Gold then
            if cmd.data.cur_money < money then
                res["data"] = {
                    cmd_uid = uid,
                    resultCode = ERROR_CODE.MONEY_NOT_ENOUGH,
                    desc = "抱歉，你的钱不够"
                }
                ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
                return
            end
        end

        FriendManager.SubUserMoney(zonetask, friendData, money_type, money)
    end

    travelData:LevelUp()
    --从新计算一次旅行团加成
    travelData:CalcAddontion()
    FriendManager.UpdateCalcAddontion(friendData)

    local last_uid = travelData:GetEmployUid()
    local last_friendData = FriendManager:GetFriendInfo(last_uid)
    if last_friendData ~= nil then
        local last_travelData = last_friendData:GetUserTravel()

        --玩家可能不在线,设置离线数据被该标志
        last_friendData:SetOfflineChange()

        --从新计算雇佣你的旅行团加成
        last_travelData:CalcAddontion()
        FriendManager.UpdateCalcAddontion(last_friendData)
    end

    res["data"] = {
        cmd_uid = uid,
        resultCode = 0,
        desc = "升级成功",
        unlock_count = 0,
    }

    --团员位置解锁的条件
    local cond = travelUnlock.query(travelData:GetUnlockSlotCount()+1)
    if cond ~= nil then
        if travelData:GetLevel() >= cond.level then
            travelData:AddUnlockSlotCount()
            res["data"].unlock_count = 1
        end
    end

    --任务系统，任务完成情况
    FriendManager.NotifyAchieveTaskAddProgress(zonetask, friendData, TaskConditionEnum.TravelLevelUpEvent, travelData:GetLevel())
    FriendManager.NotifyMainTaskAddProgress(zonetask, friendData, TaskConditionEnum.TravelLevelUpEvent, 1)
    FriendManager.NotifyMainTaskAddProgress(zonetask, friendData, TaskConditionEnum.TravelLevelValueEvent, travelData:GetLevel())

    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end

--更改玩家的旅行团头像
Zone.CmdChangeUserTravelHead_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.ChangeUserTravelHead_S"
    local uid = cmd.data.cmd_uid
    --检查客户端输入数据
    if cmd["data"] == nil or cmd["data"].head == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据错误",
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return   
    end

    local friendData = FriendManager:GetOrNewFriendInfo(uid);
    local travelData = friendData:GetUserTravel()
    local head = cmd["data"].head

    --玩家可能不在线,设置离线数据被该标志
    friendData:SetOfflineChange()

    if head == travelData:GetTravelHead() then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 0,
            desc = "",
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    if travelData:IsExistTravelHeadBackup(head) == false then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.TRAVEL_NEED_BUY_HEAD,
            desc = "这个头像需要先购买",
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    travelData:SetTravelHead(head)

    res["data"] = {
        cmd_uid = uid,
        resultCode = 0,
        desc = "",
        head = head,
    }
    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end

--怒气值满了，点击
Zone.CmdReleaseTravelAnger_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.ReleaseTravelAnger_S"

    local uid = cmd.data.cmd_uid

    --检查客户端数据输入
    if cmd["data"] == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    local friendData = FriendManager:GetOrNewFriendInfo(uid)
    local travelData = friendData:GetUserTravel()
    --玩家可能不在线,设置离线数据被该标志
    friendData:SetOfflineChange()

    if travelData:IsAngerFull() == false then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.TRAVEL_ANGER_NOT_FULL,
            desc = ""
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    local money = friendData:GetProduct() * 30 * 1000/(800+travelData:GetAnger());

    travelData:ClearAnger()
    travelData:AddAngerClickCount()
    travelData:SetAngerClickMoney(money)

    res["data"] = {
        cmd_uid = uid,
        resultCode = 0,
        desc = "",
        anger = travelData:GetAnger(),
        anger_click_count = travelData:GetAngerClickCount(),
    }

    if travelData:GetAngerClickCount() <= GlobalConst.Doublerage_Time then
        res["data"].money = money * 100
    else
        res["data"].money = money
        FriendManager.AddUserMoney(zonetask, friendData, static_const.Static_MoneyType_Gold, money)
    end

    unilight.error("money.."..tostring(res["data"].money).." clickcount"..tostring(travelData:GetAngerClickCount()))
    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end


--怒气值满了，点击后看视屏回调
Zone.CmdReleaseAngerSeeSceen_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.ReleaseAngerSeeSceen_S"

    local uid = cmd.data.cmd_uid

    --检查客户端数据输入
    if cmd["data"] == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    local see_screen = cmd["data"].see_screen;
    local friendData = FriendManager:GetOrNewFriendInfo(uid)
    local travelData = friendData:GetUserTravel()

    --玩家可能不在线,设置离线数据被该标志
    friendData:SetOfflineChange()

    local money = travelData:GetAngerClickMoney()

    if see_screen == true and travelData:GetAngerClickCount() <= GlobalConst.Doublerage_Time then
        money = money * 100
        FriendManager.AddUserMoney(zonetask, friendData, static_const.Static_MoneyType_Gold, money)
    else
        FriendManager.AddUserMoney(zonetask, friendData, static_const.Static_MoneyType_Gold, money)
    end

    
    travelData:SetAngerClickMoney(0)

    res["data"] = {
        cmd_uid = uid,
        resultCode = 0,
        desc = "",
        money = money,
    }

    unilight.error("222money.."..tostring(res["data"].money).." clickcount"..tostring(travelData:GetAngerClickCount()))
    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end