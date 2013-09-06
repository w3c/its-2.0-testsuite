<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:my="http://example.com/myns" xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="my">

    <xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>
    <xsl:param name="output">html</xsl:param>
  <xsl:param name="testSuiteMainPage">https://github.com/w3c/its-2.0-testsuite/</xsl:param>
    <xsl:param name="testSuiteFilesLinksPrefix"
      >https://github.com/w3c/its-2.0-testsuite/tree/master/its2.0/</xsl:param>
  <xsl:param name="inputDataPrefix">https://github.com/w3c/web-platform-tests/tree/master/conformance-checkers/html-its/</xsl:param>
    <xsl:variable name="testsuiteLocation"/>
    <xsl:variable name="its2spec">http://www.w3.org/TR/its20/</xsl:variable>
    <xsl:variable name="annotatedTestSuiteMasterWithAllTests">
        <xsl:apply-templates select="/" mode="annotateTestSuiteMaster"/>
    </xsl:variable>
    <xsl:variable name="annotatedTestSuiteMaster">
        <xsl:apply-templates select="$annotatedTestSuiteMasterWithAllTests"
            mode="stripNotConformanceClassRelevantTest"/>
    </xsl:variable>
    <xsl:template mode="stripNotConformanceClassRelevantTest" match="node() |@*">
        <xsl:copy>
            <xsl:apply-templates select="node() |@*" mode="stripNotConformanceClassRelevantTest"/>
        </xsl:copy>
    </xsl:template>
    <xsl:function name="my:stripTestsPerDataCategory" as="item()*">
        <xsl:param name="currentSetOftTests"/>
        <xsl:for-each select="$currentSetOftTests">
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:copy-of select="my:description | my:expectedOutput"/>
                <xsl:for-each select="my:outputImplementors">
                    <xsl:variable name="currentImplementer" select="@implementer"/>
                    <xsl:variable name="relatedTests"
                        select="$currentSetOftTests/my:outputImplementors[@implementer=$currentImplementer]"/>
                    <xsl:if
                        test="not($relatedTests/my:error) and count($relatedTests) = count($currentSetOftTests)">
                        <xsl:copy-of select="self::*"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:copy>
        </xsl:for-each>
    </xsl:function>
    <xsl:template mode="stripNotConformanceClassRelevantTest" match="my:dataCategory">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of
                select="my:stripTestsPerDataCategory(my:inputfile[contains(@conformance-class,'xml-global')])"/>
            <xsl:copy-of
                select="my:stripTestsPerDataCategory(my:inputfile[contains(@conformance-class,'xml-local')])"/>
            <xsl:copy-of
                select="my:stripTestsPerDataCategory(my:inputfile[contains(@conformance-class,'html-global')])"/>
            <xsl:copy-of
                select="my:stripTestsPerDataCategory(my:inputfile[contains(@conformance-class,'html-local')])"
            />
        </xsl:copy>
    </xsl:template>
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
                                            select="$implementersFileLines[position()=$position]"
                                        /><xsl:text>]</xsl:text></error>
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
                    <title>ITS 2.0 Implementation Report</title>
                    <link rel="stylesheet" type="text/css"
                        href="http://www.w3.org/StyleSheets/base.css"/>
                    <style type="text/css">
                        *.toc { list-style: none;}
                        table{
                            text-align:center;
                            empty-cells:show;
                            width:100%;
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
                            body { 
                            background: #FBFBFF;
                            color: black;
                            margin: 1em 5% 1em 10%
                            }   
                        }</style>
                    <!-- Below is mostly copied from xxx -->
                    <style type="text/css">
                        body{
                            padding:2em 1em 2em 70px;
                            margin:0;
                            font-family:sans-serif;
                            color:black;
                            background:white;
                            background-position:top left;
                            background-attachment:fixed;
                            background-repeat:no-repeat;
                        }
                        :link{
                            color:#00C;
                            background:transparent
                        }
                        :visited{
                            color:#609;
                            background:transparent
                        }
                        a:active{
                            color:#C00;
                            background:transparent
                        }
                        a:link img,
                        a:visited img{
                            border-style:none
                        } /* no border on img links */
                        a img{
                            color:white;
                        } /* trick to hide the border in Netscape 4 */
                        @media all{ /* hide the next rule from Netscape 4 */
                            a img{
                                color:inherit;
                            } /* undo the color change above */
                        }
                        th,
                        td{ /* ns 4 */
                            font-family:sans-serif;
                        }
                        h1,
                        h2,
                        h3,
                        h4,
                        h5,
                        h6{
                            text-align:left
                        }
                        /* background should be transparent, but WebTV has a bug */
                        h1,
                        h2,
                        h3{
                            color:#005A9C;
                            background:white
                        }
                        h1{
                            font:170% sans-serif
                        }
                        h2{
                            font:140% sans-serif
                        }
                        h3{
                            font:120% sans-serif
                        }
                        h4{
                            font:bold 100% sans-serif
                        }
                        h5{
                            font:italic 100% sans-serif
                        }
                        h6{
                            font:small-caps 100% sans-serif
                        }
                        .hide{
                            display:none
                        }
                        div.head{
                            margin-bottom:1em
                        }
                        div.head h1{
                            margin-top:2em;
                            clear:both
                        }
                        div.head table{
                            margin-left:2em;
                            margin-top:2em
                        }
                        p.copyright{
                            font-size:small
                        }
                        p.copyright small{
                            font-size:small
                        }
                        @media screen{ /* hide from IE3 */
                            a[href]:hover{
                                background:#ffa
                            }
                        }
                        pre{
                            margin-left:2em
                        }
                        /*
                        p {
                        margin-top: 0.6em;
                        margin-bottom: 0.6em;
                        }
                        */
                        dt,
                        dd{
                            margin-top:0;
                            margin-bottom:0
                        } /* opera 3.50 */
                        dt{
                            font-weight:bold
                        }
                        ul.toc,
                        ol.toc{
                            list-style:disc; /* Mac NS has problem with 'none' */
                            list-style:none;
                        }
                        @media aural{
                            h1,
                            h2,
                            h3{
                                stress:20;
                                richness:90
                            }
                            .hide{
                                speak:none
                            }
                            p.copyright{
                                volume:x-soft;
                                speech-rate:x-fast
                            }
                            dt{
                                pause-before:63ms
                            }
                            pre{
                                speak-punctuation:code
                            }
                        }</style>
                </head>
                <body>
                    <h1>ITS 2.0 Implementation Report</h1>
                    <p>Version generated: <xsl:value-of select="current-dateTime()"/></p>
                    <p>This document is the implementation report for the <a
                            href="http://www.w3.org/International/multilingualweb/lt/"
                            >MultilingualWeb-LT</a> Working Group's <a
                              href="http://www.w3.org/TR/2013/WD-its20-20130820/">Internationalization
                              Tag Set 2.0 (20 August 2013 Last Call Working Draft)</a>. The report contains
                        the following sections:</p>
                    <ul>
                        <li class="toc">
                            <a href="#test-suite-overview">1. Test suite overview</a>
                        </li>
                        <li class="toc"><a href="#conformance-classes-overview">2. Conformance clauses for
                                implementing ITS 2.0</a><ul>
                                <li class="toc"><a href="#conformance-markup">2.1 Conformance testing related to
                                        ITS 2.0 markup</a>
                                </li>
                                <li class="toc"><a href="#conformance-processing-expectations">2.2 Conformance
                                        testing related to processing ITS 2.0 information</a></li>
                                  <li class="toc"><a href="#conformance-nif-conversion">2.3 Testing related to NIF conversion (non-normative)</a></li>
                                </ul></li>
                    </ul>
                    <h2 id="test-suite-overview">1. Test suite overview</h2>
                    <p>The test suite is located at <a href="{$testSuiteFilesLinksPrefix}"
                                ><xsl:value-of select="$testSuiteFilesLinksPrefix"/></a></p>
                  <p>The test suite input files are referenced from the test suite and are part of the <a href="https://github.com/w3c/web-platform-tests/tree/master/conformance-checkers/html-its">W3C web platform conformance checkers</a>. Here there are both the HTML5 and XML tests stored.</p>
                    <xsl:variable name="referenceOutput"
                        select="count($annotatedTestSuiteMaster/my:testSuite/my:dataCategory/my:inputfile)"/>
                    <xsl:variable name="implementersTestsTotal"
                        select="count($annotatedTestSuiteMaster/my:testSuite/my:dataCategory/my:inputfile/my:outputImplementors)"/>
                    <xsl:variable name="testsWithErrors"
                        select="count($annotatedTestSuiteMaster/my:testSuite/my:dataCategory/my:inputfile/my:outputImplementors[my:error])"/>
                    <ul>
                        <li>Total number of input and reference output files: <xsl:value-of
                                select="$referenceOutput"/></li>
                        <li>Total number of tests successfully run from all implementers:
                                <xsl:value-of select="$implementersTestsTotal - $testsWithErrors"
                            />.</li>
                    </ul>
                    <!--                     <p>For ease of debugging, <a href="testSuiteDashboard.xml"
                        >testSuiteDashboard.xml</a> is an XML dump of the current state of the
                        test suite.</p>
                    <xsl:result-document href="testSuiteDashboard-PR-transition.xml">
                        <xsl:copy-of select="$annotatedTestSuiteMaster"/>
                    </xsl:result-document> -->
                    <h2 id="conformance-classes-overview">2. Conformance clauses for implementing
                        ITS 2.0</h2>
                    <p>ITS 2.0 provides conformance clauses for four different types of
                        implementers.</p>
                    <ol>
                        <li>
                            <p>Conformance clauses in <a 
                                href="http://www.w3.org/TR/its20/#conformance-product-schema" >Section
                                    4.1: Conformance Type 1: ITS Markup Declarations</a> tell markup
                                vocabulary developers how to add ITS 2.0 markup declarations to
                                their schemas.</p>
                        </li>
                        <li>
                            <p>Conformance clauses in <a 
                                href="http://www.w3.org/TR/its20/#conformance-product-processing-expectations" 
                                    >Section 4.2: Conformance Type 2: The Processing Expectations
                                    for ITS Markup</a> tell implementers how to process XML content
                                according to ITS 2.0 data categories.</p>
                        </li>
                        <li>
                            <p>Conformance clauses in <a 
                                href="http://www.w3.org/TR/its20/#conformance-product-html-processing-expectations"
                                    >Section 4.3: Conformance Type 3: Processing
                                    Expectations for ITS Markup in HTML</a> tell implementers how to
                                process <a title="HTML5" href="http://www.w3.org/TR/its20/#html5" >[HTML5]</a>
                                content.</p>
                        </li>
                        <li>
                            <p>Conformance clauses in <a 
                                href="http://www.w3.org/TR/its20/#conformance-product-html5-its" >Section
                                    4.4: Conformance Type 4: Markup conformance for HTML5+ITS
                                    documents</a> tell implementers how ITS 2.0 markup is integrated
                              into <a title="HTML5" href="http://www.w3.org/TR/its20/#html5" >[HTML5]</a>.</p>
                        </li>
                    </ol>
                    <h3 id="conformance-markup">2.1 Conformance testing related to ITS 2.0 markup
                        (clauses in section 4.1 and section 4.4)</h3>
                    <p>As part of the <a href="{$testSuiteFilesLinksPrefix}">ITS 2.0 test suite</a>,
                            <xsl:value-of
                            select="count($annotatedTestSuiteMaster/my:testSuite/my:dataCategory/my:inputfile)"
                        /> input files have been created. There are <xsl:value-of
                            select="count($annotatedTestSuiteMaster/my:testSuite/my:dataCategory/my:inputfile[contains(@location,'/xml/')])"
                        /> XML input files and <xsl:value-of
                            select="count($annotatedTestSuiteMaster/my:testSuite/my:dataCategory/my:inputfile[contains(@location,'/html/')])"
                        /> HTML input files. All of these files have been validated successfully
                        against the <a href="http://www.w3.org/TR/its20/#its-schemas">schemas for
                            ITS 2.0</a>. The <a href="{$testSuiteFilesLinksPrefix}">test suite main
                            page</a> provides information on how to <a
                            href="{concat($testSuiteMainPage,'#validating-xml-test-files')}"
                            >validate XML files</a> and <a
                            href="{concat($testSuiteMainPage,'#validating-html-test-files')}"
                            >validate HTML files</a>.</p>
                  <h3 id="conformance-processing-expectations">2.2 Conformance testing related to processing ITS 2.0 information (clauses in section 4.2 and section 4.3)</h3>
                    <p>The ITS 2.0 specification provides four types of processor conformance: in <a
                            href="http://www.w3.org/TR/its20/#conformance-product-processing-expectations"
                            >section 4.2</a> about processing XML <a
                            href="http://www.w3.org/TR/its20/#its-conformance-2-1-1">global or
                            local</a>, and in <a
                            href="http://www.w3.org/TR/its20/#conformance-product-html-processing-expectations"
                            >section 4.3</a> about processing HTML <a
                            href="http://www.w3.org/TR/its20/#its-conformance-3-1-1">global or
                            local</a>. The tables below summarize the implementation status with
                        regards to these conformance classes. <strong>Note:</strong> not each data
                        category implements both local and local processing. See the <a
                            href="http://www.w3.org/TR/its20/#datacategories-overview">data category
                            overview table</a> for details.</p>
                    <p><strong>NOTE:</strong> ITS 2.0 processing expectations only define which
                        information needs to be made available. They do not define how that
                        information actually is to be used. This is due to the fact that there is a
                        wide variety of usage scenarios for ITS 2.0, and a wide variety of tools for
                        working with ITS 2.0 is possible. Each of these tools may have its own way
                        of using ITS 2.0 data categories (see <a
                            title="Metadata for the Multilingual Web - Usage Scenarios and Implementations "
                            href="http://www.w3.org/TR/its20/#mlw-metadata-us-impl" 
                            >[MLW US IMPL]</a> for more information).</p>
                    <xsl:call-template name="conformance-classes-overview"/>
                    <hr/>
                  <h3 id="conformance-nif-conversion">Testing related to NIF conversion (non-normative)</h3>
                  <p>The ITS 2.0 specification has a <span style="text-decoration: underline;">non-normative</span> feature called <a href="http://www.w3.org/TR/its20/#conversion-to-nif">Conversion to NIF</a>: markup documents with ITS 2.0 information are converted to an RDF representation. The representation is based on the RDF vocabulary <q>NLP Interchange Format</q> (NIF). NIF leverages natural language processing workflows in RDF.</p>
                  <p>For testing the NIF conversion, a set of <a href="{concat($testSuiteFilesLinksPrefix,'nif-conversion/sparqltests')}">SPARQL queries</a> has been developed. They are used to check RDF constraints that are relevant for the NIF representation. <a href="{concat($testSuiteFilesLinksPrefix,'nif-conversion/outputimplementors')}">Three implementers</a> have implemented the conversion to NIF and have successfully run the SPARQL queries.</p>
                    <hr/>
                </body>
            </html>
        </xsl:result-document>
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
      <p>Each data category provides tests with the following information:</p>
      <ul>
        <li>Information about the input files <ul>
          <li>Type of tests (global or local) and additional description</li>
          <li>Links to related assertions made in the ITS 2.0 specification</li>
        </ul></li>
        <li> Information about the output from implementers<ul>
          <li><q class="na">N/A</q> = the implementer did not run the test.</li>
          <li><q class="ok">OK</q> = the output file is identical to the reference output
            file.</li>
        </ul></li>
      </ul>
        <p>The following subsections contain conformance testing details about all data categories:</p>
        <ul>
            <xsl:for-each select="$datacategories">
                <xsl:variable name="pos" select="position()"/>
                <xsl:variable name="currentDatacat" select="."/>
                <li>
                    <a href="{concat('#',replace(.,'[\s+,+]',''),'conformance-overview')}">
                        <xsl:value-of select="concat('2.2.',$pos,' ',.)"/>
                    </a>
                </li>
            </xsl:for-each>
        </ul>
        <xsl:for-each select="$datacategories">
            <xsl:variable name="pos" select="position()"/>
            <xsl:variable name="currentDatacat" select="."/>
            <h4 id="{concat(replace(.,'[\s+,+]',''),'conformance-overview')}">
                <xsl:value-of select="concat('2.2.',$pos,' ',.)"/>
            </h4>
            <xsl:variable name="xml-global"
                select="$annotatedTestSuiteMaster/my:testSuite/my:dataCategory[@name=$currentDatacat]/my:inputfile[contains(@conformance-class,'xml-global')]"/>
            <xsl:variable name="xml-local"
                select="$annotatedTestSuiteMaster/my:testSuite/my:dataCategory[@name=$currentDatacat]/my:inputfile[contains(@conformance-class,'xml-local')]"/>
            <xsl:variable name="html-global"
                select="$annotatedTestSuiteMaster/my:testSuite/my:dataCategory[@name=$currentDatacat]/my:inputfile[contains(@conformance-class,'html-global')]"/>
            <xsl:variable name="html-local"
                select="$annotatedTestSuiteMaster/my:testSuite/my:dataCategory[@name=$currentDatacat]/my:inputfile[contains(@conformance-class,'html-local')]"/>
            <table border="1" class="conformanceclasses">
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
          <p id="{concat(replace(.,'[\s+,+]',''),'test-details')}">Details about tests per implementer:</p>
          <table border="1">
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
                  <a
                    href="{concat($inputDataPrefix,substring-after($currentInputFile/@location,'inputdata/'))}"
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
                      <a href="{concat($its2spec,'#',.)}">[<xsl:value-of select="$no"
                      />]</a>
                    </xsl:for-each>) </xsl:if>
                  <a
                    href="{concat($testSuiteFilesLinksPrefix,$currentInputFile/my:expectedOutput/@location)}"
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
                                <span class="na">N/A</span>
                                <!-- 
                                                  <span class="fnf" title="file not found"
                                                  >fnf</span> -->
                              </xsl:when>
                              <xsl:otherwise>
                                <span class="na">N/A</span>
                                <!-- 
                                                  <span title="{$errorList}" class="error"
                                                  >error</span> -->
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:when>
                          <xsl:otherwise>
                            <a
                              href="{concat($testSuiteFilesLinksPrefix,$currentInputFile/my:outputImplementors[@implementer=$currentImplementer]/@location)}">
                              <span class="ok">OK</span>
                            </a>
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
