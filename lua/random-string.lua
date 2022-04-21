local args = ngx.req.get_uri_args();
local salt = args.salt;
if not salt then
    ngx.exit(ngx.HTTP_BAD_REQUEST);
end

-- lua 里两个半角句号表示字符串相加
local digest = ngx.md5(ngx.time() .. salt);
ngx.say(digest);