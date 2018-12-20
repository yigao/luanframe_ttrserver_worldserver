require "script/do/common/staticconst"

-- 邀请游戏，发送邀请你玩着游戏的玩家UID
Zone.CmdBeAskedPlayGame_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.BeAskedPlayGame_S"

    local uid = cmd.data.cmd_uid
    local friendData = FriendManager:GetOrNewFriendInfo(uid);
    friendData:SetOfflineChange()
    
    --检查客户端数据输入
    if cmd["data"] == nil or cmd["data"].uid == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    local ask_uid = cmd["data"].uid
    if ask_uid == uid then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "不能邀请自己"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    local askFriendData = FriendManager:GetFriendInfo(ask_uid);

    if askFriendData == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "错误，对方不存在"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    --玩家可能不在线,设置离线数据被该标志
    askFriendData:SetOfflineChange()

    --unilight.debug("玩家(" .. askFriendData:GetName() .. ") 成功邀请了 玩家(" .. friendData:GetName() .. ") 玩游戏")

    friendData:SetAskMePlayGameUid(ask_uid)
    askFriendData:AddMeAskPlayerUids(uid)

    if friendData:GetUserFriend(uid) == nil then
        friendData:AddUserFriend(askFriendData:GetUid(), askFriendData:GetHead(), askFriendData:GetName(), askFriendData:GetAppId(), true)
        askFriendData:AddUserFriend(friendData:GetUid(), friendData:GetHead(), friendData:GetName(), friendData:GetAppId(), true)
    end

    if friendData.isFirstLogin == true then
        askFriendData:AddMeAskPlayerUidsAndFirstLogin(uid)
    end

    ---可能的发放奖励代码，以后加上


    --任务系统，任务完成情况
    FriendManager.NotifyDailyTaskAddProgress(zonetask, askFriendData, TaskConditionEnum.AskFriendEvent, 1)
    FriendManager.NotifyAchieveTaskAddProgress(zonetask, askFriendData, TaskConditionEnum.AskFriendEvent, 1)
    FriendManager.NotifyMainTaskAddProgress(zonetask, askFriendData, TaskConditionEnum.AskFriendEvent, 1)

    res["data"] = {
        cmd_uid = uid,
        resultCode = 0,
        desc = ""
    }
    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end

-- 客户端建号时发送QQ好友消息
Zone.CmdSendUserQQFriendDataCmd_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.SendUserQQFriendDataCmd_S"

    local uid = cmd.data.cmd_uid
    local friendData = FriendManager:GetOrNewFriendInfo(uid);
    friendData:SetOfflineChange()
    local data = cmd["data"]

    --检查客户端数据输入
    if data == nil or data.self_data == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    if type(data.self_data.head) ~= "string" or type(data.self_data.name) ~= "string"
    or type(data.self_data.app_id) ~= "string" or type(data.self_data.sex) ~= "number" then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    --先将自己的QQ数据保存下来
    friendData:SetBaseInfo(uid, data.self_data.head, data.self_data.name, data.self_data.app_id, data.self_data.sex)
	

    if type(data.self_data.app_id) == "string" and data.self_data.app_id ~= "" then
        FriendManager:SaveUserQQInfo(data.self_data.app_id, uid)
    end

    --FriendManager:PrintUserQQInfo()

    --获取QQ好友信息，并且查看QQ好友是否有在玩本游戏，有的话，添加为好友
    for i, v in ipairs(data.friend_data) do
        --检查客户端数据输入
        if type(v.head) ~= "string" or type(v.name) ~= "string" or type(v.app_id) ~= "string" then
            res["data"] = {
                cmd_uid = uid,
                resultCode = 1,
                desc = "数据出错"
            }
            ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
            return
        end

        --判断是否双方是QQ好友，如果是就相互添加为好友
        local qqData_uid = FriendManager:GetUserQQInfo(v.app_id)

        if qqData_uid ~= nil and friendData:GetUserFriend(qqData_uid) == nil then
            local qq_friend_data = FriendManager:GetFriendInfo(qqData_uid)
            if qq_friend_data ~= nil and friendData:IsExistDeleteQQFriend(qqData_uid) == false then
                friendData:AddUserFriend(qq_friend_data:GetUid(), qq_friend_data:GetHead(), qq_friend_data:GetName(), qq_friend_data:GetAppId(), true)
                qq_friend_data:AddUserFriend(friendData:GetUid(), friendData:GetHead(), friendData:GetName(), friendData:GetAppId(), true)
                --玩家可能不在线,设置离线数据被该标志
                qq_friend_data:SetOfflineChange()
            end
        end
    end

    res["data"] = {
        cmd_uid = uid,
        resultCode = 0,
    }
    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end

-- 获取玩家游戏好友信息
Zone.CmdGetUserFriendDataCmd_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.GetUserFriendDataCmd_S"

    local uid = cmd.data.cmd_uid
    local friendData = FriendManager:GetOrNewFriendInfo(uid);
    local travelData = friendData:GetUserTravel()
    local friendvisitData = friendData:GetFriendVisit()

    res["data"] = {
        cmd_uid = uid,
        self_data = {
            uid = uid,
            name = friendData:GetName(),
            head = friendData:GetHead(),
            sex = friendData:GetSex(),
            star = friendData:GetStar(),
            signature =  friendData:GetSignature(), 
            area =  friendData:GetArea(), 
            horoscope =  friendData:GetHoroscope(),
            friend_ship = 0,
            money = friendData:GetMoney(),
            product = friendData:GetProduct(),
            click = friendData:GetClick(),
        },

        friend_data = {},
        today_mischief_number = friendvisitData:GetMischiefNumber(),
        today_inspire_number = friendvisitData:GetInspireNumber(),
    }

    --获取QQ好友数据
    friendData:UserFriendsForEach(
        function(k,v)
            local f_friendData = FriendManager:GetFriendInfo(k)
            if f_friendData ~= nil then
                local data = {
                    uid = k,
                    name = f_friendData:GetName(), 
                    head =  f_friendData:GetHead(), 
                    star =  f_friendData:GetStar(), 
                    sex =  f_friendData:GetSex(), 
                    signature =  f_friendData:GetSignature(), 
                    area =  f_friendData:GetArea(), 
                    horoscope =  f_friendData:GetHoroscope(),
                    friend_ship = travelData:GetRelationShip(k),
                    money = f_friendData:GetMoney(),
                    product = f_friendData:GetProduct(),
                    click = f_friendData:GetClick()
                }
                table.insert(res["data"].friend_data, data)               
            end       
        end
    )

    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end

--获得玩家被邀请为好友的列表
Zone.CmdGetUserAskedAddFriends_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.GetUserAskedAddFriends_S"

    local uid = cmd.data.cmd_uid
    local friendData = FriendManager:GetOrNewFriendInfo(uid);
    local travelData = friendData:GetUserTravel()

    res["data"] = { cmd_uid = uid,}
    res["data"].friend_data = { }

    --玩家不在线时， 被邀请为好友处理
    friendData:AskAddFriendsForEach(
        function(k,v)
            local ask_uid = k
            local ask_friend_data = FriendManager:GetFriendInfo(ask_uid)
            if ask_friend_data ~= nil then
                local req = { 
                    uid = ask_uid,
                    name = ask_friend_data:GetName(), 
                    head =  ask_friend_data:GetHead(), 
                    star =  ask_friend_data:GetStar(), 
                    sex =  ask_friend_data:GetSex(), 
                    signature =  ask_friend_data:GetSignature(), 
                    area =  ask_friend_data:GetArea(), 
                    horoscope =  ask_friend_data:GetHoroscope(),
                    friend_ship = travelData:GetRelationShip(ask_uid),
                }
                table.insert( res["data"].friend_data, req)
            end
        end
    )
    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end

-- 发送好友请求
Zone.CmdSendReqAddFriendCmd_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.SendReqAddFriendCmd_S"

    local uid = cmd.data.cmd_uid
    local friendData = FriendManager:GetOrNewFriendInfo(uid);
    local travelData = friendData:GetUserTravel()
    friendData:SetOfflineChange()

    --检查客户端输入
    if cmd["data"] == nil or type(cmd["data"].friend_uid) ~= "number" then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end


    --好友上线，如果已经达到上线的话
    if friendData:GetFriendsCount() >= static_const.Static_Const_Friend_MAX_Friend_Count then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.FRIENDS_MAX_LIMIT,
            desc = "好友数量已达上限"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    --如果已经是好友的话
    local ask_uid = cmd["data"].friend_uid;

    if ask_uid == uid then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    if friendData:GetUserFriend(ask_uid) ~= nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.FRIENDS_IS_YOUR_FRIEND,
            desc = "对方已是你的好友"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    if ask_uid == uid  then
        res["data"] = {
            cmd_uid = uid,
            resultCode = ERROR_CODE.FRIENDS_CAN_ADD_SELF,
            desc = "不能加自己为好友"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    --检查自己今天的邀请信息
    if friendData:IsExistTodayAskedFriends(ask_uid) == true then
        res["data"] = {
            cmd_uid = uid,
           resultCode = ERROR_CODE.FRIENDS_APPLY_TOO_MUCH,
           desc = "已经申请"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    --如果对方不在线， 查询保留的申请信息，如果有你，说明你多次申请了
    local askFriendData = FriendManager:GetFriendInfo(ask_uid);

    if askFriendData == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "错误，对方不存在"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    --玩家可能不在线,设置离线数据被该标志
    askFriendData:SetOfflineChange()

    --记录今天邀请过的好友
    friendData:AddTodayAskedFriends(ask_uid)
    askFriendData:AddAskAddFriends(uid)

	--给被邀请的人，一条消息记录
    askFriendData:Give(zonetask, friendData, MsgTypeEnum.FriendApply)

    --任务系统，任务完成情况
    FriendManager.NotifyDailyTaskAddProgress(zonetask, friendData, TaskConditionEnum.ApplyFriendEvent, 1)
    FriendManager.NotifyAchieveTaskAddProgress(zonetask, friendData, TaskConditionEnum.ApplyFriendEvent, 1)
    FriendManager.NotifyMainTaskAddProgress(zonetask, friendData, TaskConditionEnum.ApplyFriendEvent, 1)

    res["data"] = {
        cmd_uid = uid,
        resultCode = 0,
        desc = ""
    }

    --需要知道对方是否在线,如果不在线的话，先把请求存起来
    if askFriendData:GetOnline() == false then
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    else
        --在线的话发送好友请求给对方
        local req = { }
        req["do"] = "Cmd.SendReqBeAddFriendCmd_S"
        req["data"] = {
            cmd_uid = ask_uid,
            uid = uid,
            name = friendData:GetName(), 
            head =  friendData:GetHead(), 
            star =  friendData:GetStar(), 
            sex =  friendData:GetSex(), 
            signature =  friendData:GetSignature(), 
            area =  friendData:GetArea(), 
            horoscope =  friendData:GetHoroscope(),
            friend_ship = travelData:GetRelationShip(ask_uid),
        }

        ZoneInfo.SendCmdToMeById(req["do"], req["data"], askFriendData.gameid, askFriendData.zoneid)
        
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
    end
end

-- 同意或拒绝好友请求
Zone.CmdSendReqAgreeAddFriendCmd_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.SendReqAgreeAddFriendCmd_S"

    local uid = cmd.data.cmd_uid

    --客户端数据参数检查
    if cmd["data"] == nil or type(cmd["data"].agree) ~= "boolean" or type(cmd["data"].uid) ~= "number" then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end
    local agree = cmd["data"].agree
    local ask_uid = cmd["data"].uid

    local friendData = FriendManager:GetOrNewFriendInfo(uid);
    --玩家可能不在线,设置离线数据被该标志
    friendData:SetOfflineChange()

    if uid == ask_uid then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "不能添加自己为好友"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    friendData:DelAskAddFriends(ask_uid)
    local ask_friendData = FriendManager:GetFriendInfo(ask_uid);
    if ask_friendData == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "对方不存在"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end

    --玩家可能不在线,设置离线数据被该标志
    ask_friendData:SetOfflineChange()

    --删除今天申请记录
    ask_friendData:DelTodayAskedFriends(uid)

    --如果同意的话，就相互加为好友
    if agree == true then
        --删除QQ好像删除信息
        local isQQFriend = false
        if friendData:IsExistDeleteQQFriend(ask_uid) == true then
            isQQFriend = true
        end
        friendData:DelDeleteQQFriend(ask_uid)
        ask_friendData:DelDeleteQQFriend(uid)

        if friendData:GetFriendsCount() >= static_const.Static_Const_Friend_MAX_Friend_Count then
            res["data"] = {
                cmd_uid = uid,
                resultCode = ERROR_CODE.FRIENDS_MAX_LIMIT,
                desc = "好友数目已经达到上限，不能添加"
            }
            ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
            return
        end

        if ask_friendData:GetFriendsCount() >= static_const.Static_Const_Friend_MAX_Friend_Count then
            res["data"] = {
                cmd_uid = uid,
                resultCode = ERROR_CODE.FRIENDS_MAX_LIMIT,
                desc = "对方好友数目已经达到上限，不能添加"
            }
            ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
            return
        end

        unilight.debug("name:" .. friendData:GetName() .. "同意加name:" .. ask_friendData:GetName() .. " 为好友")
        friendData:AddUserFriend(ask_friendData:GetUid(), ask_friendData:GetHead(), ask_friendData:GetName(), ask_friendData:GetAppId(), isQQFriend)
        ask_friendData:AddUserFriend(friendData:GetUid(), friendData:GetHead(), friendData:GetName(), friendData:GetAppId(), isQQFriend)
        --ask_uid添加uid为朋友，这个是接口是uid接受或拒绝ask_uid的请求
        FriendManager.NotifyMainTaskAddProgress(zonetask, ask_friendData, TaskConditionEnum.AddFriendEvent, 1)

        if ask_friendData:GetOnline() == true then
            res["data"] = {
                cmd_uid = uid,
                resultCode = 0,
                desc = "添加好友成功"
            }

            local req = {}
            req["do"] = "Cmd.SendReqAgreeAddFriendCmd_S"
            req["data"] = {
                cmd_uid = ask_uid,
                resultCode = 0,
                desc = "添加好友成功"
            }

            ZoneInfo.SendCmdToMeById(req["do"], req["data"], ask_friendData.gameid, ask_friendData.zoneid)
        end
    end

    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end

-- 删除好友
Zone.CmdSendReqDeleteFriendCmd_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.SendReqDeleteFriendCmd_S"
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

    local del_uid = cmd["data"].uid

    local friendData = FriendManager:GetOrNewFriendInfo(uid)
    local delFriendData = FriendManager:GetFriendInfo(del_uid)

    --玩家可能不在线,设置离线数据被该标志
    friendData:SetOfflineChange()

    if delFriendData == nil then
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "数据出错"
        }
        ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
        return
    end
    
    --玩家可能不在线,设置离线数据被该标志
    delFriendData:SetOfflineChange()

    --如果是QQ好友的话，记录一下，免得下次登入又被加上
    if friendData:GetUserFriend(del_uid) ~= nil then
        local tmp = friendData:GetUserFriend(del_uid)
        if tmp:GetIsQQFriend() == true then
            unilight.debug("是QQ好友，删除QQ好友，记录一下")
            friendData:AddDeleteQQFriend(del_uid)
        end
        friendData:DelUserFriend(del_uid)
    end

    --如果是QQ好友的话，记录一下，免得下次登入又被加上
    if delFriendData:GetUserFriend(uid) ~= nil then
        local tmp = delFriendData:GetUserFriend(uid)
        if tmp:GetIsQQFriend() == true then
            unilight.debug("是QQ好友，删除QQ好友，记录一下")
            delFriendData:AddDeleteQQFriend(uid)
        end
        delFriendData:DelUserFriend(uid)
    end

    --删除今天邀请和推荐
    friendData:DelTodayAskedFriends(del_uid)
    delFriendData:DelTodayAskedFriends(uid)
    friendData:DelRecommendFriends(del_uid)
    delFriendData:DelRecommendFriends(uid)

    res["data"] = {
        cmd_uid = uid,
        resultCode = 0,
        desc = "删除好友成功"
    }
    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end

--推荐好友
Zone.CmdSendReqRecommendFriendCmd_C = function(cmd,zonetask)
    local uid = cmd.data.cmd_uid

    local res = { }
    res["do"] = "Cmd.SendReqRecommendFriendCmd_S"
    res["data"] = {cmd_uid = uid,}
    res["data"].friends = {}

    local friendData = FriendManager:GetOrNewFriendInfo(uid)
    local travelData = friendData:GetUserTravel()

    --玩家可能不在线,设置离线数据被该标志
    friendData:SetOfflineChange()

    --收集被推荐的好友
    local tmp = {}

    for k, v in pairs(friendData.deleteQQFriend.map) do
         --推荐好友，满足条件 1不是自己 2不是好友 3今天没有被推荐过 4今天没有被邀请过
         if k ~= uid and friendData:GetUserFriend(k) == nil and 
            friendData:IsRecommendedToFriend(k) == false and 
            friendData:IsExistTodayAskedFriends(uid) == false then
            local friendInfo = FriendManager:GetFriendInfo(k)
            if friendInfo ~= nil then
                local info = {
                    uid = k,
                    name = friendInfo:GetName(), 
                    head =  friendInfo:GetHead(), 
                    star =  friendInfo:GetStar(), 
                    sex =  friendInfo:GetSex(), 
                    signature =  friendInfo:GetSignature(), 
                    area =  friendInfo:GetArea(), 
                    horoscope =  friendInfo:GetHoroscope(),
                    friend_ship = travelData:GetRelationShip(k),
                }
                table.insert(res["data"].friends, info)

                --如果人数多于20直接发送，如果没有从以前推荐过的列表中插入
                if #res["data"].friends >= 20 then
                    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
                end
            end
         end
    end

    for i = 0, 100, 1 do
        local friendInfo = FriendManager:GetRandomFriendInfo()
        --推荐好友，满足条件 1不是自己 2不是好友 3今天没有被推荐过 4今天没有被邀请过
        if friendInfo ~= nil and friendInfo:GetUid() ~= uid and 
        friendData:GetUserFriend(friendInfo:GetUid()) == nil and 
        friendData:IsRecommendedToFriend(friendInfo:GetUid()) == false and 
        friendData:IsExistTodayAskedFriends(uid) == false and
        friendInfo:GetName() ~= "" and friendInfo:GetHead() ~= "" then
            local info = {
                uid = friendInfo:GetUid(),
                name = friendInfo:GetName(), 
                head =  friendInfo:GetHead(), 
                star =  friendInfo:GetStar(), 
                sex =  friendInfo:GetSex(), 
                signature =  friendInfo:GetSignature(), 
                area =  friendInfo:GetArea(), 
                horoscope =  friendInfo:GetHoroscope(),
                friend_ship = travelData:GetRelationShip(friendInfo:GetUid()),
            }
            table.insert(res["data"].friends, info)
            tmp[friendInfo:GetUid()] = true
        end

        --如果人数多于20直接发送，如果没有从以前推荐过的列表中插入
        if #res["data"].friends >= 20 then
            for tmpk,tmpv in pairs(tmp) do
                --记录已经被推荐
                --friendData:AddRecommendFriends(tmpk)
                
            end
            ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
            return
        end

    end
    

    --如果人数多于20直接发送，如果没有从以前推荐过的列表中插入
    for k,v in pairs(friendData.recommendFriends.map) do
        if k ~= uid and friendData:GetUserFriend(k) == nil and 
        friendData:IsExistTodayAskedFriends(k) == false then
            local friendInfo = FriendManager:GetFriendInfo(k)
            if friendInfo ~= nil and friendInfo:GetName() ~= "" and friendInfo:GetHead() ~= "" then
                local info = {
                    uid = k,
                    name = friendInfo:GetName(), 
                    head =  friendInfo:GetHead(), 
                    star =  friendInfo:GetStar(), 
                    sex =  friendInfo:GetSex(), 
                    signature =  friendInfo:GetSignature(), 
                    area =  friendInfo:GetArea(), 
                    horoscope =  friendInfo:GetHoroscope(),
                    friend_ship = travelData:GetRelationShip(k),
                }
                table.insert(res["data"].friends, info)
                --如果人数多于20直接发送
                if #res["data"] >= 20 then
                    for tmpk,tmpv in pairs(tmp) do
                        --记录已经被推荐
                        --friendData:AddRecommendFriends(tmpk)
                    end
                    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
                    return
                end
            end
        end
    end

    for tmpk,tmpv in pairs(tmp) do
        --记录已经被推荐
        --friendData:AddRecommendFriends(tmpk)
    end

    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end

--通过UID获得对方信息
Zone.CmdGetUserInfoByUid_C = function(cmd,zonetask)
    local res = { }
    res["do"] = "Cmd.GetUserInfoByUid_S"

    local uid = cmd.data.cmd_uid
    local find_uid = cmd.data.uid
    local friendData = FriendManager:GetFriendInfo(find_uid)

    if friendData ~= nil then
        local travelData = friendData:GetUserTravel()
        res["data"] = {
            cmd_uid = uid,
            resultCode = 0,
            desc = "",
            uid = find_uid,
            name = friendData:GetName(), 
            head =  friendData:GetHead(), 
            star =  friendData:GetStar(), 
            sex =  friendData:GetSex(), 
            signature =  friendData:GetSignature(), 
            area =  friendData:GetArea(), 
            horoscope =  friendData:GetHoroscope(),
            friend_ship = travelData:GetRelationShip(uid),
        }
    else
        res["data"] = {
            cmd_uid = uid,
            resultCode = 1,
            desc = "玩家不存在",
        }
    end
    ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end
