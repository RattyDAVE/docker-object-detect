

##docker run -it --name camera_go -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --device /dev/video0 tensorflow/tensorflow:latest-py3 bash

##xhost +
##docker exec -it camera_go bash

FROM tensorflow/tensorflow:latest-py3

RUN apt update -y && \ 
  apt install -y git protobuf-compiler wget python3-opencv python-opencv python3-matplotlib && \ 
  mkdir ~/tensorflow1 && \ 
  cd ~/tensorflow1 && \ 
  git clone --recurse-submodules https://github.com/tensorflow/models.git && \ 
  cd ~/tensorflow1/models/research && \ 
  protoc object_detection/protos/*.proto --python_out=. && \ 
  cd ~/tensorflow1/models/research/object_detection && \ 
  wget http://download.tensorflow.org/models/object_detection/ssdlite_mobilenet_v2_coco_2018_05_09.tar.gz && tar -xzvf ssdlite_mobilenet_v2_coco_2018_05_09.tar.gz && \ 
  wget https://raw.githubusercontent.com/RattyDAVE/pi-object-detection/master/camera_on.py  && \
  wget https://raw.githubusercontent.com/RattyDAVE/pi-object-detection/master/obj-config.ini && \
  echo "#!/bin/bash" > /root/startup.sh && \
  echo "cd ~/tensorflow1/models/research/object_detection"  >> /root/startup.sh && \
  echo "export PYTHONPATH=$PYTHONPATH:~/tensorflow1/models/research:~/tensorflow1/models/research/slim"  >> /root/startup.sh && \
  echo "python3 camera_on.py" >> /root/startup.sh && \
  chmod 755 /root/startup.sh

CMD ["/bin/bash", "/root/startup.sh"]
