
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
            id:string             # a short id of form R<n> for some n
-->

<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:fn="http://www.w3.org/2005/xpath-functions"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"       
        xmlns:xlink="http://www.w3.org/TR/xlink"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel" >
<xsl:template match="@*|node()" mode="initial_enrichment_first_pass">
  <xsl:copy>
     <xsl:apply-templates select="@*|node()" mode="initial_enrichment_first_pass"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="entity_model"
              mode="initial_enrichment_first_pass"> 
  <xsl:copy>
    <!-- add prefixes for namespaces -->
    <xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'"/>
    <xsl:namespace name="era" select="'http://www.entitymodelling.org/ERmodel'"/>
    <xsl:namespace name="er-js" select="'http://www.entitymodelling.org/ERmodel/javascript'"/>  
    <xsl:apply-templates mode="initial_enrichment_first_pass"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="entity_type
                     [not(id)]
                    "
              mode="initial_enrichment_first_pass">
              <xsl:message>enriching entity type</xsl:message>
   <xsl:copy>
       <id>
          <xsl:text>E</xsl:text>  <!-- S for structure -->
          <xsl:number count="entity_type" level="any" />
       </id>
       <xsl:apply-templates select="@*|node()" mode="initial_enrichment_first_pass"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="group
                     [not(id)]
                    "
              mode="initial_enrichment_first_pass">
   <xsl:copy>
       <id>
          <xsl:text>G</xsl:text>  <!-- S for structure -->
          <xsl:number count="entity_type" level="any" />
       </id>
       <xsl:apply-templates select="@*|node()" mode="initial_enrichment_first_pass"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="composition
                     [not(id)]
                    "
              mode="initial_enrichment_first_pass">
   <xsl:copy>
       <id>
          <xsl:text>S</xsl:text>  <!-- S for structure -->
          <xsl:number count="composition" level="any" />
       </id>
       <xsl:apply-templates select="@*|node()" mode="initial_enrichment_first_pass"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="reference
                     [not(id)]" 
              mode="initial_enrichment_first_pass">
   <xsl:copy>
       <id>
          <xsl:text>R</xsl:text>
          <xsl:number count="reference" level="any" />
       </id>
       <xsl:apply-templates select="@*|node()" mode="initial_enrichment_first_pass"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="attribute
                     [not(id)]" 
              mode="initial_enrichment_first_pass">
   <xsl:copy>
       <id>
          <xsl:text>A</xsl:text>
          <xsl:number count="attribute" level="any" />
       </id>
       <xsl:apply-templates select="@*|node()" mode="initial_enrichment_first_pass"/>
    </xsl:copy>
</xsl:template>
</xsl:transform>