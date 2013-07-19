Validating NIF conversion output files
=================
Validating one file
-------------------------

* In the sparqltests directory, run 'java -jar validate.jar -i filepath'

* 'filepath' is the path to the file

* Example: 'java -jar validate.jar ../expected/locqualityissue-nif-1.ttl'

Validating a complete directory
--------------------------

* In the sparqltests directory, run '/executeTests.sh directorypath'

* 'directorypath' is the path to the file

* Example: './executeTests.sh ../expected/'

More information
-------------------------

* validate.jar contains sparql queries that test constraints in the RDF representation and APACHE jena to run the queries

* Documentation is available here https://github.com/NLP2RDF/java-maven#nif-validator

* The latest validate.jar is available here https://github.com/NLP2RDF/java-maven/blob/master/validate.jar