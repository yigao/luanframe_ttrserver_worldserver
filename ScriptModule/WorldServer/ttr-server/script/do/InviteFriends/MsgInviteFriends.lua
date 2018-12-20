

-- 获取玩家邀请到的好友信息
Zone.CmdGetInviteFriendInfoCmd_C = function(cmd,zonetask)
	local res = {}
	res["do"] = "Cmd.GetInviteFriendInfoCmd_S"
	local uid = cmd.data.cmd_uid
	local code, desc, inviteFriendsInfo, progressRewarded, askFriendFiveReward = InviteFriendsMgr.GetInviteFriendsInfo(uid)

	res["data"] = {
		cmd_uid = uid,
		resultCode 	= code,
		desc 		= desc,
		data 	    = inviteFriendsInfo,
		progressRewarded = progressRewarded,
		askFriendFiveReward = askFriendFiveReward,	--0没有领取，1已经领取
	}
	ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
	return
end

-- 获取5人领取奖励
Zone.CmdGetAskFriendFiveReward_C = function(cmd,zonetask)
	local res = {}
	res["do"] = "Cmd.GetAskFriendFiveReward_S"
	local uid = cmd.data.cmd_uid
	local friendData = FriendManager:GetOrNewFriendInfo(uid)

	--玩家可能不在线,设置离线数据被该标志
	friendData:SetOfflineChange()

	local tmp = friendData:GetMeAskPlayerUidsAndFirstLogin()
	if #tmp >= GlobalConst.Invitation_Role_Times and friendData:GetAskFriendFiveReward() == 0 then
		local travelData = friendData:GetUserTravel()
		local data = travelHead[GlobalConst.Invitation_Role_Character]
		if data ~= nil then
			travelData:AddTravelHeadBackup(data.head)

			local req = {}
			req["do"] = "Cmd.NotifyAddUserTravelHead_S"
			req["data"] = {
				cmd_uid = uid,
				head = data.head,
			}
			ZoneInfo.SendCmdToMe(req["do"], req["data"], zonetask)
		end

		friendData:SetAskFriendFiveReward()
	else
		res["data"] = {
			cmd_uid = uid,
			resultCode = 1,
			desc = "",
		}
		ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
		return
	end

	res["data"] = {
		cmd_uid = uid,
		resultCode = 0,
		desc = "",
	}
	ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
	return
end

 --领取 邀请好友 获得的奖励
 Zone.CmdGetInviteFriendRewardCmd_C = function(cmd,zonetask)
	local res = {}
	res["do"] = "Cmd.GetInviteFriendRewardCmd_S"
	local uid = cmd.data.cmd_uid
	local friendUid = cmd.data.friendUid
	print("CmdGetInviteFriendRewardCmd_C, uid="..uid..", friendUid="..friendUid)
	local  ret, desc, rewardId = InviteFriendsMgr.GetInviteFriendReward(uid, friendUid)

	res["data"] = {
		cmd_uid = uid,
		resultCode 	= ret,
		desc 		= desc,
		rewardId 	= rewardId,
	}
	ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
	return
end


--领取 邀请好友进度 获得的奖励
Zone.CmdGetProgressRewardCmd_C = function(cmd,zonetask)
	local res = {}
	res["do"] = "Cmd.GetProgressRewardCmd_S"
	local uid = cmd.data.cmd_uid
	local progressRewardId = cmd.data.progressRewardId
	local  ret, desc = InviteFriendsMgr.GetProgressReward(uid, progressRewardId)

	res["data"] = {
		cmd_uid = uid,
		resultCode 	= ret,
		desc 		= desc,
		progressRewardId 	= progressRewardId,
	}
	ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
end