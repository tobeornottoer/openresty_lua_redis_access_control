--访问频率控制
--频率配置 使用redis的hsasmap
--格式为：1.1.1.1 {expire:10,rate:100} 0.0.0.0 为全局IP配置，指定IP配置用ip作为key

require("Redis_Key")
require("Blacklist")
require("Debug")

Rate = {}

function Rate:control(redis,ip)

	local rule = self:getRule(redis,ip)
	if rule == nil or rule.expire == 0 or rule.rate == 0 then
		return true
	end

	local numb = redis:get(Redis_Key.RATE_PREX..ip)

	if numb == 0 or numb == "null" or numb == ngx.null or numb == nil then
		redis:setex(Redis_Key.RATE_PREX..ip,rule.expire,1)
	elseif tonumber(numb) > tonumber(rule.rate) then
		--达到最大阈值，加入黑名单
		if tonumber(rule.max) > 0 and tonumber(rule.max) < tonumber(numb) then
			Blacklist:addIp(redis,ip)
		else
			redis:incrby(Redis_Key.RATE_PREX..ip,1)
		end
		return false
	else
		redis:incrby(Redis_Key.RATE_PREX..ip,1)
	end
	return true

end

function Rate:getRule(redis,ip)

	local rule = redis:hgetall(Redis_Key.RATE_RULE..ip) --指定IP配置
	if rule == nil or rule == ngx.null or rule == false or next(rule) == nil then
		rule = redis:hgetall(Redis_Key.RATE_RULE.."0.0.0.0") --全局IP配置
	end


	rule = self:fotmatRule(rule)

	if rule == false or rule == ngx.null or rule == nil or next(rule) == nil then
		return nil
	else
		local data  = {}
		data.expire  = rule.expire == nil and 0 or rule.expire
		data.rate    = rule.rate   == nil and 0 or rule.rate
		data.max     = rule.max    == nil and 0 or rule.max
		return data
	end

end

function Rate:fotmatRule(rule)
	if rule == nil or next(rule) == nil then
		return nil
	end
	if type(rule) == "table" then
		local data = {}
		for k,v in pairs(rule) do
			if k % 2 == 1 then
				data.v = nil
			end
			if k % 2 == 0 then
				data[rule[k-1]] = v
			end
		end
		return data
	end
	return rule
end


return Rate
