<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:dobundle="http://ecm.sourceforge.net/types/digitalobjectbundle/0/2/#"
                xmlns:foxml="info:fedora/fedora-system:def/foxml#"
                xmlns:pbcore="http://www.pbcore.org/PBCore/PBCoreNamespace.html"
                xmlns:ritz="http://doms.statsbiblioteket.dk/types/ritzau_original/0/1/#"
                xmlns:gallup="http://doms.statsbiblioteket.dk/types/gallup_original/0/1/#"

                xmlns:oai="http://www.openarchives.org/OAI/2.0/"
                xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
                xmlns:Index="http://statsbiblioteket.dk/summa/2008/Document"
                xmlns:d="http://fedora.statsbiblioteket.dk/datatypes/digitalObjectBundle/"
                xmlns:dcterms="http://purl.org/dc/terms/"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:doms="http://www.statsbiblioteket.dk/doms-relations/"
                version="1.0" exclude-result-prefixes="xs xsl dobundle dc oai oai_dc">
    <!--xmlns:util="http://xml.apache.org/xalan/java/dk.statsbiblioteket.doms.disseminator.Util"-->
    <!-- Fallback handling of DOMS data
         Right now it is a copy of the radio-TV xslt, so get on modifying!
    -->
    <xsl:output version="1.0" encoding="UTF-8" indent="yes" method="xml"/>
    <xsl:template match="/">

        <xsl:variable name="id">
            <xsl:value-of select="dobundle:digitalObjectBundle/foxml:digitalObject/@PID"/>
        </xsl:variable>

        <Index:SummaDocument version="1.0" Index:boost="1" Index:disabled_resolver="doms" Index:id="{$id}">
            <Index:fields>
                <xsl:for-each select="dobundle:digitalObjectBundle">
                    <Index:field Index:name="domsshortrecord">
                        <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
                        <shortrecord>
                            <pid><xsl:value-of select="foxml:digitalObject[position()=1]/@PID"/></pid>
                            <title><xsl:value-of select="foxml:digitalObject[position()=1]/foxml:objectProperties/foxml:property[@NAME='info:fedora/fedora-system:def/model#label']/@VALUE"/></title>
                            <state><xsl:value-of select="foxml:digitalObject[position()=1]/foxml:objectProperties/foxml:property[@NAME='info:fedora/fedora-system:def/model#state']/@VALUE"/></state>
                            <type>Radio/tv</type>
                            <createdDate><xsl:value-of select="foxml:digitalObject[position()=1]/foxml:objectProperties/foxml:property[@NAME='info:fedora/fedora-system:def/model#createdDate']/@VALUE"/></createdDate>
                            <modifiedDate><xsl:value-of select="foxml:digitalObject[position()=1]/foxml:objectProperties/foxml:property[@NAME='info:fedora/fedora-system:def/view#lastModifiedDate']/@VALUE"/></modifiedDate>
                        </shortrecord>
                        <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
                    </Index:field>


                    <xsl:for-each select="foxml:digitalObject/foxml:datastream[@ID='PBCORE']/foxml:datastreamVersion[last()]/foxml:xmlContent/pbcore:PBCoreDescriptionDocument">


                        <Index:field Index:name="shortformat">
                            <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
                            <shortrecord>
                                <shardURL>
                                    <xsl:for-each select="../../../../../foxml:digitalObject/foxml:datastream[@ID ='CONTENTS']/foxml:datastreamVersion[last()]">
                                        <xsl:value-of select="foxml:contentLocation/@REF"/>
                                    </xsl:for-each>
                                </shardURL>
                                <shortRecordDescription>
                                    <xsl:variable name="kortomtale">
                                        <xsl:for-each select="pbcore:pbcoreDescription/pbcore:descriptionType[text()='kortomtale']">
                                            <xsl:value-of select="../pbcore:description"/>
                                        </xsl:for-each>
                                    </xsl:variable>
                                    <xsl:variable name="langomtale1">
                                        <xsl:for-each select="pbcore:pbcoreDescription/pbcore:descriptionType[text()='langomtale1']">
                                            <xsl:value-of select="../pbcore:description"/>
                                        </xsl:for-each>
                                    </xsl:variable>
                                    <xsl:variable name="langomtale2">
                                        <xsl:for-each select="pbcore:pbcoreDescription/pbcore:descriptionType[text()='langomtale2']">
                                            <xsl:value-of select="../pbcore:description"/>
                                        </xsl:for-each>
                                    </xsl:variable>
                                    <xsl:choose>
                                        <xsl:when test="$langomtale1 != ''">
                                            <xsl:value-of select="$langomtale1" />
                                        </xsl:when>
                                        <xsl:when test="$kortomtale != ''">
                                            <xsl:value-of select="$kortomtale" />
                                        </xsl:when>
                                    </xsl:choose>
                                </shortRecordDescription>

                                <!--

                                pbcore:pbcoreDescription/pbcore:description

    <xsl:template name="get-radiotv_description">
        <xsl:if test="xmlContent/PBCoreDescriptionDocument/pbcoreDescription[position() = 1]/description">
            <xsl:for-each select="xmlContent/PBCoreDescriptionDocument/pbcoreDescription[position() = 1]/description">
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template name="get-radiotv_description2">
        <xsl:if test="xmlContent/PBCoreDescriptionDocument/pbcoreDescription[position() = 2]/description">
            <xsl:for-each select="xmlContent/PBCoreDescriptionDocument/pbcoreDescription[position() = 2]/description">
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template name="get-radiotv_description-short">
        <xsl:if test="xmlContent/PBCoreDescriptionDocument/pbcoreDescription/descriptionType='kortomtale'">
            <xsl:for-each select="xmlContent/PBCoreDescriptionDocument/pbcoreDescription/descriptionType[text()='kortomtale']">
                <xsl:value-of select="../description"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>



                                -->




                                <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/">
                                    <rdf:Description>
                                        <dc:title>
                                            <xsl:value-of select="pbcore:pbcoreTitle/pbcore:title"/>
                                        </dc:title>
                                        <dc:creator>
                                            <xsl:choose>
                                                <xsl:when test="pbcore:pbcoreCreator/pbcore:creator/text() != ''">
                                                    <xsl:value-of select="pbcore:pbcoreCreator/pbcore:creator"/>
                                                </xsl:when>
                                                <xsl:when test="pbcore:pbcoreContributor/pbcore:contributor/text() != '' and pbcore:pbcoreContributor/pbcore:contributorRole ='forfatter'">
                                                    <xsl:value-of select="pbcore:pbcoreContributor/pbcore:contributor"/>
                                                </xsl:when>
                                            </xsl:choose>
                                        </dc:creator>
                                        <dc:date>
                                            <xsl:value-of select="substring(pbcore:pbcoreInstantiation/pbcore:pbcoreDateAvailable/pbcore:dateAvailableStart,1,4)"/>
                                        </dc:date>
                                        <dc:dateTime>
                                            <xsl:value-of select="substring(pbcore:pbcoreInstantiation/pbcore:pbcoreDateAvailable/pbcore:dateAvailableStart,9,2)"/>
                                            <xsl:text>-</xsl:text>
                                            <xsl:value-of select="substring(pbcore:pbcoreInstantiation/pbcore:pbcoreDateAvailable/pbcore:dateAvailableStart,6,2)"/>
                                            <xsl:text>-</xsl:text>
                                            <xsl:value-of select="substring(pbcore:pbcoreInstantiation/pbcore:pbcoreDateAvailable/pbcore:dateAvailableStart,1,4)"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select="substring(pbcore:pbcoreInstantiation/pbcore:pbcoreDateAvailable/pbcore:dateAvailableStart,12,5)"/>
                                        </dc:dateTime>
                                        <dc:type xml:lang="da">
                                            <xsl:choose>
                                                <xsl:when test="pbcore:pbcoreInstantiation/pbcore:formatMediaType='Sound'">
                                                    <xsl:value-of select="'Radio'"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="'Tv'"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </dc:type>
                                        <dc:type xml:lang="en">
                                            <xsl:choose>
                                                <xsl:when test="pbcore:pbcoreInstantiation/pbcore:formatMediaType='Sound'">
                                                    <xsl:value-of select="'Radio'"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="'Tv'"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </dc:type>
                                        <dc:identifier>
                                            <xsl:value-of select="$id"/>
                                        </dc:identifier>
                                        <channelname>
                                            <xsl:value-of select="pbcore:pbcorePublisher[pbcore:publisherRole/text() = 'channel_name']/pbcore:publisher"/>
                                        </channelname>
                                        <channelnameHuman>
                                            <xsl:value-of select="pbcore:pbcorePublisher[pbcore:publisherRole/text() = 'kanalnavn']/pbcore:publisher"/>
                                        </channelnameHuman>
                                        <episode>
                                            <xsl:for-each select="pbcore:pbcoreExtension/pbcore:extension">
                                                <xsl:if test="starts-with(.,'episodenr:')">
                                                    <xsl:value-of select="substring-after (.,'episodenr:')"/>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </episode>
                                        <totalEpisodes>
                                            <xsl:for-each select="pbcore:pbcoreExtension/pbcore:extension">
                                                <xsl:if test="starts-with(.,'antalepisoder:')">
                                                    <xsl:value-of select="substring-after (.,'antalepisoder:')"/>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </totalEpisodes>
                                    </rdf:Description>
                                </rdf:RDF>
                            </shortrecord>
                            <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
                        </Index:field>

                        <!-- Title group -->
                        <xsl:for-each select="pbcore:pbcoreTitle/pbcore:title">
                            <xsl:choose>
                                <xsl:when test="../pbcore:titleType ='titel'">
                                    <xsl:if test="./text()!=''">
                                        <Index:field Index:name="main_title">
                                            <xsl:value-of select="."/>
                                        </Index:field>
                                        <Index:field Index:name="lti">
                                            <xsl:value-of select="."/>
                                        </Index:field>
                                        <Index:field Index:name="sort_title">
                                            <xsl:value-of select="."/>
                                        </Index:field>
                                        <!--  Language bliver ikke angivet fra Ritzau, derfor kan indledende artikler ikke fjernes pt
                                        <Index:field Index:name="lti">
                                            <xsl:call-template name="article" >
                                                <xsl:with-param name="code" select="."/>
                                            </xsl:call-template>
                                        </Index:field>
                                        -->
                                    </xsl:if>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="./text()!=''">
                                        <Index:field Index:name="title">
                                            <xsl:value-of select="."/>
                                        </Index:field>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>

                        <!-- Author group -->
                        <xsl:for-each select="pbcore:pbcoreCreator/pbcore:creator">
                            <xsl:if test="./text()!=''">
                                <Index:field Index:name="author_person">
                                    <xsl:value-of select="."/>
                                </Index:field>
                                <Index:field Index:name="author_main">
                                    <xsl:value-of select="."/>
                                </Index:field>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:for-each select="pbcore:pbcorePublisher/pbcore:publisher">
                            <xsl:if test="./text()!=''">
                                <Index:field Index:name="author_corporation">
                                    <xsl:value-of select="."/>
                                </Index:field>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:for-each select="pbcore:pbcoreContributor/pbcore:contributor">
                            <xsl:if test="./text()!=''">
                                <Index:field Index:name="author_other">
                                    <xsl:value-of select="."/>
                                </Index:field>
                            </xsl:if>
                        </xsl:for-each>

                        <xsl:for-each select="pbcore:pbcoreCreator/pbcore:creator">
                            <xsl:if test="./text()!=''">
                                <Index:field Index:name="author_normalised">
                                    <xsl:call-template name="author_norm">
                                        <xsl:with-param name="lastName" select="substring-after(.,' ')"/>
                                        <xsl:with-param name="firstName" select="substring-before(.,' ')"/>
                                    </xsl:call-template>
                                </Index:field>
                            </xsl:if>
                        </xsl:for-each>


                        <!-- Subject group -->
                        <xsl:for-each select="pbcore:pbcoreGenre/pbcore:genre">
                            <xsl:if test="./text()!=''">
                                <Index:field Index:name="subject_other">
                                    <xsl:choose>
                                        <xsl:when test="contains(.,':')">
                                            <xsl:value-of select="substring-after(.,':')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="."/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </Index:field>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:for-each select="pbcore:pbcoreGenre/pbcore:genre">
                            <xsl:if test="./text()!=''">
                                <Index:field Index:name="lsubject">
                                    <xsl:for-each select="pbcore:pbcoreGenre/pbcore:genre">
                                        <xsl:if test="./text()!=''">
                                            <xsl:choose>
                                                <xsl:when test="contains(.,':')">
                                                    <xsl:value-of select="substring-after(.,':')"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="."/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:if>
                                    </xsl:for-each>
                                </Index:field>
                            </xsl:if>
                        </xsl:for-each>

                        <!-- Material type -->
                        <Index:field Index:name="lma_long">
                            <xsl:choose>
                                <xsl:when test="pbcore:pbcoreInstantiation/pbcore:formatMediaType='Sound'">
                                    <xsl:value-of select="'radio'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'tv'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </Index:field>

                        <!-- Date -->
                        <Index:field Index:name="py">
                            <xsl:value-of select="substring(pbcore:pbcoreInstantiation/pbcore:pbcoreDateAvailable/pbcore:dateAvailableStart,1,4)"/>
                        </Index:field>

                        <xsl:if test="pbcore:pbcoreInstantiation/pbcore:pbcoreDateAvailable/pbcore:dateAvailableStart/text()!=''">
                            <Index:field Index:name="year" >
                                <xsl:value-of select="substring(pbcore:pbcoreInstantiation/pbcore:pbcoreDateAvailable/pbcore:dateAvailableStart,1,4)"/>
                            </Index:field>
                        </xsl:if>
                        <xsl:if test="pbcore:pbcoreInstantiation/pbcore:dateCreated/text()!='' and pbcore:pbcoreInstantiation/pbcore:dateCreated != '0'">
                            <Index:field Index:name="year" >
                                <xsl:value-of select="pbcore:pbcoreInstantiation/pbcore:dateCreated"/>
                            </Index:field>
                        </xsl:if>
                        <Index:field Index:name="iso_date">
                            <xsl:value-of select="substring(pbcore:pbcoreInstantiation/pbcore:pbcoreDateAvailable/pbcore:dateAvailableStart,1,10)"/>
                        </Index:field>
                        <Index:field Index:name="iso_time">
                            <xsl:value-of select="substring(pbcore:pbcoreInstantiation/pbcore:pbcoreDateAvailable/pbcore:dateAvailableStart,12,8)"/>
                        </Index:field>
                        <Index:field Index:name="iso_dateTime">
                            <xsl:value-of select="substring(pbcore:pbcoreInstantiation/pbcore:pbcoreDateAvailable/pbcore:dateAvailableStart,1)"/>
                        </Index:field>

                        <!-- Date sorting -->
                        <Index:field Index:name="sort_year_desc">
                            <xsl:choose>
                                <xsl:when test="pbcore:pbcoreInstantiation/pbcore:pbcoreDateAvailable/pbcore:dateAvailableStart/text() !=''">
                                    <xsl:value-of select="pbcore:pbcoreInstantiation/pbcore:pbcoreDateAvailable/pbcore:dateAvailableStart"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>0000</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </Index:field>
                        <Index:field Index:name="sort_year_asc" >
                            <xsl:choose>
                                <xsl:when test="pbcore:pbcoreInstantiation/pbcore:pbcoreDateAvailable/pbcore:dateAvailableStart/text()!=''">
                                    <xsl:value-of select="pbcore:pbcoreInstantiation/pbcore:pbcoreDateAvailable/pbcore:dateAvailableStart"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>9999</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </Index:field>

                        <!-- Saeson_id -->
                        <xsl:for-each select="pbcore:pbcoreExtension/pbcore:extension">
                            <xsl:if test="./text()!='' and substring(.,1,10) = 'saeson_id:'">
                                <Index:field Index:name="saeson_id">
                                    <xsl:value-of select="substring-after(.,':')"/>
                                </Index:field>
                            </xsl:if>
                        </xsl:for-each>

                        <!-- Description -->
                        <xsl:for-each select="pbcore:pbcoreDescription/pbcore:description">
                            <xsl:if test="./text()!=''">
                                <Index:field Index:name="no">
                                    <xsl:value-of select="."/>
                                </Index:field>
                            </xsl:if>
                        </xsl:for-each>

                        <xsl:for-each select="pbcore:pbcoreInstantiation/pbcore:formatAspectRatio">
                            <xsl:if test="./text()!=''">
                                <Index:field Index:name="no">
                                    <xsl:value-of select="."/>
                                </Index:field>
                            </xsl:if>
                        </xsl:for-each>

                        <xsl:for-each select="pbcore:pbcoreInstantiation/pbcore:formatColors">
                            <xsl:if test="./text()!=''">
                                <Index:field Index:name="no">
                                    <xsl:value-of select="."/>
                                </Index:field>
                            </xsl:if>
                        </xsl:for-each>

                        <xsl:for-each select="pbcore:pbcoreInstantiation/pbcore:alternativeModes">
                            <xsl:if test="./text()!=''">
                                <Index:field Index:name="no">
                                    <xsl:value-of select="."/>
                                </Index:field>
                            </xsl:if>
                        </xsl:for-each>

                        <xsl:for-each select="pbcore:pbcoreInstantiation/pbcore:pbcoreDateAvailable">
                            <xsl:if test="./text()!=''">
                                <Index:field Index:name="no">
                                    <xsl:value-of select="."/>
                                </Index:field>
                            </xsl:if>
                        </xsl:for-each>

                        <xsl:for-each select="pbcore:pbcoreExtension/pbcore:extension">
                            <xsl:if test="substring-after(.,':') !='' ">
                                <Index:field Index:name="no">
                                    <xsl:value-of select="substring-after(.,':')"/>
                                </Index:field>
                            </xsl:if>
                        </xsl:for-each>

                        <!--  Ritzay blokken er den der pt bliver benyttet til PBCORE, derfor ingen grund til dobbelt indeksering.
                        <xsl:for-each select="../../../../foxml:datastream[@ID='RITZAU_ORIGINAL']/foxml:datastreamVersion[last()]/foxml:xmlContent/ritz:ritzau_original">
                            <xsl:if test="./text()!=''">
                                <Index:field Index:name="no">
                                    <xsl:value-of select="."/>
                                </Index:field>
                            </xsl:if>
                        </xsl:for-each>
                        -->
                        <!-- Gallup blokken er pt ikke aktiv pga af problemer med at mappe den sammen med Ritzau blokken. Senere vil den blive tilføjet og brugt i PBCORE.
                        <xsl:for-each select="../../../../foxml:datastream[@ID='GALLUP_ORIGINAL']/foxml:datastreamVersion[last()]/foxml:xmlContent/gallup:gallup_original">
                            <xsl:if test="./text()!=''">
                                <Index:field Index:name="no">
                                    <xsl:value-of select="."/>
                                </Index:field>
                            </xsl:if>
                        </xsl:for-each>
                        -->

                    </xsl:for-each>
                </xsl:for-each>
            </Index:fields>
        </Index:SummaDocument>
    </xsl:template>

    <!-- Recursive template to make author normalized-->
    <xsl:template name="author_norm">
        <xsl:param name="lastName"/>
        <xsl:param name="firstName" />
        <xsl:choose>
            <xsl:when test="contains($lastName,' ')">
                <xsl:call-template name="author_norm">
                    <xsl:with-param name="lastName" select="substring-after($lastName,' ')"/>
                    <xsl:with-param name="firstName">
                        <xsl:value-of select="$firstName"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="substring-before($lastName,' ')"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$lastName" />
                <xsl:text>, </xsl:text>
                <xsl:value-of select="$firstName" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>
