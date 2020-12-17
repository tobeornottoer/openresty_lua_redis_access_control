
require("Redis")
require("Redis_Key")
require("Blacklist")
require("Rate")

function run()
	local red   = Redis:new()
	--local code  = red:get("http_code")
	--Redis:set(red)
	--ngx.exit(tonumber(code))

	local switch = red:get(Redis_Key.SWITCH)
	if switch == "0" or switch == ngx.null or switch == nil then
		--不开启访问控制
		Redis:set(red)
		ngx.exit(ngx.OK)
	end

	--黑名单拦截
	local ip = get_client_ip()
	local check_ip = Blacklist:checkIp(red,ip)
	if ip ~= "0.0.0.0" and check_ip == false then
		Redis:set(red)
		ngx.exit(ngx.HTTP_FORBIDDEN)
	end

	--访问速率
	local check_rate = Rate:control(red,ip)
	if ip ~= "0.0.0.0" and check_rate == false then
		Redis:set(red)
		ngx.exit(ngx.HTTP_FORBIDDEN)
	end

	Redis:set(red)
	ngx.exit(ngx.OK)

end


function get_client_ip()
	local headers = ngx.req.get_headers()
    local ip = headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"
    return ip
end

run()
