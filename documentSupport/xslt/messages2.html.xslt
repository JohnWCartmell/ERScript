<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="message_structure">
        <xsl:element name="div">
           <xsl:attribute name="class" select="'message_structure'"/>
           <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="message_structure/rule">
        <xsl:element name="table">
            <xsl:attribute name="class" select="'rule'"/>
            <xsl:for-each select="rhs/(terminal|non-terminal)">
                <xsl:element name="tr" >
                    <xsl:element name="td">
                        <xsl:if test="position()=1">
                           <xsl:value-of select="../../name"/>
                           =>
                        </xsl:if>
                    </xsl:element>
                    <xsl:element name="td">
                        <xsl:element name="span">
                             <xsl:attribute name="class" select="if (identifying) then 'terminal-identifying' else name()"/>
                             <xsl:value-of select="name"/>
                                                     <xsl:if test="optional">
                            <xsl:text>?</xsl:text>
                        </xsl:if>
                        <xsl:if test="repeating">
                            <xsl:text>*</xsl:text>
                        </xsl:if>
                        </xsl:element>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
</xsl:transform>
