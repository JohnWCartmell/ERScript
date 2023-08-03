<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="table">
        <xsl:element name="table">
            <xsl:copy-of select="@*"/>
            <!-- this copies all its attributes -->
            <xsl:if test="class">
                <xsl:attribute name="class" select="class"/>
            </xsl:if>
            <xsl:apply-templates select="thead|tbody"/>
        </xsl:element>
    </xsl:template>

    <!-- want to add rowspan and colspan (see n above) to <td> but having <text> everywhere
   very hard work  therefore pass all attributes through using xslt:copy-of!!-->
    <xsl:template match="th">
        <xsl:copy >
            <!-- this copies element name -->
            <xsl:copy-of select="@*"/>
            <!-- this copies all its attributes -->
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="thead">
        <xsl:element name="thead">
            <xsl:if test="class">
                <xsl:attribute name="class" select="class"/>
            </xsl:if>
            <xsl:apply-templates select="*[not(self::class)]" />
        </xsl:element>
    </xsl:template>

    <!-- want to add rowspan and colspan (see n above) to <td> but having <text> everywhere
   very hard work  therefore pass all attributes through using xslt:copy-of!!-->
    <xsl:template match="td">
        <xsl:variable name="colno" select="position()"/>
        <xsl:copy >
            <!-- this copies element name -->
            <xsl:variable name="class" select="ancestor::table/columnstyles/col[$colno]/class"/>
            <xsl:if test="not($class='')">
                <xsl:attribute name="class" select="$class"/>
            </xsl:if>
            <xsl:copy-of select="@*"/>
            <!-- this copies all its attributes -->
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tr">
        <xsl:element name="tr">
            <xsl:apply-templates select="*[not(self::class)]"/>
        </xsl:element>
    </xsl:template>

</xsl:transform>