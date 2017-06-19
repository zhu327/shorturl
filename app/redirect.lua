local storage = require("storage")


local method = ngx.req.get_method()
if method ~= 'GET' then
    return ngx.exit(ngx.HTTP_NOT_ALLOWED)
end


local key = ngx.var[1]

local url = storage:get(key)

if url then
    ngx.redirect(url, ngx.HTTP_MOVED_PERMANENTLY)
else
    ngx.exit(ngx.HTTP_NOT_FOUND)
end