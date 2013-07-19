#!/bin/sh
# All tests require validate.jar
echo "Folder with the produced .ttl files: $1" 
for i in `ls $1` ; do echo "checking $1$i"; java -jar validate.jar -i $1$i ; done
