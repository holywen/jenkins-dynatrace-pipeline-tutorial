IMAGENAME=$1
docker ps | grep ${IMAGENAME} | awk '{print $1 }' | xargs -I {} docker stop {}
docker rm -f $(docker ps -a -q)
docker ps -a | awk '{ print $1,$2 }' | grep ${IMAGENAME} | awk '{print $1 }' | xargs -I {} docker rm {}