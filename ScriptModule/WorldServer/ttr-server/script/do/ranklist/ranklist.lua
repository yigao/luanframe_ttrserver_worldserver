

CreateClass("RankList")   --排行数据节点

--初始化排行榜队列
function RankList:Init()
    --玩家数据映射
    self.node_list_map = Map:New()
    self.node_list_map:Init()

    --排行榜数据
    self.node_list = {}
end

function RankList:CreateNode(uid, value)
    local node = RankNode:New()
    node:Init(uid,value)
    self.node_list_map:Insert(uid, node)
    return node
end

function RankList:GetNode(uid)
    return self.node_list_map:Find(uid)
end

function RankList:UpdateNode(uid, value)
    if type(value) ~= "number" then
        value = 0
    end
    local node = self.node_list_map:Find(uid)
    if node == nil then
        node = self:CreateNode(uid, value)
    end
    node:SetValue(value)
    return node
end

function RankList.SortFunc(first, second)
    if first.value > second.value then
        return true
    end
    return false
end

function RankList:SortNode()
    table.reset(self.node_list)
    self.node_list_map:ForEach(
        function(k,v)
            local node = v
            table.insert(self.node_list, node)
        end
    )

    table.sort(self.node_list, RankList.SortFunc)

    for k, node in ipairs(self.node_list) do
        node:SetRank(k)
        node:SetLastValue()
    end
end

function RankList:GetList()
    return self.node_list
end