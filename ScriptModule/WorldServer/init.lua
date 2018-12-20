WorldServer = { }

function WorldServer.load_script_file()
	register_module(WorldServerModule, "WorldServerModule")
end

--加载所有的module
unilight.InsertLoadFunc(WorldServer.load_script_file)

return WorldServer