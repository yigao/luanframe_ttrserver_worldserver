require "script/do/common/staticconst"

CreateClass("UserTravel")   --单个玩家所有好友数据结构体

TravelShieldStatusEnum = {
    TravelShieldStatus_Close = 0,
    TravelShieldStatus_Open = 1,
}

function UserTravel:Init(uid)
    self.uid = uid
    --初始化旅行团等级
    self.level = 0

    --旅行团界面专用头像数据, 数字，来自配置表
    self.travelHead = 1 -- 1是配置表数据

    --旅行团备用头像，数字，来自配置表
    self.travelHeadBackUp = Map:New()
    self.travelHeadBackUp:Init()
    self.travelHeadBackUp:Insert(1,true)
    self.travelHeadBackUp:Insert(2,true)

    -- 旅行团功能 当前雇佣他的旅行团UID 如果为0表示空闲
    self.employUid = 0
    -- 当前雇佣他的旅行团名字
    self.employName = ""

    -- 雇佣CD时间时间到期前，需要知道上一次雇佣他的人是谁
    self.lastEmployUid = 0

    -- 旅行团功能 雇佣CD时间 cd时间到了，上一次雇佣他的对象可以重新雇佣他
    self.employCd = 0
    
    --旅行团成员映射，uid--加入旅行团时间
    self.members = Map:New()
    self.members:Init()

    --雇佣到期时间定时器, uid--定时器
    self.members_timer = {}

    --旅行团亲密度, 玩家UID--亲密值
    self.relationships = Map:New()
    self.relationships:Init()

    --今天剩余抓捕次数
    self.captureTimes = static_const.Static_Const_TRAVEL_INIT_MAX_CAPTURE_TIMES

    --今天已经购买的抓捕次数，用于判断所学抓捕费用
    self.todayBuyCaptureTimes = 0

    --已经解锁的位置数目, 默认已经有3个
    self.unlockSlotCount = static_const.Static_Const_TRAVEL_Init_UNLOCK_SLOT_COUNT

    --防护罩数目
    self.shieldCount = static_const.Static_Const_TRAVEL_Init_Shield_Count

    --旅行团产量加成
    self.additon = 1.0

    --玩家怒气
    self.anger = 0

    --点击怒气满了次数
    self.anger_click_count = 0

    --怒气满了点击获得的金币数
    self.anger_click_money = 0
end

function UserTravel:SetDBTable(data)
    if data == nil then return end

    self.uid = data.uid or self.uid
    self.level = data.level or self.level
    self.travelHead = data.travelHead or self.travelHead

    if data.travelHeadBackUp ~= nil then
        for k,v in pairs(data.travelHeadBackUp) do
            self.travelHeadBackUp:Insert(k,v)
        end
    end

    self.employUid = data.employUid or self.employUid
    self.employName = data.employName or self.employName
    self.employCd = data.employCd or self.employCd
    self.lastEmployUid = data.lastEmployUid or self.lastEmployUid
    self.shieldCount = data.shieldCount or self.shieldCount
    self.todayBuyCaptureTimes = data.todayBuyCaptureTimes or self.todayBuyCaptureTimes
    self.anger = data.anger or self.anger
    self.anger_click_count = data.anger_click_count or self.anger_click_count
    
    if data.members ~= nil then
        for k,v in pairs(data.members) do
            self.members:Insert(k,v)
        end
    end

    if data.relationships ~= nil then
        for k,v in pairs(data.relationships) do
            self.relationships:Insert(k,v)
        end
    end

    self.captureTimes = data.captureTimes or self.captureTimes
    self.unlockSlotCount = data.unlockSlotCount or self.unlockSlotCount
    self.additon = data.additon or self.additon
end

function UserTravel:GetDBTable()
    local data = {}
    data.uid = self.uid
    data.level = self.level
    data.travelHead = self.travelHead
    data.travelHeadBackUp = { }
    self.travelHeadBackUp:ForEach(
        function(k,v)
            data.travelHeadBackUp[k] = v
        end
    )


    data.employUid = self.employUid
    data.employName = self.employName
    data.lastEmployUid = self.lastEmployUid
    data.employCd = self.employCd
    data.shieldCount = self.shieldCount
    data.additon = self.additon
    data.anger = self.anger
    data.anger_click_count = self.anger_click_count

    data.members = {}
    self.members:ForEach(
        function(k,v)
            data.members[k] = v
        end
    )

    data.relationships = {}
    self.relationships:ForEach(
        function(k,v)
            data.relationships[k] = v
        end
    )

    data.captureTimes = self.captureTimes

    data.todayBuyCaptureTimes = self.todayBuyCaptureTimes

    data.unlockSlotCount = self.unlockSlotCount

    return data
end

function UserTravel:GetAngerClickMoney()
    return self.anger_click_money
end

function UserTravel:SetAngerClickMoney(m)
    self.anger_click_money = m
end

--怒气点击次数
function UserTravel:GetAngerClickCount()
    return self.anger_click_count
end

--增加怒气点击次数
function UserTravel:AddAngerClickCount()
    self.anger_click_count = self.anger_click_count + 1
end

--获得怒气
function UserTravel:GetAnger()
    return self.anger
end

--清理怒气
function UserTravel:ClearAnger()
    self.anger = 0
end

--增加怒气
function UserTravel:AddAnger(value)
    local config = traveLevel[self.level]
    if config ~= nil then
        self.anger = self.anger + value
        if self.anger >= config["anger"] then
            self.anger = config["anger"]
        end
    end
end

--怒气值是否满了
function UserTravel:IsAngerFull()
    local config = traveLevel[self.level]
    if config ~= nil then
        if self.anger >= config["anger"] then
            return true
        end
    end
    return false
end

function UserTravel:GetTodayBuyCaptureTimes()
    return self.todayBuyCaptureTimes
end

function UserTravel:AddTodayBuyCaptureTimes()
    self.todayBuyCaptureTimes = self.todayBuyCaptureTimes + 1
end

function UserTravel:GetTodayBuyCaptureTimes_NeedCost() 
    if GlobalConst.Travel_Catch_COST[self.todayBuyCaptureTimes+1] ~= nil then
        return  GlobalConst.Travel_Catch_COST[self.todayBuyCaptureTimes+1]
    else
        return GlobalConst.Travel_Catch_COST[#GlobalConst.Travel_Catch_COST]
    end
end

function UserTravel:GetShieldCount()
    return self.shieldCount
end

function UserTravel:SubShieldCount()
    if self.shieldCount > 0 then
        self.shieldCount = self.shieldCount - 1
    end
end

function UserTravel:AddShieldCount(times)
    if times > 0 then
        self.shieldCount = self.shieldCount + times
    end
end

function UserTravel:GetTravelHead()
    return self.travelHead
end

function UserTravel:SetTravelHead(head)
    self.travelHead = head
end

function UserTravel:AddTravelHeadBackup(head)
    self.travelHeadBackUp:Insert(head, true)
end

function UserTravel:GetTravelHeadBackup()
    return self.travelHeadBackUp
end

function UserTravel:IsExistTravelHeadBackup(head)
    if self.travelHeadBackUp:Find(head) ~= nil then
        return true
    else
        return false
    end
end

function UserTravel:GetTravelHeadBackupCount()
    return self.travelHeadBackUp:Count()
end

--获得雇佣到期剩余时间
function UserTravel:GetEmployEndLeftTime(uid)
    local tt = self:GetMemberTime(uid)
    if tt + static_const.Static_Const_TRAVEL_Employ_MAX_TIME > os.time() then
        return tt + static_const.Static_Const_TRAVEL_Employ_MAX_TIME - os.time()
    end
    return 0
end

--清理停服期间超时的旅行团成员, 这时候还没有开启旅行团定时器
function UserTravel:ClearTravelMemberTimeout()
    local out = {}
    self.members:ForEach(
        function(m_uid, m_time)
            if m_time + static_const.Static_Const_TRAVEL_Employ_MAX_TIME <= os.time() then
                out[m_uid] = true
            end
        end
    )

    local friendData = FriendManager:GetFriendInfo(self.uid)

    for employ_uid, v in pairs(out) do
        --处理金牌客服
        if employ_uid == static_const.Static_Const_Friend_Travel_GOLD_GUEST_UID then

        else
            local f_friendData = FriendManager:GetFriendInfo(employ_uid) 
            if f_friendData ~= nil then
                local f_travelData = f_friendData:GetUserTravel()

                f_travelData:SetEmployUid(0)
                f_travelData:SetEmployName("")
                f_travelData:SetLastEmployUid(self.uid)
                f_travelData:SetEmployCd()
                f_travelData:AddRelationShip(self.uid)
                f_friendData:SetOfflineChange()
            end
            self:AddRelationShip(employ_uid)
        end

        self:DelMember(employ_uid)

        if friendData ~= nil then
            friendData:SetOfflineChange()
        end
    end
end

--开启旅行团成员的所有到期定时器
function UserTravel:StartAllEmployEndTimer()
    self.members:ForEach(
        function(m_uid, m_time)
            self:StartEmployEndTimer(m_uid)
        end
    )
end

--开启雇佣到期定时器
function UserTravel:StartEmployEndTimer(employ_uid)
    local leftTime = self:GetEmployEndLeftTime(employ_uid)
    if leftTime > 0 then
        local employ_timer = unilight.addtimer("FriendManager.FriendTravelEmployTimeout", leftTime, self.uid, employ_uid)
        self.members_timer[employ_uid] = employ_timer
    end
end

--结束雇佣到期定时器
function UserTravel:StopEmployEndTimer(employ_uid)
    local employ_timer =  self.members_timer[employ_uid]
    if employ_timer ~= nil then
        unilight.stoptimer(employ_timer)
    else
        unilight.error("雇佣定时器找不到，出错了。。。。。。。。")
        return false
    end
    self.members_timer[employ_uid] = nil
    return true
end


function UserTravel:GetUnlockSlotCount()
    return self.unlockSlotCount
end

function UserTravel:AddUnlockSlotCount()
    self.unlockSlotCount = self.unlockSlotCount + 1
end

function UserTravel:GetCaptureTimes()
    return self.captureTimes
end

function UserTravel:DecCaptureTimes()
    if self.captureTimes > 0 then
        self.captureTimes = self.captureTimes - 1
    else
        self.captureTimes = 0
    end
end

function UserTravel:AddCaptureTimes(add)
    if add > 0 then
        self.captureTimes = self.captureTimes + add
    end
end

function UserTravel:ClearCaptureInfo()
        self.captureTimes = static_const.Static_Const_TRAVEL_INIT_MAX_CAPTURE_TIMES
        self.todayBuyCaptureTimes = 0
        self.anger_click_count = 0
end

function UserTravel:PrintUserTravel()
    unilight.debug("-------打印旅行团程序信息-------------")
    local tmp = self:GetDBTable()
    unilight.debug(table2json(tmp))
end

--获取好友雇佣他的旅行团UID
function UserTravel:GetEmployUid()
    return self.employUid
end

function UserTravel:GetEmployName()
    return self.employName
end

function UserTravel:SetEmployName(name)
    self.employName = name
end

--设置好友雇佣他的旅行团UID
function UserTravel:SetEmployUid(uid)
    self.employUid = uid
end

-- 雇佣CD时间时间到期前，需要知道上一次雇佣他的人是谁
function UserTravel:GetLastEmployUid()
    return self.lastEmployUid
end

-- 雇佣CD时间时间到期前，需要知道上一次雇佣他的人是谁
function UserTravel:SetLastEmployUid(uid)
    self.lastEmployUid = uid
end

-- 旅行团功能 雇佣CD时间 cd时间到了，上一次雇佣他的对象可以重新雇佣他
function UserTravel:SetEmployCd()
    self.employCd = os.time() + static_const.Static_Const_TRAVEL_Employ_CD_Time
end

--- 是否处于雇佣CD时段里
function UserTravel:GetEmployCdLeftTime()
    if self.employCd > os.time() then
        return self.employCd - os.time()
    else
        return 0
    end
end

function UserTravel:ClearEmployCd()
    self.employCd = 0
end

function UserTravel:GetLevel()
    return self.level
end

function UserTravel:LevelUp()
    self.level = self.level + 1
end

function UserTravel:MembersForEach(fun, ...)
    self.members:ForEach(fun, ...)
end

function UserTravel:IsExistMembers(uid)
    if self.members:Find(uid) == nil then
        return false
    else
        return true
    end
end

function UserTravel:GetMemberTime(uid)
    local t = self.members:Find(uid)
    if t == nil then
        t = 0
    end
    return t
end

function UserTravel:AddMember(uid)
    self.members:Insert(uid, os.time())
end

--删除旅行团成员
function UserTravel:DelMember(uid)
    self.members:Remove(uid)
end

function UserTravel:GetMemberCount()
    return self.members:Count()
end

function UserTravel:GetRelationShip(uid)
    local t = self.relationships:Find(uid)
    if t == nil then
        t = 0
    end
    return t
end

--增加亲密度，有上限100
function UserTravel:AddRelationShip(uid)
    local t = self.relationships:Find(uid)
    if t == nil then
        self.relationships:Insert(uid,1)
    else
        if t >= GlobalConst.Intimacy_MaxPoint then
            return
        end
        t = t + 1
        self.relationships:Replace(uid, t)
    end
end

function UserTravel.BuyShieldCountCallBack(uid, itemid, itemcount)
    local req = {}
    req["do"] = "Cmd.NotifyUserBuyShieldCount_S"
    req["data"] = {
        shield_count = 0,
    }

    req.errno = unilight.SUCCESS
    local laccount = go.roomusermgr.GetRoomUserById(uid)
    if laccount == nil then
        return
    end

    local friendData = FriendManager:GetOrNewFriendInfo(uid);
    local travelData = friendData:GetUserTravel()

    travelData:AddShieldCount(itemcount)
    req["data"].shield_count = travelData:GetShieldCount()

    unilight.success(laccount, req)
end

function UserTravel.AddTravelHeadBackupCallBack(uid, itemid, itemcount)
    local req = {}
    req["do"] = "Cmd.NotifyAddUserTravelHead_S"
    req["data"] = {
        head = 0,
    }

    req.errno = unilight.SUCCESS
    local laccount = go.roomusermgr.GetRoomUserById(uid)
    if laccount == nil then
        return
    end

    local friendData = FriendManager:GetOrNewFriendInfo(uid);
    local travelData = friendData:GetUserTravel()

    local data = travelHead[itemid]
    if data ~= nil then
        travelData:AddTravelHeadBackup(data.head)
        req["data"].head = data.head
    else
        unilight.error("错误，无法通过itemid找到对应的头像,itemid:" .. itemid)
    end

    unilight.success(laccount, req)
end

--重新计算玩家旅行团产量加成
function UserTravel:CalcAddontion()
    self.additon = 1.0
    local friend_sum = 0.0  --所有好友加成之合
    local self_conf = traveLevel[self.level]
    if self_conf == nil then 
        unilight.info("旅行团团长等级找不到配置数据:"..self.level)
        return
    end

    --先计算所有好友的加成，公式为 （好友的雇佣加成*(1+亲密度*亲密度加成) 所有好友之和
    self.members:ForEach(
        function(m_uid, m_time)
            --如果是金牌客服的话
            if m_uid == static_const.Static_Const_Friend_Travel_GOLD_GUEST_UID then
                local config = traveLevel[0]
                if config ~= nil then
                    --单个好友加成
                    local friend_num =  config.capture_addon
                    friend_sum = friend_sum + friend_num --好友之合
                end
            else
                local m_friendData = FriendManager:GetFriendInfo(m_uid)
                if m_friendData ~= nil then
                    local relation_ship = self:GetRelationShip(m_uid)
                    local m_travelData = m_friendData:GetUserTravel()
                    local m_level = m_travelData:GetLevel()
                    local config = traveLevel[m_level]
                    if config ~= nil then
                        --单个好友加成
                        local friend_num =  config.capture_addon * (1 + relation_ship * GlobalConst.Intimacy_Plus)
                        friend_sum = friend_sum + friend_num --好友之合
                    end
                end
            end
        end
    )

    --公式 1 +（所有好友之合 + 团长基础加成） * (1 + 旅行团加成)
    self.additon = 1 + (friend_sum + self_conf.base_addon) * (1 + self_conf.addon)
end

--获得玩家旅行团产量加成
function UserTravel:GetAddontion()
    return self.additon
end



