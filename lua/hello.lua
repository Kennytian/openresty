ngx.header['server'] = 'secret';
local startTime = ngx.req.start_time();
ngx.say("<p>你好，hello, world from Lua file!!</p>");
ngx.say('ngx.HTTP_GET value is:' .. ngx.HTTP_GET);
ngx.say('ngx.HTTP_POST value is:' .. ngx.HTTP_POST);
ngx.say('ngx.OK value is:' .. ngx.OK);
ngx.say('ngx.DONE value is:' .. ngx.DONE);
ngx.say('ngx.req.start_time() value is:' .. ngx.req.start_time());
ngx.say('ngx.now() value is:' .. ngx.now());
ngx.sleep(1);
ngx.say('ngx elapsed value is:' .. (ngx.now() - startTime) .. 's');
ngx.say('ngx.localtime() value is:' .. ngx.localtime());
ngx.say('ngx.utctime() value is:' .. ngx.utctime());
ngx.say('ngx.http_time(startTime) value is:' .. ngx.http_time(startTime));
ngx.say('ngx.req.http_version() value is:' .. ngx.req.http_version());
ngx.print('ngx.req.raw_header() value is:' .. ngx.req.raw_header())
ngx.say('ngx.req.raw_header() value is:' .. ngx.req.raw_header(true));
ngx.say('ngx.today() value is:' .. ngx.today());
ngx.say('ngx.time() value is:' .. ngx.time());
