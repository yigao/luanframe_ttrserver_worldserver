CreateClass("FriendVisit")   --好友互访数据

function FriendVisit:Init(uid)
    self.uid = uid
    --当前地图ID, 第一个地图的ID为101
    self.cur_map_id = 101;
    --地图数据
    self.builds = {}

    --鼓舞次数
    self.today_mischief_number = 0
    --捣蛋次数
    self.today_inspire_number = 0
    --被鼓舞次数
    self.today_encouraged_number = 0
    --被捣蛋次数
    self.today_beteased_number = 0

    --上一次被鼓舞的时间,用于看视频，当看完视屏后，立马设置为0
    self.last_mischief_time = 0

    --上一次被鼓舞的时间,用于看视频，当看完视屏后，立马设置为0
    self.last_inspire_time = 0

    --上一次捣蛋的有奖励建筑
    self.last_inspire_buildid = 0

    --今天鼓舞的好友
    self.today_mischief_friends = {}
    --今天捣蛋的好友
    self.today_inspire_friends = {}

    --因为好友互访，玩家数据不在内存中，暂时存放在这里
    self.add_visit_money = 0
    self.sub_visit_money = 0

    --上一次鼓舞money
    self.last_mischief_money = 0
end

function FriendVisit:SetLastMischiefTime(t)
    self.last_mischief_time = t
end

--看视频10分钟里结束算有效
function FriendVisit:IsMischiefTimeEffect()
    if self.last_mischief_time + 600 > os.time() then
        return true
    end
    return false
end

--看视频10分钟里结束算有效
function FriendVisit:IsLastInspireTimeEffect()
    if self.last_mischief_time + 600 > os.time() then
        return true
    end
    return false
end

function FriendVisit:SetLastInspireTime(t)
    self.last_inspire_time = t
end

function FriendVisit:AddVisitMoney(money)
    if money > 0 then
        self.add_visit_money = self.add_visit_money + money
    end
end

function FriendVisit:SubVisitMoney(money)
    if money > 0 then
        self.sub_visit_money = self.sub_visit_money + money
    end
end

--清理今日数据
function FriendVisit:ZeroClearData()
    --鼓舞次数
    self.today_mischief_number = 0
    --捣蛋次数
    self.today_inspire_number = 0
    --被鼓舞次数
    self.today_encouraged_number = 0
    --被捣蛋次数
    self.today_beteased_number = 0

    --今天鼓舞的好友
    self.today_mischief_friends = {}
    --今天捣蛋的好友
    self.today_inspire_friends = {}
end

--是否今天鼓舞过
function FriendVisit:IsTodayMischief(uid)
    if self.today_mischief_friends[uid] ~= nil then
       return true
    end
    return false
end

--是否今天捣蛋过
function FriendVisit:IsTodayInspire(uid)
    if self.today_inspire_friends[uid] == true then
       return true
    end
    return false
end

--是否今天还可以捣蛋看视屏
function FriendVisit:IsTodayInspireSeeSceen(uid)
    if self.today_inspire_friends[uid] == nil then
        return true
    end
    return false
end

--记录今天鼓舞过得玩家
function FriendVisit:RecordMischiefFriend(uid)
    self.today_mischief_friends[uid] = true
end

--记录今天捣蛋玩家
function FriendVisit:RecordInspireFriend(uid)
    self.today_inspire_friends[uid] = true
end

--记录在给一次机会..今天捣蛋玩家
function FriendVisit:AgainInspireFriend(uid)
    self.today_inspire_friends[uid] = false
end

--增加今天鼓舞次数
function FriendVisit:AddMischiefNumber()
    self.today_mischief_number = self.today_mischief_number + 1
end

--获得今天鼓舞次数
function FriendVisit:GetMischiefNumber()
    return self.today_mischief_number
end

--今天鼓舞次数是否到达上线
function FriendVisit:MischiefNumberIsLimit()
    if self.today_mischief_number >= GlobalConst.Mischief_Number then
        return true
    end
    return false
end

--增加今天捣蛋次数
function FriendVisit:AddInspireNumber()
    self.today_inspire_number = self.today_inspire_number + 1
end

--获得今天捣蛋次数
function FriendVisit:GetInspireNumber()
    return self.today_inspire_number
end

--今天捣蛋次数是否到达上线
function FriendVisit:InspireNumberIsLimit()
    if self.today_inspire_number >= GlobalConst.Tnspire_Number then
        return true
    end
    return false
end

--增加今天被鼓舞次数
function FriendVisit:AddEncouragedNumber()
    self.today_encouraged_number = self.today_encouraged_number + 1
end

--获得今天被鼓舞次数
function FriendVisit:GetEncouragedNumber()
    return self.today_encouraged_number
end

--今天被鼓舞次数是否到达上线
function FriendVisit:EncouragedNumberIsLimit()
    if self.today_encouraged_number >= GlobalConst.Encouraged_Number then
        return true
    end
    return false
end

--增加被捣蛋次数
function FriendVisit:AddBeteasedNumber()
    self.today_beteased_number = self.today_beteased_number + 1
end

--获得被捣蛋次数
function FriendVisit:GetBeteasedNumber()
    return self.today_beteased_number
end

--被捣蛋次数是否到达上线
function FriendVisit:BeteasedNumberIsLimit()
    if self.today_beteased_number >= GlobalConst.Beteased_Number then
        return true
    end
    return false
end

function FriendVisit:GetDBTable()
    local data = {}
    data.cur_map_id = self.cur_map_id
    data.today_mischief_number = self.today_mischief_number
    data.today_inspire_number = self.today_inspire_number
    data.today_encouraged_number = self.today_encouraged_number
    data.today_beteased_number = self.today_beteased_number
    data.add_visit_money = self.add_visit_money
    data.sub_visit_money = self.sub_visit_money
    data.builds = {}
    for id, info in pairs(self.builds) do
        data.builds[id] = {
            id = info.id,
            level = info.level,
            buildlv = info.buildlv,
        }
    end
    data.today_mischief_friends = {}
    for k,v in pairs(self.today_mischief_friends) do
        data.today_mischief_friends[k] = v
    end

    data.today_inspire_friends = {}
    for k,v in pairs(self.today_inspire_friends) do
        data.today_inspire_friends[k] = v
    end
    return data
end

function FriendVisit:SetDBTable(data)
    if data == nil then return end

    self.cur_map_id = data.cur_map_id or self.cur_map_id
    self.today_mischief_number = data.today_mischief_number or self.today_mischief_number
    self.today_inspire_number = data.today_inspire_number or self.today_inspire_number
    self.today_encouraged_number = data.today_encouraged_number or self.today_encouraged_number
    self.today_beteased_number = data.today_beteased_number or self.today_beteased_number
    self.add_visit_money = data.add_visit_money or self.add_visit_money
    self.sub_visit_money = data.sub_visit_money or self.sub_visit_money

    if data.builds ~= nil then
        for id, info in pairs(data.builds) do
            self.builds[id] = {
                id = info.id,
                level = info.level,
                buildlv = info.buildlv,
            }
        end
    end

    if data.today_mischief_friends ~= nil then
        for k, v in pairs(data.today_mischief_friends) do
            self.today_mischief_friends[k] = v
        end
    end

    if data.today_inspire_friends ~= nil then
        for k, v in pairs(data.today_inspire_friends) do
            self.today_inspire_friends[k] = v
        end
    end
end

function FriendVisit:GetCurMapId()
    return self.cur_map_id
end

function FriendVisit:SetCurMapId(mapid)
    self.cur_map_id = mapid
    self.builds = {}
end

function FriendVisit:GetBuilds()
    return self.builds
end

function FriendVisit:GetLastInpireBuildId()
    if self.last_inspire_buildid == 0 or self.last_inspire_buildid == nil then
        self:GetRandBuilds()
    end
    return self.last_inspire_buildid
end

function FriendVisit:GetRandBuilds()
    local tmp = {}
    for k, v in pairs(self.builds) do
        table.insert(tmp, k)
    end

    if #tmp > 0 then
        self.last_inspire_buildid = tmp[math.random(#tmp)]
    else
        for k, v in pairs(TableBuilding) do
            if v["mapid"] == self.cur_map_id then
                table.insert(tmp, k)
            end
        end
        if #tmp > 0 then
            self.last_inspire_buildid = tmp[math.random(#tmp)]
        else
            self.last_inspire_buildid = 0
        end
    end
end

function FriendVisit:AddBuild(buildid, level, buildlv)
    self.builds[buildid] = {
        id = buildid,
        level = level,
        buildlv = buildlv,
    }
end

function FriendVisit:SetLevel(buildid, level)
    if self.builds[buildid] ~= nil then
        self.builds[buildid].level = level
    end
end

function FriendVisit:SetBuildLevel(buildid, buildlv)
    if self.builds[buildid] ~= nil then
        self.builds[buildid].buildlv = buildlv
    end
end



