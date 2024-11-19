

<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xmlns:fn="http://www.w3.org/2005/xpath-functions"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"       
        xmlns:xlink="http://www.w3.org/TR/xlink"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel" >
<!--


     composition => 
            injective : boolean,  # change of 14-Nov-2024
            surjective : boolean  # change of 14-Nov-2024

      dependency => 
            injective : boolean,  # change of 14-Nov-2024
            surjective : boolean  # change of 14-Nov-2024

     reference =>
            injective : boolean,  # change of 14-Nov-2024
            surjective : boolean  # change of 14-Nov-2024

-->

<xsl:template match="@*|node()" mode="implementation_of_defaults_enrichment">
  <xsl:copy>
     <xsl:apply-templates select="@*|node()" mode="implementation_of_defaults_enrichment"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="composition
                     [not(injective)][not(surjective)]
                     " 
              mode="implementation_of_defaults_enrichment"  priority="100">
              <!-- SHOULD include dependencies as well !!!!!!!!!!!-->
   <xsl:copy>
       <xsl:apply-templates select="@*|node()" mode="implementation_of_defaults_enrichment"/>

  <xsl:variable name="inverse" 
                as="element()?"
                select="if (inverse) 
                        then //dependency [../name=current()/type]
                                               [name=current()/inverse]
                                               [type=current()/../name]
                        else ()" />  <!-- explained change of 1-Aug-2024 -->
                                     <!-- adapted change 16-Nov-2024 -->


    <!-- below is rather odd incase no inverse specified but is transcribed
        from the preexisting logic in ERmodel2.diagram.xslt 
        Seems particularly strange for reference relationships
        Are we wedded to it?
    -->
    <xsl:variable name="surjective" as="xs:boolean"
                select="not($inverse/cardinality)
                        or $inverse/cardinality/ExactlyOne
                        or $inverse/cardinality/OneOrMore
                       " />
       <surjective>
           <xsl:value-of select="$surjective"/>
       </surjective>
    </xsl:copy>
</xsl:template>


<xsl:template match="reference
                     [not(injective)][not(surjective)]
                     " 
              mode="implementation_of_defaults_enrichment"  priority="100">
              <!-- SHOULD include dependencies as well !!!!!!!!!!!-->
   <xsl:copy>
       <xsl:apply-templates select="@*|node()" mode="implementation_of_defaults_enrichment"/>
    <xsl:variable name="inverse" 
                as="element()?"
                select="if (inverse) 
                        then //reference [../name=current()/type]
                                               [name=current()/inverse] 
                        else ()" />  <!-- explained change of 1-Aug-2024 -->
                                     <!-- adapted change 16-Nov-2024 -->
    <xsl:variable name="injective" as="xs:boolean"
                select="$inverse/cardinality/ZeroOrOne
                            or $inverse/cardinality/ExactlyOne
                        " />

    <!-- below is rather odd incase no inverse specified but is transcribed
        from the preexisting logic in ERmodel2.diagram.xslt 
        Seems particularly strange for reference relationships
        Are we wedded to it?
    -->
    <xsl:variable name="surjective" as="xs:boolean"
                select="$inverse/cardinality/ExactlyOne
                        or $inverse/cardinality/OneOrMore
                       " />

       <injective>
           <xsl:value-of select="$injective"/>
       </injective>
       <surjective>
           <xsl:value-of select="$surjective"/>
       </surjective>
    </xsl:copy>
</xsl:template>

</xsl:transform>