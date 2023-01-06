<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               version="2.0"
               xpath-default-namespace="http://www.entitymodelling.org/ERmodel"
               xmlns="http://www.entitymodelling.org/ERmodel">
<xsl:output method="xml" indent="yes"/>

<xsl:include href="ERmodel.functions.module.xslt"/>

<xsl:template match="/">
   <xsl:message> In root entity in 2.oldform which is <xsl:value-of select="name()"/></xsl:message>
   <!--
   <xsl:message> Initial pass</xsl:message>
   <xsl:variable name="state" as="document-node()">
      <xsl:copy>
         <xsl:apply-templates select="." mode="initial_pass"/>
      </xsl:copy>
   </xsl:variable>
   -->
   <xsl:message> main pass</xsl:message>
   <xsl:copy>
      <xsl:apply-templates select="entity_model" mode="oldform"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="@*|node()" mode="oldform">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="oldform"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="@name" mode="oldform">
   <xsl:element name="name"> 
      <xsl:value-of select="."/>
   </xsl:element>
</xsl:template>  

<xsl:template match="@type" mode="oldform">
   <!-- intentially left blank -->
</xsl:template>  

<xsl:template  match="group" mode="oldform">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="oldform"/> 
   </xsl:copy>
</xsl:template>

<xsl:template  match="entity_type/identifying" mode="oldform">
      <!-- just flatten the structure i.e. remove the <identifying> element 
           TBD: need also to consolidate (need an example that needs this second step)
      -->
      <xsl:apply-templates select="@*|node()" mode="oldform"/> 
</xsl:template>

<xsl:template  match="entity_type" 
                    mode="oldform">
   <xsl:copy>  
      <xsl:apply-templates select="@*|node()" mode="oldform"/> 
   </xsl:copy>
</xsl:template>

<xsl:template  match="*[ self::reference
                        |self::composition
                       ]" 
                    mode="oldform">
   <xsl:copy>
      <xsl:apply-templates select="@*" mode="oldform"/> <!-- process attributes first -->
         <xsl:element name="cardinality">
         <xsl:element name="{if (substring(@type,string-length(@type))='?')
                             then 'ZeroOrOne'
                             else if (substring(@type,string-length(@type))='*')
                             then 'ZeroOneOrMore'
                             else if (substring(@type,string-length(@type))='+')
                             then 'OneOrMore'
                             else 'ExactlyOne'
                            }"/>

      </xsl:element>
      <xsl:variable name="type"
                        select="if ((substring(@type,string-length(@type))='?')
                                 or (substring(@type,string-length(@type))='*')
                                 or (substring(@type,string-length(@type))='+'))
                                then substring(@type,1,string-length(@type)-1)
                                else @type
                               "/>
      <xsl:element name="type">
         <xsl:value-of select="$type"/>
      </xsl:element>
      <xsl:if test="   (self::reference and parent::identifying)
                    or (self::composition and //identifying/context/../../@name=$type)">    
         <xsl:element name="identifying"/>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="@inverse">
            <xsl:element name="inverse">
               <xsl:value-of select="@inverse"/>
            </xsl:element>
         </xsl:when>
         <xsl:when test="self::composition">
            <xsl:element name="inverse">
               <xsl:value-of select="if(//context[../name=$type][@name])
                                     then //context[../name=$type]/@name
                                     else if(//identifying/context[../../name=$type][@name])
                                     then //identifying/context[../../name=$type]/@name
                                     else '..'
                                     "/>
            </xsl:element>
         </xsl:when>
      </xsl:choose>


      <xsl:apply-templates select="*" mode="oldform"/> <!-- now processing non-attributes -->
   </xsl:copy>
</xsl:template>

<xsl:template  match="context" mode="oldform">
   <xsl:element name="dependency">
      <xsl:if test="not(@name)">
         <xsl:element name="name">
            <xsl:choose>
               <xsl:when test="//composition[type=current()/../name]/inverse">
                  <xsl:value-of select="//composition[type=current()/../name]/inverse"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>..</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:if>
      <xsl:apply-templates select="@*" mode="oldform"/> <!-- process attributes first -->
      <xsl:choose>
         <xsl:when test="@type">
            <xsl:element name="cardinality">
               <xsl:element name="{if (substring(type,string-length(@type))='?')
                                   then 'ZeroOrOne'
                                   else 'ExactlyOne'
                                  }"/>

            </xsl:element>
            <xsl:element name="type">
               <xsl:value-of select="if ((substring(@type,string-length(@type))='?')
                                       or (substring(@type,string-length(@type))='*')
                                       or (substring(@type,string-length(@type))='+'))
                                      then substring(@type,1,string-length(@type)-1)
                                      else @type
                                     "/>

            </xsl:element>
         </xsl:when>
         <xsl:otherwise>
            <xsl:element name="cardinality">
                  <xsl:value-of select="if (count(//composition[type=current()/../name]) &gt; 1)
                                        then 'ZeroOrOne'
                                        else 'ExactlyOne'
                                          "/>
            </xsl:element>
            <xsl:element name="type">
                  <xsl:value-of select="//composition[type=current()/../name]/../name"/>
                  <!-- this logic not quite right because might be multiple incoming compositions -->
            </xsl:element>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="parent::identifying
                     or //composition[type=current()/../name]/identifying">    
                                                <!-- TBD probably need a bit more than this -->
                                             <!-- Hmmmm ... not sure -->
         <xsl:element name="identifying"/>   <!-- little bit odd because previously wouldn't have modelled 
                                                depedencies as identifying -->
      </xsl:if>
      <xsl:element name="inverse_of">
         <xsl:value-of select="//composition[type=current()/../name]/name"/>
      </xsl:element>
      <xsl:apply-templates select="*" mode="oldform"/> <!-- now processing non-attributes -->
   </xsl:element>
</xsl:template>

<xsl:template  match="attribute" 
                    mode="oldform">
   <xsl:copy>
      <xsl:if test="@name">
         <xsl:element name="name"> 
            <xsl:value-of select="@name"/>
         </xsl:element>
      </xsl:if>
      <xsl:if test="@type">
         <xsl:element name="type">
            <xsl:value-of select="if (substring(type,string-length(@type))='?')
                                  then substring(type,1,string-length(@type)-1)
                                  else @type
                                  "/>
         </xsl:element>
      </xsl:if>
            <xsl:if test="parent::identifying">    <!-- TBD probably need a bit more than this -->
                                             <!-- Hmmmm ... not sure -->
         <xsl:element name="identifying"/>
      </xsl:if>
      <!-- <xsl:apply-templates select="@*|node()" 
                           mode="oldform"/>    -->
   </xsl:copy>
</xsl:template>

<xsl:template match="*[self::constructed_relationship|self::diagonal|self::riser|self::key]" mode="oldform">
   <xsl:copy>
      <xsl:apply-templates select="@path" mode="parse_navigation"/>
   </xsl:copy>
</xsl:template>


<xsl:template match="@path" mode="parse_navigation">
   <xsl:variable name="text" as="xs:string" select="."/>
   <xsl:message>text of navigation is <xsl:value-of select="$text"/></xsl:message>
   <xsl:choose>
      <xsl:when test="$text='.'">
         <xsl:element name="identity"/>
      </xsl:when>
      <xsl:when test="$text='^'">
         <xsl:element name="theaboslute"/>
      </xsl:when>
      <xsl:when test="contains($text,'/')">
         <xsl:element name="join">
            <xsl:analyze-string select="$text" regex="/">
              <xsl:non-matching-substring>
                <xsl:element name="component">
                  <xsl:element name="rel">
                     <xsl:value-of select="."/>
                  </xsl:element>
               </xsl:element>
              </xsl:non-matching-substring>
            </xsl:analyze-string>
         </xsl:element>
      </xsl:when>
      <xsl:when test="contains($text,'|')">
         <xsl:element name="aggregate">
            <xsl:analyze-string select="$text" regex=".*\|.*">
              <xsl:non-matching-substring>
                <xsl:element name="component">
                  <xsl:element name="rel">
                     <xsl:value-of select="."/>
                  </xsl:element>
               </xsl:element>
              </xsl:non-matching-substring>
            </xsl:analyze-string>
         </xsl:element>
      </xsl:when>
      <xsl:otherwise>
         <xsl:element name="join">
          <xsl:element name="component">
            <xsl:element name="rel">
               <xsl:value-of select="$text"/>
            </xsl:element>
         </xsl:element>
      </xsl:element>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>




</xsl:transform>
