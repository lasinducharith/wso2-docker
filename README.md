# WSO2 Docker Images for clustered setups

The following repository contains several WSO2 docker images and template configuration files

* Clustering with wka membership scheme
* Separate MySQL-server container and svn-server container
* Shared userstore and registry MySQL database mounts
* Dep-sync artifact synchronizing enabled

## How to create a ESB/AS docker cluster?

* **Build required docker image**
  * Build base-image
  * Next build ESB/AS docker images (To build the WSO2 AS, ESB docker images, you should  first build the base docker image)
  * Pull MySQL-server and svn-server docker images from docker hub
    I have used [sameersbn/mysql](https://registry.hub.docker.com/u/sameersbn/mysql/) mysql-server docker image and [krisdavison/svn-server](https://registry.hub.docker.com/u/krisdavison/svn-server/) svn-server docker image, without re-inventing the wheel

* **Execute run.sh bash script inside required server**

## Repository directory structure

```
   ├── docker
   │   ├── base-image
   │   │   ├── build.sh
   │   │   └── Dockerfile
   │   ├── wso2as-5.2.1
   │   │   ├── build.sh
   │   │   ├── Dockerfile
   │   │   └── run.sh
   │   ├── wso2esb-4.8.1
   │   │   ├── build.sh
   │   │   ├── Dockerfile
   │   │   └── run.sh
   │   │ 
   └── template-modules
       ├── wso2as-5.2.1
       │   
       └── wso2esb-4.8.1
          
```
## Steps to get started (Below explains how to create a ESB cluster)

(1) Copy following files to the packages folder of base-image (wso2-docker/docker/base-image):
```
jdk-7u60-linux-x64.tar
ppaas-configurator-4.1.0-SNAPSHOT.zip
```

(2)  Run build.sh file to build the docker image:
```
sh build.sh
```

(3) Navigate to wso2esb docker image directory (wso2-docker/docker/wso2esb-4.8.1) and copy the ESB distribution:
```
wso2esb-4.8.1.zip
```

(4) Run build.sh file with 'clean' param to build the docker image with template module:
```
sh build.sh clean
```

(5) List docker images and see if _lasinducharith/base_ and  _lasinducharith/esb_ images are avaiable:
```
docker images
```
 
(6) Pull MySQL server and SVN-Server docker images (optional) - Even if you do not pull the images here, when we execute the run script, it will download the images from docker-hub
```
docker pull sameersbn/mysql:latest
docker pull krisdavison/svn-server:v2.0
```
```

(7) Navigate to wso2esb docker image directory (wso2-docker/docker/wso2esb-4.8.1) and execute run script.
```
sudo ./run.sh
```

(8) If the cluster is created you will see an output similar to below
```
MySQL server started: [name] mysql-db-server [ip] 172.17.1.17 [container-id] 37ee1775dcae50eb765981a5785c196070ca2a853b622ffd23a36d5f931bb418
Dep Sync SVN server started: [name] dep-sync-svn [ip] 172.17.1.18 [container-id] 14f287adff2beb84672a9017ff2dff2c2f383cf54ae1fabff1c28c96ec348b27
ESB wka member started: [name] wso2esb-1-wka [ip] 172.17.1.19 [container-id] fca889413dbce0fb9ddbd453b077aa7f9be2a8e7934ac707677dd096f23deb20
ESB member started: [name] wso2esb-2 [ip] 172.17.1.20 [container-id] f42dab2d10dfac45d2343fe7b1e0874f3acf8f5d9b5466f7808d3c1ad4c21184
ESB member started: [name] wso2esb-3 [ip] 172.17.1.21 [container-id] 65a81d5ed987e3640dc57d547af05e9a3fed14f7d6a5fbe0173fe9bbe84aa1e8
```

(9) You can ssh to ESB containers using following command. The default password will be 'wso2'.
```
ssh root@172.17.1.19
```

(10) To stop and delete the containers you can run stop.sh and delete.sh scripts in order.


