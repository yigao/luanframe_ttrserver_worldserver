

MsgTypeEnum = 
{
	FriendApply = 1,							--好友请求
	FriendRobbed = 2,							--好友被抢
	TripGroupFriendFinishEmploy = 3,			--你的旅行团的好友完成雇佣
	FriendRobbedWithFailure = 4,				--好友被抢，但失败了
	TripGroupMeFinishEmploy = 5,				--好友的旅行团的你完成雇佣
	FriendVisitInspireFriend = 6,				--好友捣蛋
	FriendVisitMischiefFriend = 7,				--好友鼓舞
}


MSG_MAX = 50
MSG_KEEP_TIME = 86400 -- 24 * 3600

CreateClass("MsgMgr")

--一条消息记录类
CreateClass("MsgRecord")

function MsgRecord:Init()
	--唯一id
	self.id = 0
	self.time = 0
	self.msgType = 0
	--参数
	self.arguments = {}
	--玩家消息
	self.who = {}
end

function MsgRecord:Create(id, who, msgType, args)
	self.id = id
	self.time = os.time()
	self.msgType = msgType
	self.arguments = args
	self.who = who
end

function MsgRecord:GetDBTable()
	local data = {}
	data.id = self.id
	data.time = self.time
	data.msgType = self.msgType
	data.arguments = self.arguments
	data.who = self.who
	return data
end

function MsgRecord:SetDBTable(data)
	self.id = data.id or self.id
	self.time = data.time or self.time
	self.msgType = data.msgType or self.msgType
	self.arguments = data.arguments or self.arguments
	self.who = data.who or self.who
end

function MsgMgr:Init()
	-- 消息记录
	self.id = 1000
	self.records = List:New()
	self.records:Init()
end

function MsgMgr:GetDBTable()
	local data = {}
	data.id = self.id

	data.records = {}
    self.records:ForEach(
        function(v)
            table.insert(data.records,v:GetDBTable())
        end
	)
	return data
end

function MsgMgr:SetDBTable(data)
	if data == nil then return end

	self.id = data.id or self.id
	if data.records ~= nil then
		for k,v in pairs(data.records) do
			local record = MsgRecord:New()
			record:Init()
			record:SetDBTable(v)
			self.records:Push(record)
		end
	end
end

--contents: string array
function MsgMgr:add(who, msgType, args)
	self.id = self.id + 1
	local msg = MsgRecord:New()
	msg:Init()
	msg:Create(self.id, who, msgType, args)

	self.records:Push(msg)

	while (self.records:Count() >= MSG_MAX) do
		unilight.debug("Msgs is more than " .. MSG_MAX .. ", remove the first")
		self.records:RemoveByIndex(1)
	end

	return msg
end

function MsgMgr:CleanTimeout()
	local indexes = {}
	local time = os.time()

	self.records:RemoveIf(
		function(record)
			if time - record.time > MSG_KEEP_TIME then
				return true
			end
			return false
		end
	)

	while (self.records:Count() >= MSG_MAX) do
		self.records:RemoveByIndex(1)
	end
end

function MsgMgr:Remove(id)

	self.records:RemoveIf(
		function(record)
			if record.id == id then
				return true
			end
			return false
		end
	)

	unilight.debug("Succeed to remove a msg")
	return 0
end

function MsgMgr:give(friendinfo, msgType, args)
	local l_who = {
		uid = friendinfo:GetUid(),
		male = friendinfo:GetSex(),
		nickName = friendinfo:GetName(),
		star = friendinfo:GetStar(),
	}

	return self:add(l_who, msgType, args)
end
