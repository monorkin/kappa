npm run transpile
docker run \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -p "3000:3000" \
    -p "3001:8080" \
    -e "PROJECT_ROOT=$PWD" \
    -e "HANDLER=bin/index.handler" \
    stankec/kappa
