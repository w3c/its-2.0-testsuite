<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:my="http://example.com/myns" xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="my">

    <xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>
    <xsl:param name="output">html</xsl:param>
    <xsl:variable name="testsuiteLocation"/>
  <xsl:param name="inputDataPrefix">https://github.com/w3c/web-platform-tests/tree/master/conformance-checkers/html-its/</xsl:param>
    <xsl:variable name="its2spec"
        >http://www.w3.org/International/multilingualweb/lt/drafts/its20/its20.html</xsl:variable>
    <xsl:variable name="annotatedTestSuiteMaster">
        <xsl:apply-templates select="/" mode="annotateTestSuiteMaster"/>
    </xsl:variable>
    <xsl:variable name="implemeters" as="item()*">
        <xsl:for-each
            select="distinct-values(//my:outputImplementors/@implementer)[string-length()&gt;0]">
            <xsl:sort/>
            <xsl:value-of select="."/>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="datacategories" as="item()*">
        <xsl:for-each
            select="distinct-values(/my:testSuite/my:dataCategory/@name)[string-length()&gt;0]">
            <xsl:value-of select="."/>
        </xsl:for-each>
    </xsl:variable>
    <xsl:template match="@* | node()" mode="annotateTestSuiteMaster">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="annotateTestSuiteMaster"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template mode="annotateTestSuiteMaster" match="my:outputImplementors"
        xmlns="http://example.com/myns">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when
                    test="not(unparsed-text-available(concat($testsuiteLocation,preceding-sibling::my:expectedOutput/@location)))">
                    <error>referenceFileNotFound: <xsl:value-of
                            select="ancestor::my:inputfile/@location"/></error>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when
                            test="not(unparsed-text-available(concat($testsuiteLocation,@location)))">
                            <error>outputFileNotFound</error>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="implementersFileLines"
                                select="tokenize(unparsed-text(concat($testsuiteLocation,@location)), '\r?\n')"/>
                            <xsl:for-each
                                select="tokenize(unparsed-text(concat($testsuiteLocation,preceding-sibling::my:expectedOutput/@location)), '\r?\n')">
                                <xsl:variable name="position" select="position()"/>
                                <xsl:variable name="line" select="."/>
                                <xsl:if
                                    test="compare(replace($line,'\s+',''), replace($implementersFileLines[position()=$position],'\s+',''))!=0">
                                    <error><xsl:text>&#xA;Line </xsl:text><xsl:value-of
                                            select="$position"
                                            /><xsl:text>: Comparison failed.&#xA;* Reference line: </xsl:text>[<xsl:value-of
                                            select="$line"
                                            /><xsl:text>]&#xA;* Implementers file line:[</xsl:text><xsl:value-of
                                            select="$implementersFileLines[position()=$position]"/><xsl:text>]</xsl:text></error>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$output='xml'">
                <xsl:copy-of select="$annotatedTestSuiteMaster"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="htmlOutput"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="htmlOutput">
        <xsl:result-document>
          <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
            <html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
                <head>
                    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
                    <title>ITS 2.0 Test Suite Dashboard</title>
                    <style type="text/css">
                        table{
                            text-align:center;
                            empty-cells:show;
                        }
                        td.firstcolumn{
                            text-align:right;
                        }
                        *.fnf{
                            color:blue;
                        }
                        *.na{
                            color:grey;
                        }
                        *.ok{
                            color:green;
                        }
                        *.error{
                            color:red;
                        }
                        table.conformanceclasses{
                            text-align:left;
                            empty-cells:show;
                        }</style>
                </head>
                <body>
                    <h1>ITS 2.0 Test Suite Dashboard</h1>
                    <p>Version generated: <xsl:value-of select="current-dateTime()"/></p>
                    <h2 id="purpose">Purpose</h2>
                    <p>This document provides a summary of the ITS 2.0 Test Suite:</p>
                    <ul>
                        <li>
                            <a href="#tests-current-state-summary">Current state of tests
                                (summary)</a>
                        </li>
                        <li>
                            <a href="#conformance-classes-overview">Overview of conformance classes</a>
                        </li>
                        <li>
                            <a href="#tests-current-state-details">Current state of tests
                                (details)</a>
                        </li>
                        <li>
                            <a href="#tests-current-state-xml-dump">XML dump of current state</a>
                        </li>
                    </ul>
                    <xsl:call-template name="implementersVersusDatacategories"/>
                    <hr/>
                    <xsl:call-template name="conformance-classes-overview"/>
                    <hr/>
                    <xsl:call-template name="current-state-details"/>
                    <hr/>
                    <h2 id="tests-current-state-xml-dump">XML dump of current state</h2>
                    <p>For ease of debugging, <a href="testSuiteDashboard.xml"
                            >testSuiteDashboard.xml</a> is an XML dump of the current state of the
                        test suite.</p>
                    <xsl:result-document href="testSuiteDashboard.xml">
                        <xsl:copy-of select="$annotatedTestSuiteMaster"/>
                    </xsl:result-document>
                    <hr/>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    <xsl:template name="implementersVersusDatacategories">
        <h2 id="tests-current-state-summary">Current state of tests</h2>
        <xsl:variable name="referenceOutput"
            select="count($annotatedTestSuiteMaster/my:testSuite/my:dataCategory/my:inputfile)"/>
        <xsl:variable name="implementersTestsTotal"
            select="count($annotatedTestSuiteMaster/my:testSuite/my:dataCategory/my:inputfile/my:outputImplementors)"/>
        <xsl:variable name="testsWithErrors"
            select="count($annotatedTestSuiteMaster/my:testSuite/my:dataCategory/my:inputfile/my:outputImplementors[my:error])"/>
        <ul>
            <li>Total number of input and reference output files: <xsl:value-of
                    select="$referenceOutput"/></li>
            <li>Total number of tests from all implementers: <xsl:value-of
                    select="$implementersTestsTotal"/></li>
            <li>Current coverage: <xsl:value-of select="$implementersTestsTotal - $testsWithErrors"
                /> tests successfully run (<xsl:value-of
                    select="round((($implementersTestsTotal - $testsWithErrors) div $implementersTestsTotal)*100)"
                />%).</li>
        </ul>
        <p>The following table compares actual tests run, versus number of tests to be run per
            implementer. Explanation:</p>
        <ul>
            <li><q class="na">N/A</q> = the implementer did not commit to run the tests for a given
                data category.</li>
            <li><q class="ok">OK</q> = for a given data category, all output files are identical to
                the reference output files.</li>
            <li><q class="error">error</q> = for a given data category an error occurred in one or
                several output files, or one or more output files are missing.</li>
        </ul>
        <table border="1" width="100%">
            <tr>
                <td>-</td>
                <xsl:for-each select="$implemeters">
                    <td>
                        <xsl:value-of select="."/>
                    </td>
                </xsl:for-each>
            </tr>
            <xsl:for-each select="$datacategories">
                <xsl:variable name="currentDatacat" select="."/>
                <tr>
                    <td class="firstcolumn">
                        <a href="{concat('#',replace(.,'[\s+,+]',''))}">
                            <xsl:value-of select="."/>
                        </a>
                    </td>
                    <xsl:for-each select="$implemeters">
                        <xsl:variable name="currentImplementer" select="."/>
                        <xsl:variable name="numberOfFiles"
                            select="count($annotatedTestSuiteMaster/my:testSuite/my:dataCategory[@name=$currentDatacat]/my:inputfile/my:outputImplementors[@implementer=$currentImplementer])"/>
                        <xsl:variable name="numberOfFilesSuccessfullyRun"
                            select="count($annotatedTestSuiteMaster/my:testSuite/my:dataCategory[@name=$currentDatacat]/my:inputfile/my:outputImplementors[@implementer=$currentImplementer][not(my:error)])"/>
                        <td>
                            <xsl:choose>
                                <xsl:when test="$numberOfFiles = 0">
                                    <span class="na">n/a</span>
                                </xsl:when>
                                <xsl:when test="$numberOfFilesSuccessfullyRun &lt; $numberOfFiles">
                                    <span class="error">
                                        <xsl:value-of
                                            select="concat($numberOfFilesSuccessfullyRun, '/',$numberOfFiles)"
                                        />
                                    </span>
                                </xsl:when>
                                <xsl:when test="$numberOfFilesSuccessfullyRun = $numberOfFiles">
                                    <span class="ok">
                                        <xsl:value-of
                                            select="concat($numberOfFilesSuccessfullyRun, '/',$numberOfFiles)"
                                        />
                                    </span>
                                </xsl:when>
                            </xsl:choose>
                        </td>
                    </xsl:for-each>
                </tr>
            </xsl:for-each>
            <tr>
                <td class="firstcolumn">Total number of files</td>
                <xsl:for-each select="$implemeters">
                    <xsl:variable name="currentImplementer" select="."/>
                    <xsl:variable name="numberOfFiles"
                        select="count($annotatedTestSuiteMaster/my:testSuite/my:dataCategory/my:inputfile/my:outputImplementors[@implementer=$currentImplementer])"/>
                    <xsl:variable name="numberOfFilesSuccessfullyRun"
                        select="count($annotatedTestSuiteMaster/my:testSuite/my:dataCategory/my:inputfile/my:outputImplementors[@implementer=$currentImplementer][not(my:error)])"/>
                    <td>
                        <xsl:value-of
                            select="concat($numberOfFilesSuccessfullyRun, '/',$numberOfFiles)"/>
                    </td>
                </xsl:for-each>
            </tr>
        </table>
    </xsl:template>
    <xsl:function name="my:countConformingImplementations" as="item()*">
        <xsl:param name="conformanceClassTests"/>
        <xsl:variable name="implementationsPerConformanceClass">
            <my:isGood>
                <xsl:for-each
                    select="distinct-values($conformanceClassTests/my:outputImplementors/@implementer)">
                    <xsl:variable name="currentImplementer" select="."/>
                    <xsl:variable name="relatedTests"
                        select="$conformanceClassTests/my:outputImplementors[@implementer=$currentImplementer]"/>
                    <xsl:if
                        test="not($relatedTests/my:error) and count($relatedTests) = count($conformanceClassTests)">
                        <my:ok/>
                    </xsl:if>
                </xsl:for-each>
            </my:isGood>
        </xsl:variable>
        <xsl:value-of select="count($implementationsPerConformanceClass/my:isGood/my:ok)"/>
    </xsl:function>
    <xsl:template name="writeConformanceInfo">
        <xsl:variable name="currentInputFile" select="."/>
        <xsl:variable name="currentInputFileName"
            select="tokenize($currentInputFile/@location,'/')[last()]"/>
        <a href="{concat('#t-',substring-before($currentInputFileName,'.'))}">
            <xsl:value-of select="substring-before($currentInputFileName,'.')"/>
        </a>
    </xsl:template>
    <xsl:template name="conformance-classes-overview">
        <h2 id="conformance-classes-overview">Overview of conformance classes</h2>
        <p>The ITS 2.0 specification provides four types of processor conformance: processing XML <a href="http://www.w3.org/TR/its20/#its-conformance-2-1-1">global or local</a>, and processing HTML <a href="http://www.w3.org/TR/its20/#its-conformance-3-1-1">global or local</a>. The tables below summarize the implementation status with regards to these conformance classes. <strong>Note:</strong> not each data category implements both local and local processing. See the <a href="http://www.w3.org/TR/its20/#datacategories-overview">data category overview table</a> for details.</p>
        <xsl:for-each select="$datacategories">
            <xsl:variable name="currentDatacat" select="."/>
            <p><strong><xsl:value-of select="."/></strong></p>
            <xsl:variable name="xml-global"
                select="$annotatedTestSuiteMaster/my:testSuite/my:dataCategory[@name=$currentDatacat]/my:inputfile[contains(@conformance-class,'xml-global')]"/>
            <xsl:variable name="xml-local"
                select="$annotatedTestSuiteMaster/my:testSuite/my:dataCategory[@name=$currentDatacat]/my:inputfile[contains(@conformance-class,'xml-local')]"/>
            <xsl:variable name="html-global"
                select="$annotatedTestSuiteMaster/my:testSuite/my:dataCategory[@name=$currentDatacat]/my:inputfile[contains(@conformance-class,'html-global')]"/>
            <xsl:variable name="html-local"
                select="$annotatedTestSuiteMaster/my:testSuite/my:dataCategory[@name=$currentDatacat]/my:inputfile[contains(@conformance-class,'html-local')]"/>
            <table width="100%" border="1" class="conformanceclasses">
                <tr>
                    <td>
                        <strong>Conformance class</strong>
                    </td>
                    <td>
                        <strong>Conforming<br/>implementations</strong>
                    </td>
                    <td>
                        <strong>Test files</strong>
                    </td>
                </tr>
                <xsl:if test="$xml-global">
                    <tr>
                        <td>XML Global</td>
                        <td>
                            <xsl:value-of select="my:countConformingImplementations($xml-global)"/>
                        </td>
                        <td>
                            <xsl:for-each select="$xml-global">
                                <xsl:call-template name="writeConformanceInfo"/>
                            </xsl:for-each>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="$xml-local">
                    <tr>
                        <td>XML Local</td>
                        <td>
                            <xsl:value-of select="my:countConformingImplementations($xml-local)"/>
                        </td>
                        <td>
                            <xsl:for-each select="$xml-local">
                                <xsl:call-template name="writeConformanceInfo"/>
                            </xsl:for-each>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="$html-global">
                    <tr>
                        <td>HTML Global</td>
                        <td>
                            <xsl:value-of select="my:countConformingImplementations($html-global)"/>
                        </td>
                        <td>
                            <xsl:for-each select="$html-global">
                                <xsl:call-template name="writeConformanceInfo"/>
                            </xsl:for-each>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="$html-local">
                    <tr>
                        <td>HTML Local</td>
                        <td>
                            <xsl:value-of select="my:countConformingImplementations($html-local)"/>
                        </td>
                        <td>
                            <xsl:for-each select="$html-local">
                                <xsl:call-template name="writeConformanceInfo"/>
                            </xsl:for-each>
                        </td>
                    </tr>
                </xsl:if>
            </table>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="current-state-details">
        <h2 id="tests-current-state-details">Details of current state</h2>
        <p>Explanation:</p>
        <ul>
            <li><q class="na">N/A</q> = the implementer did not commit to run the test.</li>
            <li><q class="ok">OK</q> = the output file is identical to the reference output
                file.</li>
            <li><q class="error">error</q> = an error occurred, e.g. the output file is not
                available or it is not identical to the reference output file. Move the mouse over
                    <q>error</q> to see details.</li>
            <li><q class="fnf">fnf</q>: the output file from the implementer has not been
                found.</li>
        </ul>
        <xsl:for-each select="$datacategories">
            <xsl:variable name="currentDatacat" select="."/>
            <h3 id="{replace(.,'[\s+,+]','')}">
                <xsl:value-of select="."/>
            </h3>
            <p>Detailed overview:</p>
            <table border="1" width="100%">
                <tr>
                    <td>-</td>
                    <xsl:for-each select="$implemeters">
                        <td>
                            <xsl:value-of select="."/>
                        </td>
                    </xsl:for-each>
                </tr>
                <xsl:for-each
                    select="$annotatedTestSuiteMaster/my:testSuite/my:dataCategory[@name=$currentDatacat]/my:inputfile">
                    <xsl:variable name="currentInputFile" select="."/>
                    <xsl:variable name="currentInputFileName"
                        select="tokenize($currentInputFile/@location,'/')[last()]"/>
                    <tr>
                        <td>
                          <a target="_blank" href="{concat($inputDataPrefix,substring-after($currentInputFile/@location,'inputdata/'))}"
                                id="{concat('t-',substring-before($currentInputFileName,'.'))}">
                                <xsl:value-of select="$currentInputFileName"/>
                            </a>
                            <br/>
                            <xsl:value-of select="$currentInputFile/my:description"/>
                            <br/>
                            <xsl:if test="$currentInputFile/my:description/@assertions">
                                (assertions: <xsl:for-each
                                    select="tokenize($currentInputFile/my:description/@assertions,'\s+')">
                                    <xsl:variable name="no" select="position()"/>
                                    <a target="_blank" href="{concat($its2spec,'#',.)}"
                                            >[<xsl:value-of select="$no"/>]</a>
                                </xsl:for-each>) </xsl:if>
                            <a target="_blank"
                                href="{$currentInputFile/my:expectedOutput/@location}"
                                >(expected)</a>
                        </td>
                        <xsl:for-each select="$implemeters">
                            <xsl:variable name="currentImplementer" select="."/>
                            <td>
                                <xsl:choose>
                                    <xsl:when
                                        test="not($currentInputFile/my:outputImplementors[@implementer=$currentImplementer]/@location)">
                                        <span class="na">N/A</span>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:choose>
                                            <xsl:when
                                                test="$currentInputFile/my:outputImplementors[@implementer=$currentImplementer]/my:error">
                                                <xsl:variable name="errorList">
                                                  <xsl:for-each
                                                  select="$currentInputFile/my:outputImplementors[@implementer=$currentImplementer]/my:error">
                                                  <xsl:value-of select="."/>
                                                  </xsl:for-each>
                                                </xsl:variable>
                                                <xsl:choose>
                                                  <xsl:when
                                                  test="contains($errorList,'outputFileNotFound')">
                                                  <span class="fnf" title="file not found"
                                                  >fnf</span>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <span title="{$errorList}" class="error"
                                                  >error</span>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <span class="ok">OK</span>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </xsl:for-each>
                    </tr>
                </xsl:for-each>
            </table>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
