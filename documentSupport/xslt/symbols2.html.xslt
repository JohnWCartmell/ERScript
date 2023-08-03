<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="alpha">
        <xsl:text>&#945;</xsl:text>
    </xsl:template>

    <xsl:template match="beta">
        <xsl:text>&#946;</xsl:text>
    </xsl:template>

    <xsl:template match="circ">
        <xsl:text>&#8728;</xsl:text>
    </xsl:template>
    
    <xsl:template match="containedin">
        <xsl:text>&#8838;</xsl:text>
    </xsl:template>
    
    <xsl:template match="degreecelsius">
        <xsl:text>&#8451;</xsl:text>
    </xsl:template>
    
    <xsl:template match="emdash">
        <xsl:text>&#8212;</xsl:text>
    </xsl:template> 

    <xsl:template name="leftdoublequote">
        <xsl:text>&#8220;</xsl:text>
    </xsl:template>

        <xsl:template name="leftsinglequote">
        <xsl:text>&#8216;</xsl:text>
    </xsl:template>
    
    <xsl:template match="pi">
        <xsl:text>&#960;</xsl:text>
    </xsl:template>

    <xsl:template match="relationship">
        <xsl:text>&#8954;&#9473;</xsl:text>
    </xsl:template>

    <xsl:template name="rightdoublequote">
        <xsl:text>&#8221;</xsl:text>
    </xsl:template>

    <xsl:template name="rightsinglequote">
        <xsl:text>&#8217;</xsl:text>
    </xsl:template>

    <xsl:template match="scopeequiv">
        <xsl:text>&#x2272;</xsl:text>
    </xsl:template>
    
    <xsl:template match="scopesubject">
        <xsl:text>&#x021B7;</xsl:text>
    </xsl:template>

    <xsl:template match="scopeup">
        <!-- up arrow <xsl:text>&#x2B61;</xsl:text> -->
        <xsl:text>&#x2025;</xsl:text>
    </xsl:template>

    <xsl:template name="sectionsign">
        <xsl:text>&#167;</xsl:text>
    </xsl:template>
    
    <xsl:template match="squarecontainedin">
        <xsl:text>&#8849;</xsl:text>
    </xsl:template>
    

    
    
    
</xsl:transform>
