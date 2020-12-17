-- 该文件定义所有在redis里的key
Redis_Key                            = {}
--访问控制开关
Redis_Key.SWITCH                     = "ngx_lua_AC"

Redis_Key.BLACKLIST_IP               = "ngx_lua_blacklist_ip"
Redis_Key.BLACKLIST_USER             = "ngx_lua_blacklist_user"

Redis_Key.RATE_PREX                  = "ngx_lua_rate_"
Redis_Key.RATE_RULE                  = "ngx_lua_rate_rule"


return Redis_Key
