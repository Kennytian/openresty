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