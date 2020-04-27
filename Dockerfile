#FROM tensorflow/tensorflow:latest-py3
FROM tensorflow/tensorflow:1.15.2-py3 

ENV DEBIAN_FRONTEND noninteractive

RUN apt update -y && \ 
  apt install -yqq git protobuf-compiler wget python3-opencv python-opencv python3-matplotlib && \ 
  apt-get -y autoclean && apt-get -y autoremove && \
  apt-get -y purge $(dpkg --get-selections | grep deinstall | sed s/deinstall//g) && \
  rm -rf /var/lib/apt/lists/* /tmp/*

RUN mkdir ~/tensorflow1 && \ 
  cd ~/tensorflow1 && \ 
  git clone --recurse-submodules https://github.com/tensorflow/models.git && \ 
  cd ~/tensorflow1/models/research && \ 
  protoc object_detection/protos/*.proto --python_out=.
  
RUN  cd ~/tensorflow1/models/research/object_detection && \ 
  wget http://download.tensorflow.org/models/object_detection/ssdlite_mobilenet_v2_coco_2018_05_09.tar.gz && tar -xzvf ssdlite_mobilenet_v2_coco_2018_05_09.tar.gz

#wget https://raw.githubusercontent.com/RattyDAVE/pi-object-detection/master/camera_on.py  && \
#wget https://raw.githubusercontent.com/RattyDAVE/pi-object-detection/master/obj-config.ini && \
  
RUN echo "#!/bin/bash" > /root/startup.sh && \
  echo "cd ~/tensorflow1/models/research/object_detection"  >> /root/startup.sh && \
  echo "export PYTHONPATH=$PYTHONPATH:~/tensorflow1/models/research:~/tensorflow1/models/research/slim"  >> /root/startup.sh && \
  echo "python3 camera_on.py" >> /root/startup.sh && \
  chmod 755 /root/startup.sh

ADD camera_on.py ~/tensorflow1/models/research/object_detection
ADD obj-config.ini ~/tensorflow1/models/research/object_detection
ADD download.sh ~/tensorflow1/models/research/object_detection

# RUN chmod 755 ~/tensorflow1/models/research/object_detection/download.sh

CMD ["/bin/bash", "/root/startup.sh"]
