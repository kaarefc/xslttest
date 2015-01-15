<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:dobundle="http://doms.statsbiblioteket.dk/types/digitalobjectbundle/default/0/1/#"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:foxml="info:fedora/fedora-system:def/foxml#"
                xmlns:oai="http://www.openarchives.org/OAI/2.0/"
                xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
                xmlns:Index="http://statsbiblioteket.dk/summa/2008/Document"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:p="info:lc/xmlns/premis-v2"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:fedoraModel="info:fedora/fedora-system:def/model#"
                xmlns:date="http://exslt.org/dates-and-times"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"
                xmlns:java="http://xml.apache.org/xalan/java"
                xmlns:javadate="http://xml.apache.org/xalan/java/java.util.Date"
                xmlns:javadateParser="http://xml.apache.org/xalan/java/java.text.SimpleDateFormat"
                version="1.0" exclude-result-prefixes="xs xsl dobundle dc oai oai_dc p date java javadate javadateParser">
    <xsl:output version="1.0" encoding="UTF-8" indent="yes" method="xml"/>
    <xsl:include href="date.difference.template.xsl"/>

    <xsl:variable name="apos">'</xsl:variable>
    <xsl:variable name="parser"
                  select="javadateParser:new(concat('yyyy-MM-dd',$apos,'T',$apos,'HH:mm:ss.SSSXXX'))"/>


    <xsl:template match="/">
        <!-- find the batchid including round trip number of the batch round trip with the highest round trip number -->
        <xsl:variable name="batch_round_trip_id">
            <xsl:for-each select="/dobundle:digitalObjectBundle/foxml:digitalObject[1]/foxml:datastream[@ID='EVENTS']/foxml:datastreamVersion[last()]/foxml:xmlContent/p:premis/p:object/p:objectIdentifier/p:objectIdentifierValue">
                <!-- sort only on round trip number, that is: the part after -RT -->
                <xsl:sort select="substring-after(., '-RT')" data-type="number" order="descending"/>
                <xsl:if test="position() = 1">
                    <xsl:value-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <Index:SummaDocument version="1.0"
                             Index:disabled_resolver="doms"
                             Index:id="{/dobundle:digitalObjectBundle/foxml:digitalObject[1]/@PID}">
            <Index:fields>

                <Index:field Index:name="item_uuid">
                    <xsl:value-of select="/dobundle:digitalObjectBundle/foxml:digitalObject[1]/@PID"/>
                </Index:field>

                <xsl:variable name="lastModified">
                    <xsl:for-each select="//foxml:datastream[@ID != 'EVENTS']/foxml:datastreamVersion/@CREATED">
                        <xsl:sort data-type="text" order="descending"/>
                        <xsl:if test="position() = 1">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <Index:field Index:name="lastmodified_date">
                    <xsl:value-of select="$lastModified"/>
                </Index:field>


                <!--Models stuff-->
                <xsl:for-each select="/dobundle:digitalObjectBundle/foxml:digitalObject[1]/foxml:datastream[@ID='RELS-EXT']/foxml:datastreamVersion/foxml:xmlContent/rdf:RDF/rdf:Description/fedoraModel:hasModel">
                    <Index:field Index:name="item_model">
                        <xsl:value-of select="substring-after(@rdf:resource,'info:fedora/')"/>
                    </Index:field>
               </xsl:for-each>


                <!--Edition stuff-->
                <xsl:if test="/dobundle:digitalObjectBundle/foxml:digitalObject[1]/foxml:datastream[@ID='RELS-EXT']/foxml:datastreamVersion/foxml:xmlContent/rdf:RDF/rdf:Description/fedoraModel:hasModel[@rdf:resource='info:fedora/doms:ContentModel_Edition']">
                    <xsl:for-each select="/dobundle:digitalObjectBundle/foxml:digitalObject[1]/foxml:datastream[@ID='EDITION']/foxml:datastreamVersion/foxml:xmlContent/mods:mods">
                        <Index:field Index:name="newspapr_edition_avisID">
                            <xsl:value-of select="mods:titleInfo[@type='uniform']/mods:title/text()"/>
                        </Index:field>
                        <Index:field Index:name="newspapr_edition_dateIssued">
                            <xsl:value-of select="mods:originInfo/mods:dateIssued/text()"/>
                        </Index:field>
                    </xsl:for-each>
                </xsl:if>

                <!--Title Record stuff-->
                <xsl:if test="/dobundle:digitalObjectBundle/foxml:digitalObject[1]/foxml:datastream[@ID='RELS-EXT']/foxml:datastreamVersion/foxml:xmlContent/rdf:RDF/rdf:Description/fedoraModel:hasModel[@rdf:resource='info:fedora/doms:ContentModel_Newspaper']">
                    <xsl:for-each select="/dobundle:digitalObjectBundle/foxml:digitalObject[1]/foxml:datastream[@ID='MODS']/foxml:datastreamVersion/foxml:xmlContent/mods:mods">
                        <Index:field Index:name="newspapr_title_avisID">
                            <xsl:value-of select="mods:identifier[@type='title_family']/text()"/>
                        </Index:field>
                        <Index:field Index:name="newspapr_title_startDate">
                            <xsl:value-of select="mods:originInfo/mods:dateIssued[@point='start']/text()"/>
                        </Index:field>
                        <Index:field Index:name="newspapr_title_endDate">
                            <xsl:choose>
                                <!--Some components REQUIRE there to be an end date, but we do not have an end date for newspapers that are still alive, so create a fake future end date-->
                                <xsl:when test="mods:originInfo/mods:dateIssued[@point='end']">
                                    <xsl:value-of select="mods:originInfo/mods:dateIssued[@point='end']/text()"/>
                                </xsl:when>
                                <xsl:otherwise>3000-01-01</xsl:otherwise>
                            </xsl:choose>
                        </Index:field>
                    </xsl:for-each>
                </xsl:if>

                <xsl:for-each select="/dobundle:digitalObjectBundle/foxml:digitalObject[1]/foxml:datastream[@ID='EVENTS']/foxml:datastreamVersion/foxml:xmlContent/p:premis">

                    <!--Newspapr batch specific stuff-->
                    <xsl:if test="/dobundle:digitalObjectBundle/foxml:digitalObject[1]/foxml:datastream[@ID='RELS-EXT']/foxml:datastreamVersion/foxml:xmlContent/rdf:RDF/rdf:Description/fedoraModel:hasModel[@rdf:resource='info:fedora/doms:ContentModel_RoundTrip']">
                        <Index:field Index:name="newspapr_batch_id">
                            <xsl:value-of select="substring-before($batch_round_trip_id, '-')"/>
                        </Index:field>
                        <Index:field Index:name="batch_id"><!--deprecated-->
                            <xsl:value-of select="substring-before($batch_round_trip_id, '-')"/>
                        </Index:field>

                        <Index:field Index:name="newspapr_round_trip_no">
                            <xsl:value-of select="substring-after($batch_round_trip_id, '-')"/>
                        </Index:field>
                        <Index:field Index:name="round_trip_no"><!--deprecated-->
                            <xsl:value-of select="substring-after($batch_round_trip_id, '-')"/>
                        </Index:field>

                        <Index:field Index:name="newspapr_batch_uuid">
                            <xsl:value-of select="/dobundle:digitalObjectBundle/foxml:digitalObject[1]/@PID"/>
                        </Index:field>
                        <Index:field Index:name="batch_uuid"><!--deprecated-->
                            <xsl:value-of select="/dobundle:digitalObjectBundle/foxml:digitalObject[1]/@PID"/>
                        </Index:field>

                        <Index:field Index:name="newspapr_round_trip_uuid">
                            <xsl:value-of select="ancestor::foxml:digitalObject[1]/@PID"/>
                        </Index:field>
                        <Index:field Index:name="round_trip_uuid"><!--deprecated-->
                            <xsl:value-of select="ancestor::foxml:digitalObject[1]/@PID"/>
                        </Index:field>
                    </xsl:if>



                    <!--Generic Item stuff-->
                    <Index:field Index:name="initial_date">
                        <xsl:for-each select="p:event/p:eventDateTime">
                            <xsl:sort data-type="text" order="ascending"/>
                            <xsl:if test="position() = 1">
                                <xsl:value-of select="."/>
                            </xsl:if>
                        </xsl:for-each>
                    </Index:field>


                    <Index:field Index:name="premis_no_details">
                        <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
                        <xsl:apply-templates select="."/>
                        <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
                    </Index:field>


                    <xsl:for-each select="p:event[not(p:eventType = preceding-sibling::p:event/p:eventType)]">
                        <xsl:call-template name="handleEvent">
                            <xsl:with-param name="eventGroup" select="key('eventKey',p:eventType)"/>
                            <xsl:with-param name="lastModified" select="$lastModified"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:for-each>
            </Index:fields>
        </Index:SummaDocument>
    </xsl:template>

    <xsl:key name="eventKey" match="p:event" use="p:eventType"/>

    <xsl:template name="handleEvent">
        <xsl:param name="eventGroup"/>
        <xsl:param name="lastModified"/>

        <xsl:for-each select="$eventGroup">
            <xsl:sort select="javadate:getTime(javadateParser:parse($parser,p:eventDateTime/text()))" data-type="number" order="descending"/>

            <xsl:if test="position() = 1">

                <xsl:variable name="eventDateTime">
                    <xsl:value-of select="p:eventDateTime"/>
                </xsl:variable>
                <xsl:variable name="eventType">
                    <xsl:value-of select="p:eventType/text()"/>
                </xsl:variable>


                <Index:field Index:name="event">
                    <xsl:value-of select="$eventType"/>
                </Index:field>

                <xsl:variable name="difference">
                    <xsl:call-template name="date:difference">
                        <xsl:with-param name="start" select="$lastModified"/>
                        <xsl:with-param name="end" select="$eventDateTime"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="starts-with($difference, '-')">
                        <Index:field Index:name="old_event">
                            <xsl:value-of select="$eventType"/>
                        </Index:field>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="p:eventOutcomeInformation/p:eventOutcome/text()='success'">
                        <Index:field Index:name="success_event">
                            <xsl:value-of select="$eventType"/>
                        </Index:field>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <!--Remove these from the output-->
    <xsl:template match="p:linkingObjectIdentifier"/>
    <xsl:template match="p:linkingAgentIdentifier"/>
    <xsl:template match="p:agent"/>


    <!--Copy all that is not matched more specifically-->
    <xsl:template match="@*|*">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[ancestor-or-self::p:eventOutcomeDetail]">
    </xsl:template>

</xsl:stylesheet>
