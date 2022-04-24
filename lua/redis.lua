-- https://github.com/openresty/lua-resty-redis
ngx.header['server'] = 'secret';
local redis = require "resty.redis"
local red = redis:new()
local redis_host = '192.168.80.3';

red:set_timeouts(1000, 1000, 1000) -- 1 sec

-- 通过 docker network connect redis-commander_default openresty 才能连接另一个 Docker 里的 redis
-- docker network connect redis-commander_default openresty
local ok, err = red:connect(redis_host, 6379)

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
ngx.say("dog err: ", err, err==nil);

if err then
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
            ngx.say('table index:', i, ', value:', res);
        end
    else
        ngx.say('res not equal table value:', res);
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