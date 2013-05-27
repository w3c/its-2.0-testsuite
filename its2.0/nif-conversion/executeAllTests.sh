#!/bin/sh
# helper script for convenience
QUERIES="beginEndIndexAreNonNegativeInteger.sparql contextTypedAsRFC5147String.sparql hasReferenceContext.sparql noNodesWithoutITSRDFAnnotation.sparql contextHasIsString.sparql hasBeginEndIndex.sparql isStringLength.sparql" 
for i in $QUERIES
do 
	echo "Running: $i" 
	./executeOneTest.sh expected $i | grep -C5 'http' 
	echo "Done: $i" 
done


