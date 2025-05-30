<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               version="2.0"
               xpath-default-namespace="http://www.entitymodelling.org/ERmodel"
               xmlns="http://www.entitymodelling.org/ERmodel">
               
<!-- <xsl:output method="xml" indent="yes"/> Can we maneg without this 11 Sept 2023 -->

<!-- Enhancement request.  Create a matching composition relationship if a context cannot be matched to any incoming composition. -->

<xsl:variable name="postfixForInverseNameConstruction"
              select="'&#x207B;&#x00B9;'"/>  <!-- see change log for 16 July 2023 -->

<xsl:template match="entity_model" mode="parse__conditional">

   <!-- <xsl:message>parse conditional entity model</xsl:message> -->
   <xsl:choose>
      <xsl:when test="@ERScriptVersion='1.6'">
         <!-- <xsl:message>parse conditional actual entity model</xsl:message> -->
         <xsl:copy>
            <xsl:attribute name="metaDataFilePathWrtERHome" select="'MetaModel/xml/ERScript..physical.xml'"/>
            <xsl:apply-templates select="@*|node()" mode="parse__main_pass"/>
         </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
         <!-- <xsl:message>Copying stright through</xsl:message> -->
         <xsl:copy-of select="."/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="@ERScriptVersion" mode="parse__main_pass">
   <xsl:message>pass over ERScriptVersion</xsl:message>
         <!-- deliberately left empty -->
</xsl:template>

<xsl:template match="@metaDataFilePathWrtERHome" mode="parse__main_pass">
   <xsl:message>pass over metaDataFilePathWrtERHome</xsl:message>
         <!-- deliberately left empty -->
</xsl:template>

<xsl:template match="@*|node()" mode="parse__main_pass">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="parse__main_pass"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="@name" mode="parse__main_pass">
   <xsl:element name="name"> 
      <xsl:value-of select="."/>
   </xsl:element>
</xsl:template>  

<xsl:template match="@xpath_evaluate" mode="parse__main_pass">
   <xsl:element name="xpath_evaluate"> 
      <xsl:value-of select="."/>
   </xsl:element>
</xsl:template>  

<!-- what the heck is this ??-->
<xsl:template match="@identifying_relationship" mode="parse__main_pass">
   <xsl:element name="identifying_relationship"> 
      <xsl:value-of select="."/>
   </xsl:element>
</xsl:template> 

<xsl:template match="@id" mode="parse__main_pass">
   <xsl:element name="id"> 
      <xsl:value-of select="."/>
   </xsl:element>
</xsl:template> 

<xsl:template match="@injective" mode="parse__main_pass">
   <xsl:element name="injective"> 
      <xsl:value-of select="."/>
   </xsl:element>
</xsl:template> 

<xsl:template match="@surjective" mode="parse__main_pass">
   <xsl:element name="surjective"> 
      <xsl:value-of select="."/>
   </xsl:element>
</xsl:template>  

<xsl:template match="@type" mode="parse__main_pass">
   <!-- intentially left blank -->
</xsl:template>  

<xsl:template match="@inverse" mode="parse__main_pass">
   <!-- intentially left blank -->
</xsl:template>  

<xsl:template match="@inverse_of" mode="parse__main_pass">
   <!-- intentially left blank -->  <!-- 24/01/2025 -->
</xsl:template>  

<xsl:template  match="group" mode="parse__main_pass">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="parse__main_pass"/> 
   </xsl:copy>
</xsl:template>

<xsl:template  match="entity_type/identifying" mode="parse__main_pass">
      <!-- just flatten the structure i.e. remove the <identifying> element 
           TBD: need also to consolidate (need an example that needs this second step)
      -->
      <xsl:apply-templates select="@*|node()" mode="parse__main_pass"/> 
</xsl:template>


<xsl:template  match="entity_type" 
                    mode="parse__main_pass">
   <xsl:copy>  
      <xsl:apply-templates select="@*|node()" mode="parse__main_pass"/> 
      <xsl:if test="not(context) and not(identifying/context)">
         <!-- <xsl:message>Missing context in et named '<xsl:value-of select="@name"/> </xsl:message> -->
         <xsl:if test="//composition[era:typeFromExtendedType(@type)=current()/@name]">
            <!-- <xsl:message>Will plant dependency</xsl:message> -->
            <xsl:call-template name="create_dependency_from_scratch"/>
         </xsl:if>
      </xsl:if>

      <!-- create absent compositions from contexts types by this current entity type-->
         <!-- BUG might be identifying/context -->
      <xsl:for-each 
           select="//context[era:typeFromExtendedType(@type)=current()/@name]
                      [not(some $comp 
                           in current()/composition
                           satisfies (era:typeFromExtendedType($comp/@type)=
                                           ancestor-or-self::entity_type[1]/@name)
                           )]">
            <xsl:element name="composition">
               <xsl:if test="@inverse_of">
                  <xsl:element name="name">
                     <xsl:value-of select="@inverse_of"/>
                  </xsl:element>
               </xsl:if>
               <xsl:element name="type">
                  <xsl:value-of select="ancestor-or-self::entity_type[1]/@name"/>
               </xsl:element>
               <xsl:element name="inverse">
                     <xsl:value-of select="if (@name)
                                           then @name
                                           else '..'
                                           "/>
               </xsl:element>
               <xsl:element name="cardinality">
                  <xsl:element name="
                                    {if (@injective='true')
                                     then (if (@surjective='true')
                                           then 'ExactlyOne'
                                           else 'ZeroOrOne'
                                          )
                                     else if (@surjective='true')
                                          then 'OneOrMore'
                                          else 'ZeroOneOrMore'
                                    }
                                       "/>  
                                       <!-- this implements the defaults 
                                                injective false
                                                surjective false
                                                (see change of 16-Nov-2024)
                                       -->
               </xsl:element>
            </xsl:element>
      </xsl:for-each>
   </xsl:copy>
</xsl:template>


  <!-- CODE REVIEW 19 Jan 2025 
         this template could be reprogrammed and named "create_missing_dependencies"
  -->
<xsl:template name="create_dependency_from_scratch" match="entity_type" mode="explicit">
   <!-- <xsl:message>create dependency from scratch for et '<xsl:value-of select="@name"/>'</xsl:message> -->
   <xsl:variable name="cardinality" as="element(cardinality)">
      <xsl:element name="cardinality">
            <xsl:element name="{if (count(//composition[era:typeFromExtendedType(@type)=current()/@name]) &gt; 1)
                                  then 'ZeroOrOne'
                                  else 'ExactlyOne'}
                                    "/>
      </xsl:element>
   </xsl:variable>


   <xsl:for-each select="//composition[era:typeFromExtendedType(@type)=current()/@name]">
      <!-- <xsl:message> Creating from '<xsl:value-of select="@name"/></xsl:message>'' -->
      <xsl:element name="dependency">
               <xsl:element name="name">
                  <xsl:value-of select="if (@inverse) 
                                        then @inverse 
                                        else if (@name) then concat(@name,$postfixForInverseNameConstruction) 
                                        else '..'" />
               </xsl:element>
         <xsl:copy-of select="$cardinality"/>
         <xsl:element name="type">
            <!-- 29/06/2023 BUT... WHY DID I WRITE IT LIKE THIS PREVIOUSLY?
            <xsl:value-of select="ancestor::*[self::entity_type|self::absolute][1]/@name"/>
         -->
            <xsl:value-of select="parent::*[self::entity_type|self::absolute]/@name"/>
         </xsl:element>
         <xsl:if test="identifying">    
               <xsl:element name="identifying"/>   
         </xsl:if>
         <xsl:element name="inverse_of">
            <xsl:value-of select="@name"/>
         </xsl:element>
      </xsl:element>
   </xsl:for-each>
</xsl:template>

<xsl:template  match="*[ self::reference
                        |self::composition
                        | self::constructed_relationship
                       ]" 
                    mode="parse__main_pass">
   <xsl:copy>
      <xsl:apply-templates select="@name|@id|@type|@inverse|@diagonal|@riser|@key" mode="parse__main_pass"/> 
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
      <xsl:variable name="type" select="era:typeFromExtendedType(@type)"/>
      <xsl:element name="type">
         <xsl:value-of select="$type"/>
      </xsl:element>

      <!-- start of change of 21 Jan 2025 -->
      <xsl:if test="@injective">
         <!-- <xsl:message>in parser module line 187 injective attribute value is <xsl:value-of select="@injective"/></xsl:message> -->
         <xsl:element name="injective">
            <xsl:value-of select="@injective"/>
         </xsl:element>
      </xsl:if>
      <xsl:if test="@surjective">
         <!-- <xsl:message>in parser module line 187 surjective attribute value is <xsl:value-of select="@surjective"/></xsl:message> -->
         <xsl:element name="surjective">
            <xsl:value-of select="@surjective"/>
         </xsl:element>
      </xsl:if>
      <!-- end of change of 21 Jan 2025-->

      <xsl:if test="   ((self::reference or self::constructed_relationship) and parent::identifying)
                    or (self::composition and //identifying/context/../../@name=$type)
                    ">  
                    <!-- this above had the compostion code commented out
                          I have reinstated this logic as part of change 16-Nov-2024 --> 
         <xsl:element name="identifying"/>
      </xsl:if>
      <xsl:apply-templates select="@xpath_evaluate" mode="parse__main_pass"/>
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
                                     else if (@name) then concat(@name,$postfixForInverseNameConstruction)
                                     else '..'               (: possible number required XXXXXXXXXXX:)
                                     "/>
            </xsl:element>
         </xsl:when>
         <xsl:when test="self::reference">
            <xsl:if test="not(@diagonal)">
               <xsl:element name="diagonal">
                  <xsl:element name="theabsolute"/>
               </xsl:element>
            </xsl:if>
            <xsl:if test="not(@riser)">
               <xsl:element name="riser">
                  <xsl:element name="theabsolute"/>
               </xsl:element>
            </xsl:if>
         </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="parse__main_pass"/> <!-- now processing non-attributes -->
   </xsl:copy>
</xsl:template>

<xsl:template  match="context" mode="parse__main_pass">
   <!-- <xsl:message>Context has type <xsl:value-of select="@type"/></xsl:message> -->
   <xsl:element name="dependency">
      <xsl:if test="not(@name)">
         <xsl:variable name="comp" 
                       as="element(composition)?"
                       select="//composition[era:typeFromExtendedType(@type)=current()/ancestor-or-self::entity_type[1]/@name]"/>
                       <!-- Note: 21 Jan 2025 changed not to error if no composition and no name -->

         <xsl:element name="name">
               <xsl:value-of select="if ($comp/@inverse) 
                                    then $comp/@inverse
                                    else if ($comp/@name) 
                                    then concat($comp/@name,$postfixForInverseNameConstruction) 
                                    else '..'"/>
         </xsl:element>

      </xsl:if>
      <xsl:apply-templates select="@*" mode="parse__main_pass"/> <!-- process attributes first -->
      <xsl:choose>
         <xsl:when test="@type">
            <xsl:element name="cardinality">
               <xsl:element name="{if (substring(type,string-length(@type))='?')
                                   then 'ZeroOrOne'
                                   else 'ExactlyOne'
                                  }"/>

            </xsl:element>
            <xsl:element name="type">
               <xsl:value-of select="era:typeFromExtendedType(@type)
                                     "/>
            </xsl:element>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="incoming_composition" 
                          as="element(composition)*"
                          select="//composition[@type=current()/../@name]"/>
            <xsl:element name="cardinality">
                  <xsl:element name="{if (count($incoming_composition) &gt; 1)
                                        then 'ZeroOrOne'
                                        else 'ExactlyOne'}
                                          "/>
            </xsl:element>
            <xsl:element name="type">
                  <xsl:value-of select="$incoming_composition/../@name"/>
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
      <xsl:apply-templates select="*" mode="parse__main_pass"/> <!-- now processing non-attributes -->
   </xsl:element>
</xsl:template>

<xsl:template  match="pullback|copy" 
                    mode="parse__main_pass">
   <xsl:copy>
      <xsl:apply-templates select="@along|@riser2|@projection_rel|@diagonal|@type" mode="parse__main_pass"/> 
   </xsl:copy>
</xsl:template>

<xsl:template match="@diagonal|@riser|@along|@key|@riser2|@equivalent_path" mode="parse__main_pass">
   <xsl:element name="{name()}">
         <xsl:apply-templates select="." mode="parse_navigation"/>
   </xsl:element>
</xsl:template>

<xsl:template match="(pullback|copy)/(@projection_rel|@type)" mode="parse__main_pass">
   <xsl:element name="{name()}">
         <xsl:value-of select="."/>
   </xsl:element>
</xsl:template>


<xsl:template match="attribute" 
                    mode="parse__main_pass">
   <xsl:copy>
      <xsl:if test="@name">
         <xsl:element name="name"> 
            <xsl:value-of select="@name"/>
         </xsl:element>
      </xsl:if>
      <xsl:if test="@type">
         <xsl:element name="type">
            <!-- 23-MAR-2023 modified to plant element (not text node)  -->
            <xsl:variable name="typename"
                          as="xs:string"
                          select="if (substring(@type,string-length(@type))='?')
                                  then substring(@type,1,string-length(@type)-1)
                                  else @type"/>
            <xsl:element name="{$typename}"/>
         </xsl:element>
      </xsl:if>
      <xsl:if test="substring(@type,string-length(@type))='?'">
         <xsl:element name="optional"/>
      </xsl:if>

      <xsl:if test="parent::identifying">    <!-- TBD probably need a bit more than this -->
                                             <!-- Hmmmm ... not sure -->
         <xsl:element name="identifying"/>
      </xsl:if>
      <xsl:apply-templates select="node()" 
                           mode="parse__main_pass"/>   <!-- reintrodcued becuase xmlRepresenttion going missing -->
   </xsl:copy>
</xsl:template>

<xsl:template match="constructed_relationship" mode="parse__main_pass">
   <xsl:copy>
      <xsl:apply-templates select="@path" mode="parse_navigation"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="@path|@diagonal|@riser|@along|@riser2|@key|@equivalent_path" mode="parse_navigation">
   <xsl:variable name="text" as="xs:string" select="."/>
   <!--<xsl:message>text of navigation is <xsl:value-of select="$text"/></xsl:message>-->
   <xsl:choose>
      <xsl:when test="$text='.'">
         <xsl:element name="identity"/>
      </xsl:when>
      <xsl:when test="$text='^'">
         <xsl:element name="theabsolute"/>
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
