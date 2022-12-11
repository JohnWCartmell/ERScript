<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns="http://www.entitymodelling.org/ERmodel"
               xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               version="2.0"
               xpath-default-namespace="http://www.entitymodelling.org/ERmodel">
   <xsl:strip-space elements="*"/>
 

   <xsl:template match="@*|node()" mode="consolidate">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="consolidate"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="absolute" mode="consolidate">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="consolidate"/>
         <!-- should what follows be apply-templates ???-->
         <xsl:copy-of select="following::absolute
                                        /*[not(self::name
                                               | self::reference[some $localref in current()/reference
                                                                 satisfies $localref/name = name] 
                                               | self::composition[some $localcomp in current()/composition
                                                                 satisfies ($localcomp/name=name
                                                                           or (not($localcomp/name)
                                                                                and 
                                                                               $localcomp/type=type
                                                                              )
                                                                           )
                                                                 ]
                                              )
                                          ]"/> 
      </xsl:copy>
   </xsl:template>

   <xsl:template match="absolute[preceding::absolute]" mode="consolidate">
              <!-- this template is deliberately left blank -->
   </xsl:template>


   <xsl:template match="group" mode="consolidate">
      <xsl:message>consolidating group</xsl:message>
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="consolidate"/>
         <xsl:apply-templates select="following::group[name=current()/name]
                                        /*[not(self::name)
                                          ]" 
                              mode="consolidate"/> 
      </xsl:copy>
   </xsl:template>

   <xsl:template match="group[preceding::group[name=current()/name]]" mode="consolidate">
              <!-- this template is deliberately left blank -->
   </xsl:template>

   <xsl:template match="entity_type" mode="consolidate">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="consolidate"/>
         <xsl:apply-templates select="following::entity_type[name=current()/name]
                                        /*[not(self::name
                                               | self::reference[some $localref in current()/reference
                                                                 satisfies $localref/name = name] 
                                               | self::attribute[some $localref in current()/attribute
                                                                 satisfies $localref/name = name] 
                                               | self::composition[some $localcomp in current()/composition
                                                                 satisfies ($localcomp/name=name
                                                                           or (not($localcomp/name)
                                                                                and 
                                                                               $localcomp/type=type
                                                                              )
                                                                           )
                                                                 ]
                                              )
                                          ]"
                              mode="consolidate"/> 
      </xsl:copy>
   </xsl:template>

   <xsl:template match="entity_type[preceding::entity_type[name=current()/name]]" mode="consolidate">
              <!-- this template is deliberately left blank -->
   </xsl:template>

   <xsl:template match="absolute/reference" mode="consolidate">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="consolidate"/>
         <xsl:copy-of select="following::reference[name=current()/name and parent::absolute]
                                                  /*[not(self::name|self::type)]"/> 
      </xsl:copy>
   </xsl:template>

   <xsl:template match="reference" mode="consolidate">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="consolidate"/>
         <xsl:copy-of select="following::reference[name=current()/name and ../name = current()/../name]
                                                  /*[not(self::name|self::type)]"/> 
      </xsl:copy>
   </xsl:template>

   <xsl:template match="reference[preceding::reference[../name = current()/../name
                                                            and name=current()/name 
                                                      ]
                                 ]" 
                 mode="consolidate">
              <!-- this template is deliberately left blank -->
   </xsl:template>

   <xsl:template match="dependency" mode="consolidate">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="consolidate"/>
         <xsl:message>Copying following dependency</xsl:message>
         <xsl:copy-of select="following::dependency[name=current()/name and ../name = current()/../name]
                                                  /*[not(self::name|self::type)]"/> 
      </xsl:copy>
   </xsl:template>

   <xsl:template match="dependency[preceding::dependency[../name = current()/../name
                                                            and name=current()/name 
                                                      ]
                                 ]" 
                 mode="consolidate">
                 <xsl:message>Pruning depdendency</xsl:message>
              <!-- this template is deliberately left blank -->
   </xsl:template>

   <xsl:template match="attribute" mode="consolidate">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="consolidate"/>
         <xsl:copy-of select="following::attribute[name=current()/name and ../name = current()/../name]
                                                  /*[not(self::name)]"/> 
      </xsl:copy>
   </xsl:template>

   <xsl:template match="attribute[preceding::attribute[../name = current()/../name
                                                            and name=current()/name 
                                                      ]
                                 ]" 
                 mode="consolidate">
              <!-- this template is deliberately left blank -->
   </xsl:template>


   <xsl:template match="absolute/composition" mode="consolidate">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="consolidate"/>
         <xsl:copy-of select="following::composition[ parent::absolute
                                                      and
                                                      ( name=current()/name 
                                                                or (  not(current()/name) 
                                                                      and not(name)  
                                                                      and type = current()/type
                                                                    )
                                                      ) 
                                                    ]/*[not(self::name|self::type)]"/> 
      </xsl:copy>
   </xsl:template>

   <xsl:template match="composition" mode="consolidate">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="consolidate"/>
         <xsl:copy-of select="following::composition[ ../name = current()/../name
                                                      and
                                                      ( name=current()/name 
                                                                or (  not(current()/name) 
                                                                      and not(name)  
                                                                      and type = current()/type
                                                                    )
                                                      ) 
                                                    ]/*[not(self::name|self::type)]"/> 
      </xsl:copy>
   </xsl:template>

   <xsl:template match="composition[preceding::composition[../name = current()/../name
                                                            and
                                                            ( name=current()/name 
                                                                      or (  not(current()/name) 
                                                                            and not(name)  
                                                                            and type = current()/type
                                                                          )
                                                            ) 
                                                          ]]" mode="consolidate">
              <!-- this template is deliberately left blank -->
   </xsl:template>

</xsl:transform>
