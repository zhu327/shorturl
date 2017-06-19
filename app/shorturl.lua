local json = require("cjson")

local storage = require("storage")
local config = require("config")


local method = ngx.req.get_method()
if method ~= 'POST' then
    return ngx.exit(ngx.HTTP_NOT_ALLOWED)
end


ngx.req.read_body()
local body = ngx.req.get_body_data()


local function validator(body)
    local ok, data = pcall(json.decode, body)
    if not ok then
        return nil, 10001, '数据格式错误'
    end

    local url = data.url or ''
    data.remark = data.remark or ''

    -- 正则验证 url
    local regex = [[https?:/{2}\w.+$]]

    local m, err = ngx.re.match(url, regex, "jo")
    if not m then
        return nil, 10002, 'url格式错误'
    end

    return data, nil, nil
end


local res, code, err = validator(body)

ngx.header['Content-Type'] = 'application/json; charset=utf-8'

if res then
    local key = storage:set(res.url, res.remark)
    
    ngx.say(json.encode({
        result = true,
        resultcode = 200,
        msg = '',
        errormsg = '',
        data = {
            url = config.url .. key
        }
    }))
else
    ngx.say(json.encode({
        result = false,
        resultcode = code,
        msg = '',
        errormsg = err,
        data = {}
    }))
end