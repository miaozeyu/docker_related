#!/bin/bash

#Docker:

#Install docker
cat /proc/version
sudo yum remove docker docker-common docker-selinux docker-engine
sudo yum install -y yum-utils device-mapper-persistent-data lvm2 #-> include yum-config-manager which allows to add/enable yum repos; rest used for devicemapper storage driver
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo #-> use yum-config-manager to add the docker repo
sudo yum install docker-ce #-> install docker engine 

sudo systemctl start docker #-> start up docker daemon
sudo systemctl status docker #-> verify daemon is running
sudo docker run hello-world

#Create & Run container
docker run -it ubuntu /bin/bash #-> Run/start/create a container as Interactive shell
docker images 
docker ps    # -> List containers (default show just running) -a includes stopped
ls -asl /var/lib/docker
ls /var/lib/docker/image/overlay2/imagedb/content/sha256   #-> image files
cat 3556258649b2ef23a41812be17377d32f568ed9f45150a26466d2ea26d926c32 | python -m json.tool
docker inspect ubuntu   #-> Check image details
docker start container_name #-> start existing container
docker attach container_name #-> reattach to running container and start shell (only works if container was started with -it /)
Ctrl-P + Ctrl-Q #-> detach without stopping container 
docker container prune #-> Remove all stopped containers!




#Build Image from Dockerfile 
docker build . #-> Build an image from a Dockerfile in the current dir
docker rmi docker-image-id #-> Remove an image
docker build -t MyImageName #-> Build and tag an image 

#Build Image from Container
docker rm container-id -> Remove a container 
docker commit --change='CMD ["python", "-c", "import this"]' 18f2b0c23c32 ubuntu_python #-> Commit change to container and build a new image from the container-id and tag the new image with name

#Best practices:
#1. keep the image as small as possible
#2. use official public images as base images
#3. ensure images to have one purpose
#4. reduce the number of layers




#--- Port Mapping (container port to host port)
docker run -d webapp #-> -d detaches Docker from I/O and runs the container in background
curl 172.17.0.4:8080
docker run -d -P webapp #-> uppercase -P flag binds the container port to an available port on local host dynamically 
curl localhost:32270
docker run -d -p 3000:8080 webapp  #-> lowercase -p flag allow you to explicitly specify the port on host you want to use: e.g. use 3000 on local host and bind the container port 8080 to it
curl localhost:3000
lynx localhost:3000 #-> terminal based browser to view webpage



#--- Networking:
#[Bridge a.k.a local/default]
docker network ls
ip addr show
ifconfig eth0
docker exec -it container-name /bin/bash  #-> Run bash shell in an existing container
arp-scan --interface=eth0 --localnet #-> Show ip of default gateway and containers in local network

#[Host network]
docker run -d --network=host ubuntu_networking /webapp #-> Run app on host network: container doesn't get its own IP addr
curl localhost:8080 #-> This will display the webpage even tho we didn't publish/expose ports manually

#[None network] -> No network, cannot ping google.com: container is completely isolated
docker run -it --network=none ubuntu_networking
ip addr show -> It shows no eth0




#--- Storage
#1. Bind mount -> Not decoupled from host; but provide container with direct access to new project source code located on host
#2. Volumes (Preferred way) - Bind mounts managed by Docker on host so you don't need to know the fully qualified path to a file/directory
         - local host file system
         - external drivers: S3, Google cloud storage ... 
#3. In-Memory Storage (tmpfs) -> Not persistent, files accessible through lifetime of the running container; used to host sensitive info like access token

#bind amount
docker build -t "scratch_volume" .
docker run -d --mount type="bind",src="/var/demo/logs", dst="/logs" scratch_volume
tail -n 30 /var/demo/logs/myapp
cat /var/demo/logs/myapp | cut -d " " -f 2 | sort | uniq
docker volume ls #-> Zero result if using bind amount

#volumes (Managed by docker)
docker run -d --mount type=volume,src="logs", dst=/logs image-name
docker volume inspect logs
tail -F -s1 /var/lib/docker/volumes/logs/_data/myapp.  #-> out put the results as they are updated
cat /var/lib/docker/volumes/logs/_data/myapp | cut -d " " -f 2 | sort | uniq
docker ps -aq | sort #-> List only the container ids

#tmpfs (Temporary file storage - available only while container is running)
docker run -it --mount type=tmpfs,dst=/logs ubuntu




#--- Tag
docker tag tag_demo:latest tag_demo:v1
docker run image-name #-> it always runs the image with a tag of latest 
docker login
docker tag tag_demo:latest miaozeyu/tag_demo:latest
docker push miaozeyu/tag_demo:latest #-> Push to docker hub
