local fmod = math.fmod
local floor = math.floor
local sub = string.sub
local redis = require("redis_db")
local mysql = require("mysql_db")

local config = require("config")


local function convert_to_code(num)
    local codes = "QKV4hy7YaBMgWUzFAJLpPudeoGHnOi0m6xItDj2cRE8Cwq1s9rblXTSkvN3f5Z"
    local length = string.len(codes)
    local str = ''
    local index, char
    while num > 0 do
        index = fmod(num, length) + 1
        char = sub(codes, index, index)
        str = char .. str
        num = floor(num / length)
    end
    return str
end


local _M = {
    _index_key = "shorturl::_index",
    _base_key = "shorturl::"
}


function _M:get_index()
    -- 获取下一个索引
    local index_key = self._index_key
    local red = redis:new(config.redis)
    local res, err = red:incr(index_key)
    ngx.log(ngx.DEBUG, 'redis incr value ' .. tostring(res))
    if not res then
        ngx.log(ngx.ERR, "reids connection error")
    end
    return res
end


function _M:init_index()
    -- 初始化索引值, 如果索引为null
    local index_key = self._index_key
    local red = redis:new(config.redis)
    local res, err = red:get(index_key)
    if res == nil then
        res, err = red:set(index_key, 14776336)
        ngx.log(ngx.DEBUG, 'redis set value ' .. tostring(res))
        if not res then
            ngx.log(ngx.ERR, "reids connection error")
        end
    end
end


function _M:gene_key()
    -- 索引转为短链接key
    local index = self:get_index()
    return convert_to_code(index)
end


function _M:_redis_key(key)
    return self._base_key .. key
end


local function insert_mysql(key, url, remark)
    local db = mysql:new(config.mysql)
    local sql = "INSERT INTO `t_shorturl` (`c_key`, `c_value`, `c_remark`, `c_add_dt`) VALUES (?, ?, ?, NOW())"
    local res, err = db:insert(sql, {key, url, remark})
    if not res or err then
        ngx.log(ngx.ERR, "mysql insert faild: " .. tostring(err))
    end
end


local function select_mysql(key)
    local db = mysql:new(config.mysql)
    local sql = "SELECT `c_value` FROM `t_shorturl` WHERE `c_key` = ? LIMIT 1"
    local res, err, errno, sqlstate = db:select(sql, {key})
    if not res or err then
        ngx.log(ngx.ERR, "mysql select faild: " .. tostring(err))
        return nil
    elseif res[1] then
        return res[1].c_value
    end
end


function set_redis(key, value)
    local red = redis:new(config.redis)
    local res, err = red:set(key, value)
    ngx.log(ngx.DEBUG, 'redis set key '.. key .. ':' .. tostring(res))
    if not res then
        ngx.log(ngx.ERR, "reids connection error")
    end
    return res, err
end


function _M:set(url, remark)
    local key = self:gene_key()
    set_redis(self:_redis_key(key), url)

    -- 落地到数据库
    local ok, err = ngx.timer.at(0, function(premature, key, url, remark)
        insert_mysql(key, url, remark)
    end, key, url, remark)

    if not ok then
        ngx.log(ngx.ERR, "failed to create the timer: ", tostring(err))
    end

    return key
end


function _M:get(key)
    local redis_key = self:_redis_key(key)
    local red = redis:new(config.redis)
    local res, err = red:get(redis_key)
    ngx.log(ngx.DEBUG, 'redis get key ' .. key .. ':' .. tostring(res))
    if res then
        return res
    end

    -- 从数据库取
    res = select_mysql(key)
    if not res then
        return nil
    end
    set_redis(redis_key, res)
    return res
end


return _M