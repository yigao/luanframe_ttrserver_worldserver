Zone.CmdUserInfoLoginCenter_C = function(cmd,zonetask)

	local uid = cmd.data.cmd_uid

	--玩家好友数据创建或登录
	local friendData = FriendManager:UserLoginFriend(uid, zonetask)
	local travelData = friendData:GetUserTravel()
	local friendVisitData = friendData:GetFriendVisit()

	--登录时主动清理零点数据
	friendData:AutoZeroClear()

	--同步玩家数据到好友数据
	friendData:SetStar(cmd.data.userInfo.star)
	friendData:SetMoney(cmd.data.userInfo.money)
	friendData:SetProduct(cmd.data.userInfo.product)
	travelData:CalcAddontion()

	friendData.isFirstLogin = cmd.data.userInfo.isFirstLogin

	local data = {
		cmd_uid = uid,
		friendAddontion = friendData:GetAddontion(),
		isFirstLogin = cmd.data.userInfo.isFirstLogin,
		shield_count = travelData:GetShieldCount(),
	}
	ZoneInfo.SendCmdToMe("Cmd.UserInfoLoginCenter_S", data, zonetask)
end