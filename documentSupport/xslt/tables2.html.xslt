<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <xsl:template match="table">
        <!-- <xsl:message>******************** TABLE columns is <xsl:copy-of select="columns"/></xsl:message> -->
        <xsl:element name="table">
            <xsl:copy-of select="@*"/><!-- this copies all its attributes -->
            <xsl:apply-templates select="thead|tbody"/>
        </xsl:element>
    </xsl:template>

    <!-- want to add rowspan and colspan (see n above) to <td> but having <text> everywhere
   very hard work  therefore pass all attributes through using xslt:copy-of!!-->
    <xsl:template match="th">
        <xsl:copy >
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="thead">
        <xsl:element name="thead">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="*" />
        </xsl:element>
    </xsl:template>

    <!-- want to add rowspan and colspan (see n above) to <td> but having <text> everywhere
   very hard work  therefore pass all attributes through using xslt:copy-of!!-->
    <xsl:template match="td">
        <xsl:variable name="colno" as="xs:integer" select="position()"/>
        <!-- <xsl:message>***** position of td is <xsl:value-of select="$colno"/></xsl:message> -->
        <xsl:copy>
            <!-- <xsl:message>column style is <xsl:copy-of select="ancestor::table/columns/col[$colno]"/></xsl:message> -->
            <!-- <xsl:message>class attribute value is '<xsl:value-of select="ancestor::table/columns/col[$colno]/@class"/>'</xsl:message> -->
            <xsl:copy-of select="ancestor::table/columns/col[$colno]/@class"/>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tr">
        <xsl:element name="tr">
            <xsl:apply-templates select="*"/>
        </xsl:element>
    </xsl:template>

</xsl:transform>