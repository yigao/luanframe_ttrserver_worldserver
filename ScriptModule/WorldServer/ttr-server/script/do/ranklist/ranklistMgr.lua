CreateClass("RankListMgr")   --排行数据节点

--排行榜类型
RankListMgr.rank_type_star = 1      --星级排行榜
RankListMgr.rank_type_money = 2     --财富排行榜
RankListMgr.rank_type_product = 3   --产出排行榜
RankListMgr.rank_type_click = 4     --点击排行榜
--unilight.createdb("rankStar", "uid")					-- 星级排行榜
--unilight.createdb("rankMoney", "uid")					-- 财富排行榜
--unilight.createdb("rankProduct", "uid")					-- 产出排行榜
--unilight.createdb("rankClick", "uid")					-- 点击排行榜

--初始化排行榜
function RankListMgr:Init()
    self.rank_map = Map:New()
    self.rank_map:Init()

    self:CreateRankList(RankListMgr.rank_type_star)
    self:CreateRankList(RankListMgr.rank_type_money)
    self:CreateRankList(RankListMgr.rank_type_product)
    self:CreateRankList(RankListMgr.rank_type_click)

    unilight.addtimer("RankListMgr.SortRank", static_const.Static_Const_Rank_List_Sort_time)
end

function RankListMgr.SortRank(timer)
    RankListMgr.rank_map:ForEach(
        function(k, rank_list)
            rank_list:SortNode()
        end
    )
end

--从DB中拉取数据
function RankListMgr:LoadFromDB()

end

--保存排行榜数据
function RankListMgr:SaveToDB()

end

function RankListMgr:CreateRankList(rank_type)
    local rank_list = RankList:New()
    rank_list:Init()
    self.rank_map:Insert(rank_type, rank_list)
end

function RankListMgr:UpdateRankNode(rank_type, uid, value)
    local rank_list = self.rank_map:Find(rank_type)
    if rank_list ~= nil then
        rank_list:UpdateNode(uid,value)
    end
end

function RankListMgr:GetRankList(rank_type)
    return self.rank_map:Find(rank_type)
end

function RankListMgr:ReqGetData(rank_type)
    local rank_list = self.rank_map:Find(rank_type)
    if rank_list ~= nil then
        local tmp = {}
        for i, node in ipairs(rank_list:GetList()) do
            tmp[#tmp+1] = node
            if #tmp >= static_const.Static_Const_RANK_LIST_MAX_COUNT then
                return tmp
            end
        end
        return tmp
    end
end

