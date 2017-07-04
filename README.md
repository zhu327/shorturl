## OpenResty shorturl

---

基于OpenResty实现的短网址生成服务

主要使用Redis存储,并且将数据落地到MySQL


```shell
curl -X POST \
  http://127.0.0.1:8080/api/v1/shorturl.json \
  -H 'content-type: application/json' \
  -d '{
    "url": "http://zhu327.github.io"
}'
```