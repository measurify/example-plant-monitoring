### Design and implementation of an embedded system for remote monitoring of plants and flowers

## Overview

#The goal of this thesis is the design and implementation of an embedded system for monitoring
remote of plants and flowers. Using a brightness sensor, SparkFun TSL2561,
an air humidity and temperature sensor, DHT22 Pro v1.3, and a capacitive moisture sensor
of the land, DFRobot SEN0193. Furthermore, there is also an Arduino TFT to show information,
locally, of the last measurement. All the previously mentioned components interface with
a microcontroller, Arduino Uno Wifi Rev 2, which takes care of data acquisition and sending of
themselves on a cloud. Communication with the latter is carried out through APIs issued by
a framework called Measurify. It acts as an interface between the detection system and the application
for smartphone. The latter, which was developed with Flutter, allows you to monitor the flowers in
remote and enter the parameters to set the system according to the user's needs. Monitoring
from smartphone it allows, through graphs, to view all the data in three modes: daily, monthly
and yearly.