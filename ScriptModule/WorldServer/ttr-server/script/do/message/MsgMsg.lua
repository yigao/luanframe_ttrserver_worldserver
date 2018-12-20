function Zone.CmdMsgPullCmd_C(cmd,zonetask)
	local res = {}
	local uid = cmd.data.cmd_uid
	res["do"] = "Cmd.MsgPullCmd_S"
	res["data"] = {
		cmd_uid = uid,
		resultCode = 0
	}

	local friendData = FriendManager:GetOrNewFriendInfo(uid)

	res.data["records"] = {}

	friendData.message.records:ForEach(
		function(v)
			table.insert(res.data["records"], v:GetDBTable())
		end
	)

	ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
	return
end

function Zone.CmdMsgSkipCmd_C(cmd,zonetask)
	local res = {}
	local uid = cmd.data.cmd_uid
	res["do"] = "Cmd.MsgSkipCmd_S"
	res["data"] = {cmd_uid = uid,}

	if cmd.data == nil or cmd.data.id == nil then
		return ERROR_CODE.ARGUMENT_ERROR
	end

	res.data["id"] = cmd.data.id

	local friendData = FriendManager:GetOrNewFriendInfo(uid)
	--玩家可能不在线,设置离线数据被该标志
	friendData:SetOfflineChange()

	res.data["resultCode"] = friendData.message:Remove(cmd.data.id)

	ZoneInfo.SendCmdToMe(res["do"], res["data"], zonetask)
	return
end
