
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
	if switch == "0" or switch == ngx.null or switch == nil or ngx.var.uri == '/lua_set' then
		--不开启访问控制 /lua_set配置页面
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

	--颁发令牌
	awardToken(ip)

	Redis:set(red)
	ngx.exit(ngx.OK)

end


function get_client_ip()
	local headers = ngx.req.get_headers()
    local ip = headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"
    return ip
end

function awardToken(ip)
	-- lua_ngx 加密算法 https://github.com/openresty/lua-resty-string
	local aes = require "resty.aes"
    local str = require "resty.string"
	local key = "1234567890123456"
	local iv  = "6543210987654321"
    local aes_128_cbc = assert(aes:new(key,nil, aes.cipher(128,"cbc"), {iv=iv}))   -- AES 128 CBC with IV and no SALT
    local encrypted = aes_128_cbc:encrypt(ip.."_"..os.time())
	ngx.req.set_header("access-pass", str.to_hex(encrypted))

end

run()
