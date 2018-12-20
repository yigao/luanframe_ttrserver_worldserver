require "script/do/common/Common"

CreateClass("FriendData")   --单个好友简单数据


--玩家的单个好友数据初始化
function FriendData:Init(uid, head, name, app_id, isQQFriend)
    self.uid = uid or 0
    self.head = head or ""
    self.name = name or ""
    self.app_id = app_id or ""
    self.isQQFriend = isQQFriend or false
end

function FriendData:GetDBTable()
    local tmp = {}
    tmp.uid = self.uid
    tmp.head = self.head
    tmp.name = self.name
    tmp.app_id = self.app_id
    tmp.isQQFriend = self.isQQFriend
    return tmp
end

function FriendData:SetDBTable(data)
    self.uid = data.uid or 0
    self.head = data.head or ""
    self.name = data.name or ""
    self.app_id = data.app_id or ""
    self.isQQFriend = data.isQQFriend or false
end

function FriendData:GetUid()
    return self.uid
end

function FriendData:GetHead()
    return self.head
end

function FriendData:GetName()
    return self.name
end

function FriendData:GetAppId()
    return self.app_id
end

function FriendData:GetIsQQFriend()
    return self.isQQFriend
end

function FriendData:PrintData()
    unilight.debug("uid------------" .. self.uid)
    unilight.debug("head-----------" .. self.head)
    unilight.debug("name-----------" .. self.name)
    unilight.debug("appid----------" .. self.app_id)
end

