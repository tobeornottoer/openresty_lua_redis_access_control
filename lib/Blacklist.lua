--黑名单模块

require("Redis_Key")

Blacklist = {}

function Blacklist:addIp(redis,ip)
	local ok,err = redis:SADD(Redis_Key.BLACKLIST_IP,ip)
	if not ok then
		ngx.log(ngx.WARN,"blacklist:add ip fair",err,ok)
		return nil
	end
end

function Blacklist:addUser(redis,user)
	local ok,err = redis:SADD(Redis_Key.BLACKLIST_USER,user)
	if not ok then
		ngx.log(ngx.WARN,"blacklist:add user fair",err,ok)
		return nil
	end
end
--检查黑名单IP
function Blacklist:checkIp(redis,ip)
	local ip,err = redis:SISMEMBER(Redis_Key.BLACKLIST_IP,ip)
	if not ip then
		ngx.log(ngx.WARN,"blacklist:get ip fair",err,ip)
		return false
	end
	if ip == 0 or ip == "0" then
		return true
	end
	return false
end
--检查黑名单user
function Blacklist:checkUser(redis,user)
	local user,err = redis:SISMEMBER(Redis_Key.BLACKLIST_USER,user)
	if not user then
		ngx.log(ngx.WARN,"blacklist:get user fair",err,user)
		return false
	end
	if user == 0 or user == "0" then
		return true
	end
	return false
end

return Blacklist
