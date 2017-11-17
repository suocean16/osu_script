<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:template match="/">

<alerts>
<xsl:for-each select="resultset/row">
    <alert>
        <date-time><xsl:value-of select="field[@name='date-time']"/></date-time>
        <alert-msg><xsl:value-of select="field[@name='alert-msg']"/></alert-msg>
        <ip><xsl:value-of select="field[@name='ip']"/></ip>
        <remote-name><xsl:value-of select="field[@name='remote-name']"/></remote-name>
        <request><xsl:value-of select="field[@name='request']"/></request>
        <action><xsl:value-of select="field[@name='action']"/></action>
        <request-URI><xsl:value-of select="field[@name='request-URI']"/></request-URI>
        <method><xsl:value-of select="field[@name='method']"/></method>
        <status-code><xsl:value-of select="field[@name='status-code']"/></status-code>
        <reason><xsl:value-of select="field[@name='reason']"/></reason>
        <reason-code><xsl:value-of select="field[@name='reason-code']"/></reason-code>
        <content-type><xsl:value-of select="field[@name='content-typ']"/></content-type>
        <user-agent><xsl:value-of select="field[@name='user-agent']"/></user-agent>
        <host><xsl:value-of select="field[@name='host']"/></host>
    </alert>
</xsl:for-each>
</alerts>
</xsl:template>
</xsl:stylesheet>
