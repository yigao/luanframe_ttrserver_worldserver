message = {}

	--[[
	功能：产生一条消息，记录在对应的玩家下
	参数：
		uid		:number,			对应玩家的UID
		who		:UserInfo,			自身玩家的信息
		msgType	:MsgTypeEnum,		消息类型
		args	:字符串数组,		消息参数
	实例：
		give(laccount.Id, userInfo, MsgTypeEnum.FriendApply)
	--]]
function message.give(friendinfo, msgType, args)
	local l_who = {
		uid = friendinfo:GetUid(),
		male = friendinfo:GetSex(),
		nickName = friendinfo:GetName(),
		star = friendinfo:GetStar(),
	}

	friendinfo.message:addNew()
end
