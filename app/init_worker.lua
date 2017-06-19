local storage = require("storage")

local worker_id = ngx.worker.id()
if worker_id == 0 then
    -- 初始化, 如果key还未赋值则给key赋初值
    local ok, err = ngx.timer.at(0, function(premature)
        storage:init_index()
    end)

    if not ok then
        ngx.log(ngx.ERR, "failed to create the timer: ", err)
        return os.exit(1)
    end
end