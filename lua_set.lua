--配置模块 --未完...

--ngx.send_headers("Content-Type","application/json")

require("Redis")
require("Redis_Key")

function getConf()
	local red   = Redis:new()
	local switch = red:get(Redis_Key.SWITCH) -- nil or 0 or 1
	local blacklist_ip = getBlacklist(red:smembers(Redis_Key.BLACKLIST_IP)) -- nil or ip,ip,ip
	local rate_table_str = getRateConf(red)

	if switch == nil or switch == ngx.null or switch == false then
		switch = 0
	end
	local result = '{"sitc":'..switch..',"blacklistip":'..blacklist_ip..',"rateconf":'..rate_table_str.."}"
	Redis:set(red)
	ngx.send_headers("Access-Control-Allow-Origin","*")
	ngx.send_headers("Content-Type","application/json")
	ngx.say(result)
end

function setConf()
end

--获取黑名单列表 json
function getBlacklist(list)
	local blacklist = nil
	for k,v in pairs(list) do
		if blacklist == nil then
			blacklist = "\""..v.."\""
		else
			blacklist = blacklist..",".."\""..v.."\""
		end
	end
	return blacklist == nil and "[]" or "["..blacklist.."]"
end

--获取速率配置 json
function getRateConf(red)
	local rate_list_keys = red:keys(Redis_Key.RATE_RULE.."*")
	local rate_table_str = ""
	if next(rate_list_keys) ~= nil then
		for k,v in pairs(rate_list_keys) do
			local data = red:hgetall(v)
			if rate_table_str == "" then
				rate_table_str = "\""..v.."\":"..table2jsonforhashmap(data)
			else
				rate_table_str = rate_table_str..",\""..v.."\":"..table2jsonforhashmap(data)
			end
		end
	end
	rate_table_str = "{"..rate_table_str.."}"
	return rate_table_str
end

--格式化redis hashmap
function table2jsonforhashmap(t)
	if t == nil or next(t) == nil then
		return  "{}"
	end
	local json = "{"
	for k,v in pairs(t) do
		if json ~= "{" and k % 2 == 1 then
			json = json..","
		end
		if k % 2 == 1 then
			json = json.."\""..v.."\":".."\""..t[k+1].."\""
		end
	end
	json = json.."}"
	return json
end



local method = ngx.req.get_method()
local params = ngx.req.get_uri_args()



if method == 'GET' and type(params["conf"]) == 'nil' then
	return ngx.redirect("/conf.html")
elseif method == 'GET' and type(params["conf"]) ~= 'nil' then
	getConf()
elseif method == 'POST' then
	setConf()
elseif method == "OPTIONS" then
	ngx.send_headers("Access-Control-Allow-Origin","*")
	ngx.say("a")
else
	ngx.exit(ngx.HTTP_BAD_REQUEST)
end

ngx.exit(ngx.OK)







