## ZTS Bug on Alpine

TO reproduce the bug, have Docker installed and run:

```bash
sh start
```

In a separate terminal, run:

```bash
curl localhost:8282
```

The request will hang and eventually crash the server 


For a debug build, build the Dockerfile in the root of this repo instead and use that in startup

```bash
docker build -t frankenphp-with-debug .
docker run --rm -it \
  --name debug_frankenphp_container \
  -e SERVER_NAME=:80 \
  -v ".:/app" \
  -p 8282:80 \
  frankenphp-with-debug
```