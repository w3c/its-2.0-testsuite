ITS-2.0-Testsuite
=================

Validating XML test files
-------------------------

* Download and install Ant from http://ant.apache.org/

* Run 'ant validate-xml' command in its2.0 directory

Validating HTML test files
--------------------------

* Download and install Ant from http://ant.apache.org/

* Download html5-its-tools from https://github.com/kosek/html5-its-tools

* Modify its2.0/build.properties to point to your local copy of html5-its-tools

* Run 'ant validate-html' command in its2.0 directory

Validating all test files
-------------------------

* Make sure that XML and HTML validation described above works for you

* Run 'ant' command in its2.0 directory

* Please note that HTML schema doesn't supports RDFa so RDFa attributes are reported as errors

* Please note that currently Schematron validation is not performed so some errors are not detected

