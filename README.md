# OpenResty

1、创建 conf.d 目录
> mkdir conf.d

2、拷贝 OpenResty 默认配置至当前目录下
> docker run -d --name temp_openresty openresty/openresty:1.19.9.1-10-alpine-fat && docker cp temp_openresty:/etc/nginx/conf.d/default.conf ./conf.d && docker rm -f temp_openresty

3、修改默认 conf.d/default.conf 文件
```nginx configuration
server {
    listen       80;
    server_name  localhost;

    # 改为 utf8 可解决中文乱码
    charset utf8;
    # 修改完配置文件就立即生效
    lua_code_cache off; 

    location / {
        default_type text/html;
        content_by_lua_block {
            ngx.say("<p>你好，hello, world!</p>")
        }
    }   
}
```

4、编写 .env 文件
```dotenv
container_name=openresty
port=8084
restart=always
```

5、编写 docker-compose.yaml 文件
```yaml
version: '3.9'
services:
  openresty:
    image: openresty/openresty:1.19.9.1-10-alpine-fat
    container_name: ${container_name}
    env_file:
      - .env
    ports:
      - "${port}:80"
    restart: ${restart}
    volumes:
      - ./conf.d:/etc/nginx/conf.d:ro
      - ./lua:/usr/local/openresty/nginx/lua:ro
```

6、编写 lua 文件

> OpenResty 文档 https://openresty-reference.readthedocs.io/en/latest/Lua_Nginx_API/

`lua/hello.lua`
```lua
ngx.say("<p>你好，hello, world from Lua file!!</p>");
```

`lua/random-string.lua`
```lua
local args = ngx.req.get_uri_args();
local salt = args.salt;
if not salt then
    ngx.exit(ngx.HTTP_BAD_REQUEST);
end

-- lua 里两个半角句号表示字符串相加
local digest = ngx.md5(ngx.time() .. salt);
ngx.say(digest);
```

7、更新 `conf.d/default.conf`
```dotenv
 location /get-random-string {
    default_type text/plain;
    content_by_lua_file lua/random-string.lua;
}
```

8、调试 lua 配置
```shell
docker exec -it openresty /usr/local/openresty/bin/openresty -s reload
```

9、连接 Redis (另一个 Docker 里的)
```lua
local redis = require "resty.redis"
local red = redis:new()

red:set_timeouts(1000, 1000, 1000) -- 1 sec

-- 通过 docker network connect redis-commander_default openresty 才能连接另一个 Docker 里的 redis
local ok, err = red:connect("192.168.80.2", 6379)

if not ok then
    ngx.say("failed to connect: ", err)
    return
end

ok, err = red:set("dog", "an animal")
if not ok then
    ngx.say("failed to set dog: ", err)
    return
end

ngx.say("set result: ", ok)

local res, err = red:get("dog")
if not res then
    ngx.say("failed to get dog: ", err)
    return
end

if res == ngx.null then
    ngx.say("dog not found.")
    return
end

ngx.say("dog: ", res)

red:init_pipeline()
red:set("cat", "Marry")
red:set("horse", "Bob")
red:get("cat")
red:get("horse")
local results, err = red:commit_pipeline()
if not results then
    ngx.say("failed to commit the pipelined requests: ", err)
    return
end

for i, res in ipairs(results) do
    if type(res) == "table" then
        if res[1] == false then
            ngx.say("failed to run command ", i, ": ", res[2])
        else
            -- process the table value
        end
    else
        -- process the scalar value
    end
end

-- put it into the connection pool of size 100,
-- with 10 seconds max idle time
local ok, err = red:set_keepalive(10000, 100)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end

-- or just close the connection right away:
-- local ok, err = red:close()
-- if not ok then
--     ngx.say("failed to close: ", err)
--     return
-- end
```

more references: https://www.bilibili.com/video/BV1nU4y1x7Lt?p=1