--≈‰÷√ƒ£øÈ --Œ¥ÕÍ...

--ngx.send_headers("Content-Type","application/json")

local html_file = "/www/lua_path/conf.html"



function echoHtml(html)
	local file = io.open(html_file,"rb")
	io.input(file)
	local content = io.read("*a")
	io.close(file)
	ngx.say(content)
end

function getConf()



local method = ngx.req.get_method()
local params = ngx.req.get_uri_args()


if method == 'GET' and type(params["conf"]) == 'nil' then
	echoHtml(html_file)
elseif method == 'GET' and type(params["conf"]) ~= 'nil' then
	getConf()
elseif method == 'POST' then
	setConf()
else
	ngx.exit(ngx.HTTP_BAD_REQUEST)
end

ngx.exit(ngx.OK)







