Validating Input Test Files
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
 
Validating Output Test Files
=================
To validate test suite output files simply compile the test suite dashboard (this will only work if you have java installed and saxon downloaded):

* Download saxon.jar from here: https://dl.dropbox.com/u/65779171/saxon.jar
* Then use this command (Linux/Mac/Windows):
  java -jar /path/of/file/saxon.jar  testsuiteMaster.xml  testsuiteDashboard.xsl -o:testSuiteDashboard.html
* Check the state of your files in the related data categories on this web page:
  http://htmlpreview.github.com/?https://raw.github.com/finnle/ITS-2.0-Testsuite/master/its2.0/testSuiteDashboard.html

Explanations of states :
* N/A = the implementer did not commit to run the test.
* OK = the output file is identical to the reference output file.
* error = an error occurred, e.g. the output file is not available or it is not identical to the reference output file. Move the mouse over error to see details.
* fnf: the output file from the implementer has not been found.



