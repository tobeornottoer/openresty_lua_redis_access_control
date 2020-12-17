Redis                 = {}
Redis.addr            = "127.0.0.1"
Redis.port            = 6379
Redis.connect_timeout = 1000 --1s
Redis.send_timeout    = 1000 --1s
Redis.read_timeout    = 3000 --3s
Redis.link_freetime   = 10000 --连接池内连接的空闲时间
Redis.pool_name       = "lua_redis_pool"
Redis.pool_size       = 10

--获取redis连接池配置
function Redis:getConf()
	local pool = {}
	pool.pool  = self.pool_name
	pool.pool_size = self.pool_size
	return pool
end

--连接redis
function Redis:new()
	local redis = require "resty.redis"
	local red   = redis:new()
	local conf  = self:getConf()
	red:set_timeouts(self.connect_timeout, self.send_timeout, self.read_timeout)
	local ok, err = red:connect(self.addr, self.port,conf)
	if not ok then
		ngx.log(ngx.ERR,"redis failed to connect: ", err)
		ngx.exit(ngx.HTTP_BAD_GATEWAY)
		return
	end
	return red
end

--将redis放回连接池
function Redis:set(red)
	local ok,err = red:set_keepalive(self.link_freetime, self.pool_size)
	if not ok then
		ngx.log(ngx.WARN,"failed to set keepalive: ", err)
		return
	end
end

return Redis
