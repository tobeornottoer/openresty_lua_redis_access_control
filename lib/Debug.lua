--debug
Debug = {}

function Debug.vard(var)
	local file = io.open("/www/lua_path/debug.log","a+")
	io.output(file)

	if type(var) == "table" then
		for k,v in pairs(var) do
			io.write(v.."=="..k.."\n")
		end
	else
		io.write(var.."\n")
	end
	io.write(os.time().."========".."\n")
	io.close(file)
end

return Debug
