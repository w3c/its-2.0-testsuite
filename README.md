Internationalization Tag Set (ITS) 2.0 Test Suite
=================

This is the Internationalization Tag Set (ITS) 2.0 http://www.w3.org/TR/its20/ test suite. ITS 2.0 and this test suite have been developed by participants of the W3C MultilingualWeb-LT Working Group http://www.w3.org/International/multilingualweb/lt/ . Please provide comments on ITS 2.0 and the test suite on the ITS Interest Group mailing list http://lists.w3.org/Archives/Public/public-i18n-its-ig/

Further information about the test suite is available in [test-suite-howto.html](its2.0/test-suite-howto.html) (also avail. as [PDF](its2.0/test-suite-howto.pdf)) in this directory and in the [nif-conversion](its2.0/nif-conversion) subdirectory.

Licensing Information
=================

The following files are available under the W3C Test Suite License http://www.w3.org/Consortium/Legal/2008/04-testsuite-license.html

* Input files, expected output files and implementers output files in the directories inputdata, expected and outputimplementers under https://github.com/finnle/ITS-2.0-Testsuite/tree/master/its2.0/

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

* Download saxon.jar from here: http://saxon.sourceforge.net/
* Then use this command (Linux/Mac/Windows): 
  java -jar /path/of/file/saxon.jar  testsuiteMaster.xml  testsuiteDashboard.xsl -o:testSuiteDashboard.html
* Upload newly compiled testsuiteDashboard.html to the git hub
* Check the state of your files in the related data categories on this web page:
  http://htmlpreview.github.io/?https://raw.github.com/w3c/its-2.0-testsuite/blob/master/its2.0/testSuiteDashboard.html

Explanations of states :
* N/A = the implementer did not commit to run the test.
* OK = the output file is identical to the reference output file.
* error = an error occurred, e.g. the output file is not available or it is not identical to the reference output file. Move the mouse over error to see details.
* fnf: the output file from the implementer has not been found.

Validating NIF output files
---------------------------
Note: The conversion to NIF is not a normative part of the ITS 2.0 specification.
Prerequisites: Java and Unix Shell
* create a temporary folder for output files (hence called $datafolder)
* read ITS files from "its2.0/nif-conversion/input/" one by one, convert to NIF and write output files in turtle to $datafolder
* go to directory 
  cd its2.0/nif-conversion/sparqltest
* run :
  ./executeTests.sh ../relative/pathTo/$datafolder
  
Explanations of output:
* If no message appears between "Running: test1.sparql" and "Done: test1.sparql" the test was successfull. 
* Otherwise the output filename and additional debug output is shown.
