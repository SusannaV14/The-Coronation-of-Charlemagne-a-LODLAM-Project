<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:schema="https://schema.org/"
    exclude-result-prefixes="tei dc crm foaf schema">

    <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat"/>

    <xsl:template match="/">
        <html lang="en">
        <head>
            <meta charset="UTF-8"/>
            <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
            <title><xsl:value-of select="//tei:titleStmt/tei:title"/></title>
            <style>
                :root {
                    --bg-primary: #f8f9fa;
                    --text-primary: #212529;
                    --person-color: #0d6efd;
                    --place-color: #198754;
                    --bibl-color: #d63384;
                    --object-color: #fd7e14;
                    --border-color: #e9ecef;
                }
                body {
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    margin: 0;
                    padding: 0;
                    background-color: var(--bg-primary);
                    color: var(--text-primary);
                }
                header {
                    background: #343a40;
                    color: white;
                    padding: 1.5rem 2rem;
                    border-bottom: 4px solid #0d6efd;
                }
                header h1 { margin: 0; font-size: 1.8rem; }
                header p { margin: 0.3rem 0 0 0; opacity: 0.8; font-size: 0.95rem; }
                
                .container {
                    display: flex;
                    gap: 2rem;
                    padding: 2rem;
                    max-width: 1400px;
                    margin: 0 auto;
                }
                .main-text {
                    flex: 2;
                    background: white;
                    padding: 2.5rem;
                    border-radius: 8px;
                    box-shadow: 0 4px 6px rgba(0,0,0,0.05);
                    line-height: 1.7;
                    font-size: 1.05rem;
                }
                .sidebar {
                    flex: 1;
                    display: flex;
                    flex-direction: column;
                    gap: 1.5rem;
                }
                .section-title {
                    border-bottom: 2px solid var(--border-color);
                    padding-bottom: 0.5rem;
                    margin-top: 0;
                    color: #495057;
                }
                
                /* Metadata Cards */
                .entity-card {
                    background: white;
                    border-radius: 8px;
                    padding: 1.2rem;
                    border-left: 5px solid #6c757d;
                    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
                    transition: transform 0.2s, box-shadow 0.2s;
                }
                .entity-card:target, .entity-card.highlight {
                    transform: scale(1.02);
                    box-shadow: 0 0 12px rgba(13, 110, 253, 0.4);
                    outline: 2px solid #0d6efd;
                }
                .entity-card.person { border-left-color: var(--person-color); }
                .entity-card.place { border-left-color: var(--place-color); }
                .entity-card.bibl { border-left-color: var(--bibl-color); }
                .entity-card.object { border-left-color: var(--object-color); }
                
                .entity-card h4 { margin: 0 0 0.5rem 0; font-size: 1.1rem; }
                .entity-card ul { list-style: none; padding: 0; margin: 0; font-size: 0.9rem; }
                .entity-card li { margin-bottom: 0.3rem; }
                .entity-card strong { color: #495057; }
                
                /* In-text markup */
                .entity-ref {
                    text-decoration: none;
                    font-weight: 600;
                    padding: 0.1rem 0.3rem;
                    border-radius: 4px;
                    transition: background-color 0.2s;
                }
                .entity-ref.person { color: var(--person-color); background: rgba(13, 110, 253, 0.1); }
                .entity-ref.place  { color: var(--place-color);  background: rgba(25, 135, 84, 0.1); }
                .entity-ref.bibl { color: var(--bibl-color); background: rgba(214, 51, 132, 0.1); }
                .entity-ref.object { color: var(--object-color); background: rgba(253, 126, 20, 0.1); }
                .entity-ref:hover { text-decoration: underline; }
                
                figure {
                    background: #f8f9fa;
                    border: 1px dashed #ced4da;
                    padding: 1rem;
                    margin: 1.5rem 0;
                    border-radius: 6px;
                    font-style: italic;
                    color: #6c757d;
                }
                .external-link { font-size: 0.8rem; word-break: break-all; }

                /* Table with relations */
                .relations-section {
                margin-top: 2rem;
                background: white;
                padding: 1.5rem;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.05);
                }
                .relations-table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 1rem;
                font-size: 0.95rem;
                }
                .relations-table th, .relations-table td {
                padding: 0.75rem 1rem;
                text-align: left;
                border-bottom: 1px solid var(--border-color);
                }
                .relations-table th {
                background-color: #f1f3f5;
                color: #495057;
                font-weight: 600;
                }
                .relations-table tr:hover {
                background-color: #f8f9fa;
                }
                .relation-name {
                font-family: monospace;
                background: #e9ecef;
                padding: 0.2rem 0.4rem;
                border-radius: 4px;
                font-size: 0.85rem;
                color: #333;
                }
            </style>
        </head>
        <body>

            <header>
                <h1><xsl:value-of select="//tei:titleStmt/tei:title"/></h1>
                <p>Annotations'Author: <strong><xsl:value-of select="//tei:titleStmt/tei:author"/></strong> | Publication: <xsl:value-of select="//tei:publicationStmt/tei:date"/></p>
            </header>

            <div class="container">
                <!-- TEXT -->
                <main class="main-text">
                    <xsl:apply-templates select="//tei:text/tei:body"/>
                    <!-- TABLE WITH RELATIONS -->
                    <section class="relations-section">
                    <h3 class="section-title">Entities Relations (listRelation)</h3>
                    <table class="relations-table">
                       <thead>
                          <tr>
                            <th>Active (Subject)</th>
                            <th>Relation (Property)</th>
                            <th>Passive (Object)</th>
                          </tr>
                       </thead>
                       <tbody>
                          <xsl:for-each select="//tei:listRelation/tei:relation">
                          <tr>
                          <!-- Subject / Active -->
                            <td>
                            <xsl:choose>
                            <xsl:when test="starts-with(@active, '#')">
                                <a class="entity-ref" href="{@active}">
                                    <xsl:value-of select="substring-after(@active, '#')"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@active"/>
                            </xsl:otherwise>
                            </xsl:choose>
                            </td>
                    
                           <!-- Predicate / Relation -->
                            <td>
                            <span class="relation-name"><xsl:value-of select="@name"/></span>
                            </td>
                    
                           <!-- Object / Passive -->
                            <td>
                            <xsl:choose>
                            <xsl:when test="starts-with(@passive, '#')">
                                <a class="entity-ref" href="{@passive}">
                                    <xsl:value-of select="substring-after(@passive, '#')"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@passive"/>
                            </xsl:otherwise>
                            </xsl:choose>
                            </td>
                           </tr>
                           </xsl:for-each>
                        </tbody>
                    </table>
                    </section>
                </main>

                <!-- INDEX: ENTITIES & METADATA -->
                <aside class="sidebar">
                    <h2 class="section-title">Entities Index</h2>
                    
                    <!-- PEOPLE -->
                    <section>
                        <h3>People</h3>
                        <xsl:for-each select="//tei:listPerson/tei:person">
                            <div class="entity-card person" id="{@xml:id}">
                                <h4><xsl:value-of select="tei:persName"/></h4>
                                <ul>
                                    <xsl:if test="foaf:title"><li><strong>Title:</strong> <xsl:value-of select="foaf:title"/></li></xsl:if>
                                    <xsl:if test="schema:Occupation"><li><strong>Occupation:</strong> <xsl:value-of select="schema:Occupation"/></li></xsl:if>
                                    <xsl:if test="schema:birthDate"><li><strong>Birth-Death:</strong> <xsl:value-of select="schema:birthDate"/> / <xsl:value-of select="schema:deathDate"/></li></xsl:if>
                                    <xsl:if test="tei:idno[@type='Wikidata']">
                                        <li class="external-link"><strong>Wikidata:</strong> <a href="{tei:idno[@type='Wikidata']}" target="_blank"><xsl:value-of select="tei:idno[@type='Wikidata']"/></a></li>
                                    </xsl:if>
                                    <xsl:if test="tei:idno[@type='VIAF']">
                                        <li class="external-link"><strong>VIAF:</strong> <a href="{tei:idno[@type='VIAF']}" target="_blank"><xsl:value-of select="tei:idno[@type='VIAF']"/></a></li>
                                    </xsl:if>
                                </ul>
                            </div>
                        </xsl:for-each>
                    </section>

                    <!-- PLACES -->
                    <section>
                        <h3>Places</h3>
                        <xsl:for-each select="//tei:listPlace/tei:place">
                            <div class="entity-card place" id="{@xml:id}">
                                <h4><xsl:value-of select="tei:placeName"/></h4>
                                <ul>
                                    <li><strong>Location:</strong> <xsl:value-of select="tei:note/schema:Country"/></li>
                                    <li><strong>Artistic Period:</strong> <xsl:value-of select="tei:note/crm:E4_Period"/></li>
                                    <xsl:if test="tei:idno[@type='Wikidata']">
                                        <li class="external-link"><strong>Wikidata:</strong> <a href="{tei:idno[@type='Wikidata']}" target="_blank"><xsl:value-of select="tei:idno[@type='Wikidata']"/></a></li>
                                    </xsl:if>
                                    <xsl:if test="tei:idno[@type='VIAF']">
                                        <li class="external-link"><strong>VIAF:</strong> <a href="{tei:idno[@type='VIAF']}" target="_blank"><xsl:value-of select="tei:idno[@type='VIAF']"/></a></li>
                                    </xsl:if>
                                </ul>
                            </div>
                        </xsl:for-each>
                    </section>

                    <!-- LITERARY WORKS -->
                    <section>
                        <h3>Literary Works</h3>
                        <xsl:for-each select="//tei:listBibl/tei:bibl">
                            <div class="entity-card bibl" id="{@xml:id}">
                                <h4><xsl:value-of select="tei:title"/></h4>
                                <ul>
                                    <li>
                                    <strong>Subject of the work: </strong>
                                    <xsl:choose>
                                    <!-- if there is an attribute @ref, create a link -->
                                    <xsl:when test="tei:note/dc:subject/@ref">
                                    <a class="entity-ref person" href="{tei:note/dc:subject/@ref}">
                                    <xsl:value-of select="tei:note/dc:subject"/>
                                    </a>
                                    </xsl:when>
                                    <!-- if no attribute, simple text -->
                                    <xsl:otherwise>
                                    <xsl:value-of select="tei:note/dc:subject"/>
                                    </xsl:otherwise>
                                    </xsl:choose>
                                    </li>
                                    <li><strong>Date:</strong> <xsl:value-of select="tei:note/schema:datePublished"/></li>
                                    <li><strong>Language:</strong> <xsl:value-of select="tei:note/dc:language"/></li>
                                    <li>
                                    <strong>Author: </strong>
                                    <xsl:choose>
                                    <!-- if there is an attribute @ref, create a link -->
                                    <xsl:when test="tei:note/dc:creator/@ref">
                                    <a class="entity-ref person" href="{tei:note/dc:creator/@ref}">
                                    <xsl:value-of select="tei:note/dc:creator"/>
                                    </a>
                                    </xsl:when>
                                    <!-- if no attribute, simple text -->
                                    <xsl:otherwise>
                                    <xsl:value-of select="tei:note/dc:creator"/>
                                    </xsl:otherwise>
                                    </xsl:choose>
                                    </li>
                                    <xsl:if test="tei:idno[@type='Wikidata']">
                                        <li class="external-link"><strong>Wikidata:</strong> <a href="{tei:idno[@type='Wikidata']}" target="_blank"><xsl:value-of select="tei:idno[@type='Wikidata']"/></a></li>
                                    </xsl:if>
                                    <xsl:if test="tei:idno[@type='VIAF']">
                                        <li class="external-link"><strong>VIAF:</strong> <a href="{tei:idno[@type='VIAF']}" target="_blank"><xsl:value-of select="tei:idno[@type='VIAF']"/></a></li>
                                    </xsl:if>
                                </ul>
                            </div>
                        </xsl:for-each>
                    </section>

                    <!-- ARTISTIC OBJECTS -->
                    <section>
                        <h3>Artistic Objects</h3>
                        <xsl:for-each select="//tei:listArtObj/tei:item">
                            <div class="entity-card object" id="{@xml:id}">
                                <h4><xsl:value-of select="tei:name"/></h4>
                                <ul>
                                    <li><strong>Artistic Period:</strong> <xsl:value-of select="tei:note/crm:E4_Period"/></li>
                                    <li><strong>Materials:</strong> <xsl:value-of select="tei:note/crm:E57_Material"/></li>
                                    <li><strong>Current Location:</strong> <xsl:value-of select="tei:note/crm:E53_Place"/></li>
                                    <li>
                                    <strong>Depicts:</strong>
                                    <xsl:choose>
                                    <!-- if there is an attribute @ref, create a link -->
                                    <xsl:when test="tei:note/dc:subject/@ref">
                                    <a class="entity-ref person" href="{tei:note/dc:subject/@ref}">
                                    <xsl:value-of select="tei:note/dc:subject"/>
                                    </a>
                                    </xsl:when>
                                    <!-- if no attribute, simple text -->
                                    <xsl:otherwise>
                                    <xsl:value-of select="tei:note/dc:subject"/>
                                    </xsl:otherwise>
                                    </xsl:choose>
                                    </li>
                                    <xsl:if test="tei:idno[@type='Wikidata']">
                                        <li class="external-link"><strong>Wikidata:</strong> <a href="{tei:idno[@type='Wikidata']}" target="_blank"><xsl:value-of select="tei:idno[@type='Wikidata']"/></a></li>
                                    </xsl:if>
                                    <xsl:if test="tei:idno[@type='VIAF']">
                                        <li class="external-link"><strong>VIAF:</strong> <a href="{tei:idno[@type='VIAF']}" target="_blank"><xsl:value-of select="tei:idno[@type='VIAF']"/></a></li>
                                    </xsl:if>
                                </ul>
                            </div>
                        </xsl:for-each>
                    </section>
                </aside>
            </div>

            <!-- JavaScript to highlight the cards -->
            <script>
                document.querySelectorAll('.entity-ref').forEach(link => {
                    link.addEventListener('click', (e) => {
                        document.querySelectorAll('.entity-card').forEach(card => card.classList.remove('highlight'));
                        const id = link.getAttribute('href').substring(1);
                        const card = document.getElementById(id);
                        if(card) {
                            card.classList.add('highlight');
                        }
                    });
                });
            </script>
        </body>
        </html>
    </xsl:template>

    <!-- Templates for Plain Text -->
    <xsl:template match="tei:div">
        <section>
            <xsl:apply-templates/>
        </section>
    </xsl:template>

    <xsl:template match="tei:head">
        <h2><xsl:apply-templates/></h2>
    </xsl:template>

    <xsl:template match="tei:p">
        <p><xsl:apply-templates/></p>
    </xsl:template>

    <!-- References at People -->
    <xsl:template match="tei:persName[@ref]">
    <a class="entity-ref person" href="{@ref}">
        <xsl:apply-templates/>
    </a>
    </xsl:template>

    <!-- References at places -->
    <xsl:template match="tei:placeName[@ref]">
    <a class="entity-ref place" href="{@ref}">
        <xsl:apply-templates/>
    </a>
    </xsl:template>

    <!-- References at literary works -->
    <xsl:template match="tei:title[@ref]">
    <a class="entity-ref bibl" href="{@ref}">
        <xsl:apply-templates/>
    </a>
    </xsl:template>

    <!-- References at Artistic Objects -->
    <xsl:template match="tei:name[@ref]">
    <a class="entity-ref object" href="{@ref}">
        <xsl:apply-templates/>
    </a>
    </xsl:template>

    <!-- Template for figures -->
    <xsl:template match="tei:figure">
    <figure>
        <strong>[Figure]: </strong>
        <xsl:apply-templates/>
    </figure>
    </xsl:template>
    <xsl:template match="tei:figDesc">
    <span><xsl:apply-templates/></span>
    </xsl:template>

</xsl:stylesheet>