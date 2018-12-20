local Index = 0
Do.dbready = function()
	unilight.info("创建表格---------------------")
	-- 初始化多个数据库 跑了多次
	if Index == 0 then
		Index = Index + 1

		unilight.createdb("friendinfo","uid")					-- 玩家好友信息
		unilight.createdb("userQQAppId", "uid")					-- 玩家QQAPPID信息
		unilight.createdb("ranklist", "uid")					-- 排行榜数据库信息

		unitimer.init(100) --初始化定时器（取出数据库缓存时 会调用到时间相关）
        -- 每次连上数据库都会跑该函数 所以只有index=0 才执行这里面的内容 可用于初始化一些要操作db的内容
	end
end
