--curl -d {"name": "Jack"}  http://localhost:8084/post
ngx.header['server'] = 'secret';
ngx.req.read_body();
local data = ngx.req.get_body_data();
ngx.say(data);