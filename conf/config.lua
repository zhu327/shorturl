return {
    redis = {
        host = "127.0.0.1",
        port = 6379,
        timeout = 1, -- 1 second
        db_index = 0,
        password = nil
    },
    mysql = {
        timeout = 5000,
        connect_config = {
            host = "127.0.0.1",
            port = 3306,
            database = "shorturl",
            user = "root",
            password = "",
            max_packet_size = 1048576
        },
        pool_config = {
            max_idle_timeout = 10000,
            pool_size = 3
        },
        desc = "mysql configuration"
    },
    url = 'http://localhost:8080/',
}