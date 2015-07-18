# WSO2 AS 5.2.1 Dockerfile

WSO2 AS 5.2.1 Dockerfile defines required resources for building a Docker image with WSO2 AS 5.2.1.

## How to build

1. Copy following files to the packages folder:
```
wso2as-5.2.1.zip
```

2. Run build.sh file to build the docker image:
```
sh build.sh clean
```

3. List docker images:
```
docker images
```