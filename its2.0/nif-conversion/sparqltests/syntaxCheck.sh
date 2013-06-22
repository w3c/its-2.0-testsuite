#!/bin/sh
# All tests require a SPARQL 1.1 engine
# This script requires Apache Jena as CLI: http://jena.apache.org/documentation/query/cmds.html
# Note: tests have not been tested with another engine, some used SPARQL features might be Jena Engine specific
# adapt:
JENAROOT=apache-jena-2.10.1

# execute by calling $JENAROOT/bin/arq
echo "Folder with the produced .ttl files (parameter 1): $1" 
echo "JENAROOT: $JENAROOT"
for i in `ls $1` ; do echo "Checking "$i":" ; $JENAROOT/bin/riot --validate $1/$i ; done

