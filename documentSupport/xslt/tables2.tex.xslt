<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <xsl:template match="table">
        <xsl:text>\begin{tabular}{</xsl:text>
            <xsl:for-each select="columns/col">
                <xsl:value-of select="' ' || align/text() || ' '"/>
            </xsl:for-each>
            <xsl:text>}</xsl:text>
            <xsl:call-template name="newline"/>
            <xsl:apply-templates select="thead"/>
            <xsl:call-template name="newline"/>
            <xsl:text>\hline</xsl:text>
            <xsl:call-template name="newline"/>
            <xsl:apply-templates select="tbody"/>
        <xsl:text>\end{tabular}</xsl:text>
    </xsl:template>

    <xsl:template match="thead">
        <xsl:for-each select="tr">
            <xsl:for-each select="th" >
                <xsl:apply-templates/>
                <xsl:value-of select="if (not(position()=last())) then ' &amp; ' else ''" />
            </xsl:for-each>
            <xsl:text>\\</xsl:text>
            <xsl:call-template name="newline" />
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="th">
        <xsl:message terminate="yes"> Out of spec</xsl:message>
    </xsl:template>

    <xsl:template match="tbody">
        <xsl:for-each select="tr">
            <xsl:for-each select="td" >
                <xsl:apply-templates/>
                <xsl:value-of select="if (not(position()=last())) then ' &amp; ' else ''"/>
            </xsl:for-each>
            <xsl:text>\\</xsl:text>
            <xsl:call-template name="newline" />
        </xsl:for-each>
    </xsl:template>


</xsl:transform>