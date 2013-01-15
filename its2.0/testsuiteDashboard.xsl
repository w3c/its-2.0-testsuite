<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:my="http://example.com/myns" xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="my">

    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
    <xsl:param name="output">html</xsl:param>
    <xsl:variable name="testsuiteLocation"></xsl:variable>
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
                        <xsl:when test="not(unparsed-text-available(concat($testsuiteLocation,@location)))">
                            <error>outputFileNotFound</error>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="referenceFileLines"
                                select="tokenize(unparsed-text(concat($testsuiteLocation,preceding-sibling::my:expectedOutput/@location)), '\r?\n')"/>
                            <xsl:for-each select="tokenize(unparsed-text(concat($testsuiteLocation,@location)), '\r?\n')">
                                <xsl:variable name="position" select="position()"/>
                                <xsl:variable name="line" select="."/>
                                <xsl:if
                                    test="string-length(replace($line,'\s+','')) != string-length(replace($referenceFileLines[position()=$position],'\s+',''))">
                                    <error><xsl:text>&#xA;Line </xsl:text><xsl:value-of
                                            select="$position"
                                            /><xsl:text>: Comparison failed.&#xA;* Reference line: </xsl:text>[<xsl:value-of
                                            select="$referenceFileLines[position()=$position]"
                                            /><xsl:text>]&#xA;* Implementers file line:[</xsl:text><xsl:value-of
                                            select="$line"/><xsl:text>]</xsl:text></error>
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
        <xsl:result-document doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
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
                    *.fnf { color: blue;}
                    *.na { color: grey; }
                    *.ok { color: green;}
                    *.error { color: red; }</style>
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
                            <a href="#tests-current-state-details">Current state of tests
                                (details)</a>
                        </li>
                        <li>
                            <a href="#tests-current-state-xml-dump">XML dump of current state</a>
                        </li>
                    </ul>
                    <xsl:call-template name="implementersVersusDatacategories"/>
                    <xsl:call-template name="current-state-details"/>
                    <h2 id="tests-current-state-xml-dump">XML dump of current state</h2>
                    <p>For ease of debugging, <a href="testSuiteDashboard.xml"
                            >testSuiteDashboard.xml</a> is an XML dump of the current state of the
                        test suite.</p>
                    <xsl:result-document href="testSuiteDashboard.xml">
                        <xsl:copy-of select="$annotatedTestSuiteMaster"/>
                    </xsl:result-document>
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
            implementer</p>
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
                            <xsl:value-of
                                select="concat($numberOfFilesSuccessfullyRun, '/',$numberOfFiles)"/>
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
    <xsl:template name="current-state-details">
        <h2 id="tests-current-state-details">Details of current state</h2>
        <p>Explanation:</p>
        <ul>
            <li><q class="na">N/A</q> = the implementer did not commit to run the test.</li>
            <li><q class="ok">OK</q> = the output file is identical to the reference output file.</li>
            <li><q class="error">error</q> = an error occurred, e.g. the output file is not available or it is not
                identical to the reference output file. Move the mouse over <q>error</q> to see
                details.</li>
            <li><q class="fnf">fileNotFound</q>: the output file from the implementer has not been found.</li>
        </ul>
        <xsl:for-each select="$datacategories">
            <xsl:variable name="currentDatacat" select="."/>
            <h3 id="{replace(.,'[\s+,+]','')}">
                <xsl:value-of select="."/>
            </h3>
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
                            <a href="{$currentInputFile/@location}"><xsl:value-of select="$currentInputFileName"/></a>
                            <br/>
                            <xsl:value-of select="$currentInputFile/my:description"/>
                            <br/>
                            <a href="{$currentInputFile/my:expectedOutput/@location}">(expected)</a>
                        </td>
                        <xsl:for-each select="$implemeters">
                            <xsl:variable name="currentImplementer" select="."/>
                            <td>
                                <xsl:choose>
                                    <xsl:when
                                        test="not($currentInputFile/my:outputImplementors[@implementer=$currentImplementer]/@location)"
                                        ><span class="na">N/A</span></xsl:when>
                                    <xsl:otherwise>
                                        <xsl:choose>
                                            <xsl:when
                                                test="$currentInputFile/my:outputImplementors[@implementer=$currentImplementer]/my:error">
                                                <xsl:variable name="errorList">
                                                  <xsl:for-each
                                                  select="$currentInputFile/my:outputImplementors[@implementer=$currentImplementer]/my:error">
                                                  <xsl:number count="."/>
                                                  <xsl:value-of select="."/>
                                                  </xsl:for-each>
                                                </xsl:variable>
                                                <xsl:choose>
                                                    <xsl:when test="contains($errorList,'outputFileNotFound')"><span class="fnf">fileNotFound</span></xsl:when>
                                                  <xsl:otherwise>
                                                  <span title="{$errorList}" class="error">error</span>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:when>
                                            <xsl:otherwise><span class="ok">OK</span></xsl:otherwise>
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
