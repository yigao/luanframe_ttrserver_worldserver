


InviteFriendsMgr = InviteFriendsMgr or {}
local G_DIAMOND = 1
local G_MONEY = 2

InviteFriendsMgr.GetInviteFriendsInfo = function(uid)

    local userFriendData = FriendManager:GetOrNewFriendInfo(uid)
    if userFriendData == nil then
        return 1, "玩家信息为空", {}
    end

    for i, v in ipairs(userFriendData.meAskPlayerUidsAndFirstLogin) do
        print("uid="..uid..", meAskPlayerUidsAndFirstLogin, i="..i..", v="..v)
    end

    local inviteFriendsData = userFriendData:GetMeAskPlayerUidsAndFirstLogin()
    if #inviteFriendsData == 0 then
        return 2, "没有邀请到的好友", {}
    end

    local data = {}
    for i, v in ipairs(inviteFriendsData) do
        local friendInfo =  FriendManager:GetFriendInfo(v)
        local temp = {
            uid = friendInfo.uid,
            star = friendInfo:GetStar(),
            rewardState = friendInfo:GetRewardState(),
            rewardId = i,
            --head = friendInfo.GetHead(),
            --sex = friendInfo.GetSex(),
            --nickName = friendInfo.GetName(), --调用函数要用:
            sex = friendInfo:GetSex(),
            head = friendInfo:GetHead(),
            nickName = friendInfo:GetName()
        }

        print("uid="..uid..", meAskPlayerUidsAndFirstLogin inviteFriendsData, start="..temp.star..", rewardState="..temp.rewardState..", rewardId="..temp.rewardId)

        table.insert(data, temp)
    end

    return 0, "获取成功",data, userFriendData:GetProgressRewarded(), userFriendData:GetAskFriendFiveReward()
end


InviteFriendsMgr.GetInviteFriendReward = function(uid, friendId)

    local selfFriendInfo = FriendManager:GetFriendInfo(uid)
    if selfFriendInfo == nil then
         return 1, "玩家信息错误"
    end

    --玩家可能不在线,设置离线数据被该标志
    selfFriendInfo:SetOfflineChange()

    local index = -1
    for i, v in ipairs(selfFriendInfo.meAskPlayerUidsAndFirstLogin) do
        print("selfUid="..uid..", GetInviteFriendReward, meAskPlayerUidsAndFirstLogin, i="..i..", v="..v..", friendId="..friendId)
        if v == friendId then
            index = i
            break
        end
    end

    if index == -1 then
        return 2, "不存在该邀请的好友"
    end

    local friendInfo = FriendManager:GetFriendInfo(friendId)
    if friendInfo == nil then
        return 3, "好友信息错误"
    end
    --玩家可能不在线,设置离线数据被该标志
    friendInfo:SetOfflineChange()

    if friendInfo:GetRewardState() == 1 then
        return 4, "该好友未达到领取条件"
    end
    if friendInfo:GetRewardState() == 3 then
        return 5, "已领取该好友的奖励"
    end

    local rewardStr = Invitation[index]["reward"]
    if rewardStr == nil then
        return 6, "奖励信息错误"
    end
    InviteFriendsMgr.HandleReward(rewardStr, uid)

    friendInfo:SetRewardState(3)
    return 0, "领取成功", index

end

InviteFriendsMgr.HandleReward = function (rewardStr, uid)

    local friendData = FriendManager:GetOrNewFriendInfo(uid)

    local rewardTable = SplitStrBySemicolon(rewardStr)
    local rewardInfo = {}
    for i, v in ipairs(rewardTable) do
        local index = string.find(v, "_")
        local rewardType = string.sub(v,1, index-1)
        local rewardNum = tonumber(string.sub(v, index + 1, -1))
        if rewardInfo[rewardType] == nil then
            rewardInfo[rewardType] = 0
        end
        rewardInfo[rewardType] = rewardInfo[rewardType] + rewardNum
    end

    for i, v in pairs(rewardInfo) do
        if v > 0 then
            local rewardType = tonumber(i)
            if rewardType <=2 then
                FriendManager.AddUserMoney(nil, friendData, rewardType, v)
            else
                FriendManager.UseItem(nil, friendData, rewardType, v)
            end
        end
    end
end

InviteFriendsMgr.GetProgressReward = function(uid, progressRewardId)

    local rewardId = tonumber(progressRewardId)
    local selfFriendInfo = FriendManager:GetFriendInfo(uid)
    if selfFriendInfo == nil then
    return 1, "玩家信息错误"
    end

    if InvitationSchedule[rewardId] == nil then
    return 2, "配置信息或领取id错误"
    end

    local inviteProgressNum = 0
    for i, v in pairs(selfFriendInfo.meAskPlayerUidsAndFirstLogin) do
        local friendInfo = FriendManager:GetFriendInfo(v)
        if friendInfo:GetStar() >= GlobalConst.Invitation_Star_Awardse then
            inviteProgressNum = inviteProgressNum + 1
        end
    end
    print("GetProgressReward, uid="..uid..", inviteProgressNum="..inviteProgressNum)

    if inviteProgressNum < InvitationSchedule[rewardId]["scheduleVal"] then
    return 3, "未达到指定条件"
    end

    for i, v in pairs(selfFriendInfo.progressRewarded) do
    if v == rewardId then
    return 4, "该奖励已经领取"
    end
    end

    local rewardStr = InvitationSchedule[rewardId]["reward"]
    InviteFriendsMgr.HandleReward(rewardStr, uid)

    table.insert(selfFriendInfo.progressRewarded, rewardId)

    return 0, "领取成功"
end