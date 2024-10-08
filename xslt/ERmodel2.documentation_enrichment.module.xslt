
<!-- In the first pass add namespace definitions  and
  create the following derived attributes (These attributes are non-persistent. )
     
    absolute => 
            id : string          # constant value "A" 

    group => 
            id: string            # a short id of form G<n> for some n

    entity_type => 
            id: string            # a short id of form E<n> for some n

    composition => 
            id:string             # a short id of form S<n> for some n

    reference => 
            id:string             # a short id of form R<n> for some n

    attribute => 
            id:string             # a short id of form A<n> for some n
-->

<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xmlns:fn="http://www.w3.org/2005/xpath-functions"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"       
        xmlns:xlink="http://www.w3.org/TR/xlink"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel" >
<!--
   entity_type|group|composition|absolute
    
         absolute => 

     entity_type =>
            id:string             # a short id of the form E<n> for some n 

    attribute => 
            id:string             # a short id of form A<n> for some n
            display_text: string  # is <attrname>:<attrtype>

     composition => 
            id:string             # a short id of form S<n> for some n
            display_text: string  # is <relname>:<dest et name> {|?|+|*}

      dependency => 
            id:string             # defined as id of inverse composition

     reference =>
            id:string             # a short id of form p<n> for some n, some prefix p
            scope_display_text : string r,;
                                 # text presentation of the scope constraint
                                 # using ~/<riser text>=<diag text>
                                 # using D:<riser text>=S:<diag text>
            display_text: string  # is <relname>:<dest et name> {|?|+|*}

      navigation ::= identity | theabsolute | join | aggregate | component
      
         navigation =>  display_text : string  # text presentation of the navigation using
                                               #       / for join
                                               #       | for aggregation  ?
                                               #       . for the identity
                                               #       ^ for the absolute
                        rel_id_csl : string    # comma separated list of rel ids 
                        rel_inv_csl : string   # array of 1's and -1's   # -1 for a dependency 
                                                                         # 1 otherwise
                                                                         # used for direction of 
                                                                         # travel in animation


-->
<!-- these are found in in ERAmodel2.diagram.module
<xsl:key name="AllRelationshipBySrcTypeAndName"
         match="reference|composition|dependency|constructed_relationship"
         use ="../descendant-or-self::entity_type/era:packArray((name,current()/name))" />

<xsl:key name="CompositionByDestTypeAndInverseName" 
         match="composition" 
         use="concat(type,':',inverse)"/>
-->
<xsl:template name="documentation_enrichment">
   <xsl:param name="document"/>
   <xsl:variable name ="next">
      <xsl:for-each select="$document">
         <xsl:copy>
           <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
         </xsl:copy>
      </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="result">
      <xsl:choose>
         <xsl:when test="not(deep-equal($document,$next))">     
            <xsl:message> changed in documentation enrichment recursive</xsl:message>
            <xsl:call-template name="documentation_enrichment">
               <xsl:with-param name="document" select="$next"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message> unchanged fixed point of documentation enrichment recursive </xsl:message>
            <xsl:copy-of select="$document"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>  
   <xsl:copy-of select="$result"/>
</xsl:template>

<xsl:template match="@*|node()" mode="documentation_enrichment_recursive">
  <xsl:copy>
     <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="entity_model"
              mode="documentation_enrichment_recursive"> 
  <xsl:copy>
    <!-- add prefixes for namespaces -->
    <xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'"/>
    <xsl:namespace name="era" select="'http://www.entitymodelling.org/ERmodel'"/>
    <xsl:namespace name="er-js" select="'http://www.entitymodelling.org/ERmodel/javascript'"/>  
    <xsl:apply-templates mode="documentation_enrichment_recursive"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="entity_type
                     [not(id)]
                    "
              mode="documentation_enrichment_recursive" priority="1">
   <xsl:copy>
       <id>
          <xsl:text>E</xsl:text>  <!-- S for structure -->
          <xsl:number count="entity_type" level="any" />
       </id>
       <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="group
                     [not(id)]
                    "
              mode="documentation_enrichment_recursive" priority="1">
   <xsl:copy>
       <id>
          <xsl:text>G</xsl:text>  <!-- S for structure -->
          <xsl:number count="entity_type" level="any" />
       </id>
       <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="composition
                     [not(id)]
                    "
              mode="documentation_enrichment_recursive"  priority="1">
   <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
        <xsl:variable name="dependency_relid_prefix" as="xs:string" 
                     select="if(/entity_model/presentation/diagram/dependency_relid_prefix) 
                             then /entity_model/presentation/diagram/dependency_relid_prefix else 'd'"/>
       <xsl:variable name="reference_relid_prefix" as="xs:string" 
                     select="if(/entity_model/presentation/diagram/reference_relid_prefix) 
                             then /entity_model/presentation/diagram/reference_relid_prefix else 'r'"/>
        <xsl:variable name="numeric">
            <xsl:choose>
                <xsl:when test="$dependency_relid_prefix = $reference_relid_prefix">
                    <xsl:number count="composition|reference[. &lt;&lt; key('ReferenceBySrcTypeAndName',concat(type,':',inverse))]" level="any" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:number count="composition" level="any" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <id>
          <xsl:value-of select="$dependency_relid_prefix || $numeric"/>        
       </id>
    </xsl:copy>
</xsl:template>

<xsl:template match="dependency
                     [not(id)]
                     [key('CompositionByDestTypeAndInverseName',concat(../name,':',name))/id]
                    "
              mode="documentation_enrichment_recursive"  priority="1">
   <xsl:copy>
       <id>
          <xsl:value-of select="key('CompositionByDestTypeAndInverseName',concat(../name,':',name))/id"/>
       </id>
       <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
    </xsl:copy>
</xsl:template>


<!-- a reference and its inverse need be given the same id -->
<!-- first allocate id to a reference that precedes its inverse in the document -->
<!-- in the next pass allocate an id equal to the id of the inverse -->
<xsl:template match="reference
                     [not(id)]
                     [. &lt;&lt; key('ReferenceBySrcTypeAndName',concat(type,':',inverse))]
                     " 
              mode="documentation_enrichment_recursive"  priority="1">
   <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
        <xsl:variable name="dependency_relid_prefix" as="xs:string" 
                     select="if(/entity_model/presentation/diagram/dependency_relid_prefix) 
                             then /entity_model/presentation/diagram/dependency_relid_prefix else 'd'"/>
       <xsl:variable name="reference_relid_prefix" as="xs:string" 
                     select="if(/entity_model/presentation/diagram/reference_relid_prefix) 
                             then /entity_model/presentation/diagram/reference_relid_prefix else 'r'"/>
        <xsl:variable name="numeric">
            <xsl:choose>
                <xsl:when test="$dependency_relid_prefix = $reference_relid_prefix">
                    <xsl:number count="composition|(reference[. &lt;&lt; key('ReferenceBySrcTypeAndName',concat(type,':',inverse))])" level="any" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:number count="reference[. &lt;&lt; key('ReferenceBySrcTypeAndName',concat(type,':',inverse))]" level="any" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <id>
          <xsl:value-of select="$reference_relid_prefix || $numeric"/>        
       </id>
    </xsl:copy>
</xsl:template>

<!-- This  will be the second pass -->
<xsl:template match="reference
                     [not(id)]
                     [key('ReferenceBySrcTypeAndName',concat(type,':',inverse))/id]
                    "
              mode="documentation_enrichment_recursive"  priority="1">
   <xsl:copy>
       <id>
          <xsl:value-of select="key('ReferenceBySrcTypeAndName',concat(type,':',inverse))/id"/>
       </id>
       <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
    </xsl:copy>
</xsl:template>


<xsl:template match="attribute
                     [not(id)]" 
              mode="documentation_enrichment_recursive"  priority="1">
   <xsl:copy>
       <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
       <id>
          <xsl:text>A</xsl:text>
          <xsl:number count="attribute" level="any" />
       </id>
    </xsl:copy>
</xsl:template>

<!-- FOLLOWING HAS BEEN RECODED IN meta model of entity logic fer future use-->

<!--
<xsl:template match="absolute
                     [not(identifier)]
                     "
              mode="documentation_enrichment_recursive"
              priority="2">
  <xsl:copy>
      <identifier>
          <xsl:value-of select="'^'"/>
      </identifier>
      <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
  </xsl:copy>
</xsl:template>
-->



<!--
<xsl:template match="attribute
                     [not(identifier)]
                     [../identifier]
                     "
              mode="documentation_enrichment_recursive"
              priority="2">
  <xsl:copy>
      <identifier >
          <xsl:value-of select="concat(../identifier,'.',name)"/>
      </identifier>
      <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="*[self::reference|self::composition]
                     [not(identifier)]
                     [../identifier]
                     [name]
                     "
              mode="documentation_enrichment_recursive"
              priority="2">
  <xsl:copy>
      <identifier >
          <xsl:value-of select="concat(../identifier,'.',name)"/>
      </identifier>
      <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="*[self::reference|self::composition]
                     [not(identifier)]
                     [../identifier]
                     [not(name)]
                     [//entity_type[name=current()/type]/identifier]
                     "
              mode="documentation_enrichment_recursive"
              priority="2">
  <xsl:copy>
      <identifier >
          <xsl:value-of select="concat(../identifier,':',
                                       //entity_type[name=current()/type]/identifier
                                       )
            "/>
      </identifier>
      <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
  </xsl:copy>
</xsl:template>

-->


<!-- scope_display_text  -->
<xsl:template match="reference
                     [not(scope_display_text)]
                     [riser/*/display_text]
                     [diagonal/*/display_text]
              "
              priority="3"
              mode="documentation_enrichment_recursive"> 
  <xsl:copy>
     <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
          <xsl:variable name="operator" select="if (cardinality/ZeroOrOne or cardinality=ZeroOneOrMore) then '=' else 'LTEQ'"/>  
                   <!-- 13-Oct-2017  'LTEQ' code will be translated by ERmodel2.svg.xslt -->             
                  <!-- 16 August 2022 - UPGRADED to latest metamodel  cardinality but note code wasn't correct to start with -->
          <scope_display_text>
             <xsl:value-of select="concat('d:',riser/*/display_text,'=s:',diagonal/*/display_text)"/>
             <!-- was        <xsl:value-of select="concat('~/',riser/*/display_text,'=',diagonal/*/display_text)"/> -->
             <!-- In future would we   want to type the * in riser/*/display_text to ease
                  static checking. On the otherhand the dest of riser is known to be navigation.
                  The above is equivalent to
                       riser/*[self::navigation]/display_text
                  Except that need to replace navigation by all its concrete subtypes.0
                  Arguably writing it that way might look we were applying a filter which we are not.
                  Question: in macro language should I not write riser/display_text and
                  know that the intermediate * will be generated in the xpath. Because the /
                  is not then the zptha ? then maybe we should surround each navigation by #'s'
                  and write the command macro as
                  "concat('d:',#riser/display_text#,'=s:',#diagonal/display_text#)"   
             -->
          </scope_display_text>
  </xsl:copy>
</xsl:template>

<!-- display_text  starts here -->


<xsl:template match="attribute
                    [not(display_text)]
                    " 
              mode="documentation_enrichment_recursive"  priority="13">

    <!-- <xsl:message>attribute named <xsl:value-of select="name"/></xsl:message> -->
    <!-- <xsl:message>attribute type '<xsl:value-of select="type/*/name()"/>'</xsl:message> -->
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
      <display_text>
         <xsl:value-of select="concat(name, ' : ', type/*/name())"/>
         <xsl:if test="optional"><xsl:text>?</xsl:text></xsl:if>
      </display_text>
    </xsl:copy>
</xsl:template>  


<xsl:template match="identity
                     [not(display_text)]
                    " 
              priority="8"
              mode="documentation_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
      <display_text>
         <xsl:value-of select="'.'"/>
      </display_text>
     <!--becomes
      <optional>
        <default>
            <macro>'.'</macro>
        </default>
      </optional>
      -->
   </xsl:copy>
</xsl:template>

<xsl:template match="theabsolute
                     [not(display_text)]
                     " 
              priority="11"
              mode="documentation_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
      <display_text>
         <xsl:value-of select="'^'"/>
      </display_text>
      <!-- similar to previous -->
   </xsl:copy>
</xsl:template>

<xsl:template match="join
                     [not(display_text)]
                     [every $component in component satisfies $component/display_text]
                     "
                     priority="10"
                     mode="documentation_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
      <display_text>
         <xsl:value-of select="string-join(component/display_text,'/')"/>
      </display_text>
      <!-- in future becomes
      <optional>
        <default>
           <macro>string-join(#component/display_text#,'/')</macro>
        </default>
      </optional>
      -->
   </xsl:copy>
</xsl:template>

<xsl:template match="component
                     [not(display_text)]" 
                     priority="11"
                     mode="documentation_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
      <display_text>
         <xsl:value-of select="rel"/>
      </display_text>
      <!-- oooooo - this will be ambiguous in macro language - is rel the relationship
                     or the foreign key attribute? 
                     Get away with it in this case we can represent as
      <optional>
        <default>
           <macro>rel</macro>            ............ note no use of #'s'
        </default>
      </optional>

      Could also ignore the foreign key and specify more sematically(though less efficient)
      <optional>
        <default>
           <macro>#rel/name#</macro>        
        </default>
      </optional>   

      Consider though use of % for all attributes. 
      -->
   </xsl:copy>
</xsl:template>

<xsl:template match="*[self::reference|self::composition]
                    [not(display_text)]
                    [cardinality/ZeroOrOne]
                    " 
              mode="documentation_enrichment_recursive"  priority="13">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
      <display_text>
         <xsl:value-of select="concat(name, ' : ', type,'?')"/>
      </display_text>
    </xsl:copy>
</xsl:template>  

<xsl:template match="*[self::reference|self::composition]
                    [not(display_text)]
                    [cardinality/ExactlyOne]
                    " 
              mode="documentation_enrichment_recursive"  priority="13">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
      <display_text>
         <xsl:value-of select="concat(name, ' : ', type)"/>
      </display_text>
    </xsl:copy>
</xsl:template>

<xsl:template match="*[self::reference|self::composition]
                    [not(display_text)]
                    [cardinality/ZeroOneOrMore]
                    " 
              mode="documentation_enrichment_recursive"  priority="13">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
      <display_text>
         <xsl:value-of select="concat(name, ' : ', type,'*')"/>
      </display_text>
    </xsl:copy>
</xsl:template>

<xsl:template match="*[self::reference|self::composition]
                    [not(display_text)]
                    [cardinality/OneOrMore]
                    " 
              mode="documentation_enrichment_recursive"  priority="13">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
      <display_text>
         <xsl:value-of select="concat(name, ' : ', type,'+')"/>
      </display_text>
    </xsl:copy>
</xsl:template>
<!-- display_text  ends -->

<!-- rel_id_xsl -->

<xsl:template match="identity
                     [not(rel_id_csl)]
                    " 
              priority="8"
              mode="documentation_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
      <rel_id_csl>
         <xsl:value-of select="''"/>
      </rel_id_csl>
      <rel_inv_csl>
         <xsl:text>1</xsl:text>
      </rel_inv_csl>
   </xsl:copy>
</xsl:template>

<xsl:template match="theabsolute
                     [not(rel_id_csl)]
                     " 
              priority="9"
              mode="documentation_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
<!--       <rel_id_csl>
         <xsl:value-of select="'''??'''"/>
      </rel_id_csl> -->
      <rel_id_csl/>
      <rel_inv_csl>
         <xsl:text>1</xsl:text>
      </rel_inv_csl>

   </xsl:copy>
</xsl:template>

<xsl:template match="join
                     [not(rel_id_csl)]
                     [every $component in component satisfies $component/rel_id_csl]
                     "
                     priority="10"
                     mode="documentation_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
      <rel_id_csl>
         <xsl:value-of select="string-join(component/rel_id_csl,',')"/>
      </rel_id_csl>
        <rel_inv_csl>
         <xsl:value-of select="string-join(component/rel_inv_csl,',')"/>
      </rel_inv_csl>
   </xsl:copy>
</xsl:template>

<xsl:template match="component
                     [src]
                     [key('AllRelationshipBySrcTypeAndName',
                                            era:packArray((src,rel)))/id]
                     [not(rel_id_csl)]" 
                     priority="11"
                     mode="documentation_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
      <rel_id_csl>
        
        
        <xsl:message>src is <xsl:value-of select="src"/> rel is <xsl:value-of select="rel"/></xsl:message>
        <xsl:message>retreived id is <xsl:value-of select="key('AllRelationshipBySrcTypeAndName',
                                            era:packArray((src,rel)))/id"/> </xsl:message>
        <xsl:message>cardinality <xsl:value-of select="count(key('AllRelationshipBySrcTypeAndName',
                                            era:packArray((src,rel))))"/> </xsl:message>
        

         <xsl:value-of select="concat('''',
                                      key('AllRelationshipBySrcTypeAndName',
                                            era:packArray((src,rel)))/id,
                                      '''')"/>
      </rel_id_csl>
      <rel_inv_csl>
         <xsl:value-of select="concat('''',
                                      key('AllRelationshipBySrcTypeAndName',
                                            era:packArray((src,rel)))/
                                               (if(self::dependency) then -1 else 1),
                                      '''')"/>
      </rel_inv_csl>
   </xsl:copy>
</xsl:template>

<!-- rel_id_csl ends -->






</xsl:transform>