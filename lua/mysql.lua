local mysql = require('resty.mysql');
local cjson = require "cjson"

local db, err = mysql:new();
-- docker network connect mysql_default openresty
-- docker network inspect mysql_default
local mysql_host = '172.31.0.3'

if not db then
    ngx.say('failed to instantiate mysql:', err);
end

db:set_timeout(1000); -- 1 second

local ok, err, errno, sqlstate = db:connect{
    host = mysql_host,
    port = 3306,
    database = 'demo',
    user = 'root',
    password = '12345678',
    max_packet_size = 1024 * 1024
}

if not ok then
    ngx.say('failed to connect: ', err, ':', errno, ' ', sqlstate);
    return;
end

--ngx.say('connected to mysql.')

local ok, err, errno, sqlstate = db:query([[
    create table if not exists dogs (
    id smallint auto_increment primary key,
    name varchar(255) default null,
    age tinyint
);
]]);

if not ok then
    ngx.say("bad result:", err, ": ", errno, ": ", sqlstate, ".");
    return;
end
--ngx.say('table dogs was created.');

math.randomseed(os.time());
local dog_name = 'doggy'..math.random(1,100);
local dog_age = math.random(1,15);
local ok, err, errno, sqlstate = db:query("insert into dogs(name, age) values('"..dog_name.."', "..dog_age..")");
if not ok then
    ngx.say("bad result:", err, ": ", errno, ": ", sqlstate, ".");
    return;
end
--ngx.say('data insert successful.');

local ok, err, errno, sqlstate = db:query("select id,name,age from dogs;");
if not ok then
    ngx.say("bad result:", err, ": ", errno, ": ", sqlstate, ".");
    return;
end
-- ngx.header['Content-Type'] = 'application/json; charset=utf-8';
ngx.say(cjson.encode(ok));

