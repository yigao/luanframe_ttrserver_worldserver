

-- event on server

StopServerClass = CreateClass("StopServerClass")

function StartOver()
	local CYCLE_MIN = 60
    local CYCLE_HOUR = 3600
    local CYCLE_DAY = CYCLE_HOUR * 24
    local CYCLE_WEEKLY = CYCLE_DAY * 7

    -- 这里是服务器启动后必定会执行的一个函数 这里可以添加各种初始化相关的内容

    --初始化排行榜
    if RankListMgr ~= nil then
        RankListMgr:Init()
    end
    --好友管理系统初始化
    if FriendManager ~= nil then
        FriendManager:Init()
    end
end
