
CreateClass("RankNode")   --排行数据节点

--玩家的单个好友数据初始化
function RankNode:Init(uid, value, rank)
    self.uid = uid or 0
    if type(value) ~= "number" then
        value = 0
    end
    self.value = value or 0
    self.rank = rank or 0
    self.lastValue = value or 0 --排行榜排序的时候的值，用来在排行榜显示，不一定等同于value
end

function RankNode:GetUid()
    return self.uid
end

function RankNode:GetValue()
    return self.value
end

function RankNode:GetLastValue()
    return self.lastValue
end

function RankNode:GetRank()
    return self.rank
end

function RankNode:SetValue(value)
    if type(value) ~= "number" then
        value = 0
    end
    self.value = value
end

function RankNode:SetLastValue()
    self.lastValue = self.value
end

function RankNode:SetRank(rank)
    self.rank = rank
end
