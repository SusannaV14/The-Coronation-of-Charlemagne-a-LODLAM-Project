import os
from lxml import etree
from rdflib import Graph, Literal, Namespace, URIRef
from rdflib.namespace import DC, FOAF, RDF, RDFS, XSD

# Definiamo i Namespace utilizzati nel TEI e per l'esportazione RDF
TEI_NS = "http://www.tei-c.org/ns/1.0"
NS_MAP = {
    "tei": TEI_NS,
    "dc": "http://purl.org/dc/elements/1.1/",
    "crm": "http://www.cidoc-crm.org/cidoc-crm/",
    "foaf": "http://xmlns.com/foaf/0.1/",
    "schema": "https://schema.org/",
    "rdfs" : "http://www.w3.org/2000/01/rdf-schema#",
}

# Namespace personalizzato per le entità del progetto
EX = Namespace("http://example.org/coronation/")
CRM = Namespace("http://www.cidoc-crm.org/cidoc-crm/")
SCHEMA = Namespace("https://schema.org/")


def parse_ref_to_uri(ref_str, g):
    """Converte un riferimento (es. '#Charlemagne' o 'foaf:Person') in una URIRef RDF."""
    if not ref_str:
        return None
    ref_str = ref_str.strip()

    # Se fa riferimento a un ID interno TEI (es. #Charlemagne)
    if ref_str.startswith("#"):
        return EX[ref_str[1:]]

    # Se è un prefisso noto (es. foaf:Person, crm:E53_Place, schema:Manuscript)
    if ":" in ref_str:
        prefix, value = ref_str.split(":", 1)
        if prefix == "foaf":
            return FOAF[value]
        elif prefix == "crm":
            return CRM[value]
        elif prefix == "schema":
            return SCHEMA[value]
        elif prefix == "dc":
            return DC[value]
        elif prefix == "rdf":
            return RDF[value]

    # Se è già un URL completo
    if ref_str.startswith("http://") or ref_str.startswith("https://"):
        return URIRef(ref_str)

    return EX[ref_str]


def tei_to_rdf_ttl(
    xml_path="tei_document.xml", output_ttl_path="coronation_graph.ttl"
):
    # 1. Inizializza il Grafo RDF e registra i prefissi per un file TTL pulito
    g = Graph()
    g.bind("ex", EX)
    g.bind("crm", CRM)
    g.bind("schema", SCHEMA)
    g.bind("foaf", FOAF)
    g.bind("dc", DC)
    g.bind("rdfs", RDFS)
    g.bind("rdf", RDF)

    # 2. Parsing del file TEI XML con lxml
    tree = etree.parse(xml_path)
    root = tree.getroot()

    # ----------------------------------------------------
    # A. ESTRAZIONE METADATI ENTITÀ
    # ----------------------------------------------------

    # Helper function per convertire la stringa di data nel Literal corretto
    def make_date_literal(date_str):
        date_str = date_str.strip()
        # Se ha due trattini ed è nel formato YYYY-MM-DD (anche con anni a 4 cifre tipo 0748-04-02)
        if date_str.count("-") == 2:
            return Literal(date_str, datatype=XSD.date)
        # Se è solo l'anno YYYY
        elif len(date_str) == 4 and date_str.isdigit():
            return Literal(date_str, datatype=XSD.gYear)
        # Altrimenti semplice stringa
        return Literal(date_str)

    # A1. Persone (listPerson)
    for person in root.xpath("//tei:listPerson/tei:person", namespaces=NS_MAP):
        person_id = person.get("{http://www.w3.org/XML/1998/namespace}id")
        if not person_id:
            continue
        subj = EX[person_id]
        g.add((subj, RDF.type, FOAF.Person))

        name = person.findtext("tei:persName", namespaces=NS_MAP)
        if name:
            g.add((subj, FOAF.name, Literal(name)))

        title = person.findtext("foaf:title", namespaces=NS_MAP)
        if title:
            g.add((subj, FOAF.title, Literal(title)))

        occ = person.findtext("schema:Occupation", namespaces=NS_MAP)
        if occ:
            g.add((subj, SCHEMA.hasOccupation, Literal(occ)))

        bdate = person.findtext("schema:birthDate", namespaces=NS_MAP)
        if bdate:
            g.add((subj, SCHEMA.birthDate, make_date_literal(bdate)))

        ddate = person.findtext("schema:deathDate", namespaces=NS_MAP)
        if ddate:
            g.add((subj, SCHEMA.deathDate, make_date_literal(ddate)))

        for idno in person.xpath("tei:idno", namespaces=NS_MAP):
            g.add((subj, RDFS.seeAlso, URIRef(idno.text.strip())))

    # A2. Luoghi (listPlace)
    for place in root.xpath("//tei:listPlace/tei:place", namespaces=NS_MAP):
        place_id = place.get("{http://www.w3.org/XML/1998/namespace}id")
        if not place_id:
            continue
        subj = EX[place_id]
        g.add((subj, RDF.type, CRM.E53_Place))

        name = place.findtext("tei:placeName", namespaces=NS_MAP)
        if name:
            g.add((subj, RDFS.label, Literal(name)))

        country = place.findtext("tei:note/schema:Country", namespaces=NS_MAP)
        if country:
            g.add((subj, SCHEMA.addressCountry, Literal(country)))

        period = place.findtext("tei:note/crm:E4_Period", namespaces=NS_MAP)
        if period:
            g.add((subj, SCHEMA.temporalCoverage, Literal(period)))

        for idno in place.xpath("tei:idno", namespaces=NS_MAP):
            g.add((subj, RDFS.seeAlso, URIRef(idno.text.strip())))

    # A3. Opere Letterarie (listBibl)
    for bibl in root.xpath("//tei:listBibl/tei:bibl", namespaces=NS_MAP):
        bibl_id = bibl.get("{http://www.w3.org/XML/1998/namespace}id")
        if not bibl_id:
            continue
        subj = EX[bibl_id]
        g.add((subj, RDF.type, SCHEMA.Manuscript))

        title = bibl.findtext("tei:title", namespaces=NS_MAP)
        if title:
            g.add((subj, DC.title, Literal(title)))

        pdate = bibl.findtext("tei:note/schema:datePublished", namespaces=NS_MAP)
        if pdate:
            g.add((subj, SCHEMA.datePublished, make_date_literal(pdate)))

        author_elem = bibl.find("tei:note/dc:creator", namespaces=NS_MAP)
        if author_elem is not None:
            if author_elem.get("ref"):
                g.add(
                    (
                        subj,
                        DC.creator,
                        parse_ref_to_uri(author_elem.get("ref"), g),
                    )
                )
            elif author_elem.text:
                g.add((subj, DC.creator, Literal(author_elem.text)))

        subject_elem = bibl.find("tei:note/dc:subject", namespaces=NS_MAP)
        if subject_elem is not None:
            if subject_elem.get("ref"):
                g.add(
                    (
                        subj,
                        DC.subject,
                        parse_ref_to_uri(subject_elem.get("ref"), g),
                    )
                )
            elif subject_elem.text:
                g.add((subj, DC.subject, Literal(subject_elem.text)))

        lang = bibl.findtext("tei:note/dc:language", namespaces=NS_MAP)
        if lang:
            g.add((subj, DC.language, Literal(lang)))

        for idno in bibl.xpath("tei:idno", namespaces=NS_MAP):
            g.add((subj, RDFS.seeAlso, URIRef(idno.text.strip())))

    # A4. Oggetti Artistici (list[@type='culturalObjects'])
    for item in root.xpath(
        "//tei:list[@type='culturalObjects']/tei:item", namespaces=NS_MAP
    ):
        item_id = item.get("{http://www.w3.org/XML/1998/namespace}id")
        if not item_id:
            continue
        subj = EX[item_id]
        g.add((subj, RDF.type, CRM["E22_Human-Made_Object"]))

        name = item.findtext("tei:name", namespaces=NS_MAP)
        if name:
            g.add((subj, RDFS.label, Literal(name)))

        period = item.findtext("tei:note/crm:E4_Period", namespaces=NS_MAP)
        if period:
            g.add((subj, SCHEMA.temporalCoverage, Literal(period)))

        mat = item.findtext("tei:note/crm:E57_Material", namespaces=NS_MAP)
        if mat:
            g.add((subj, CRM.P45_consists_of, Literal(mat)))

        loc = item.findtext("tei:note/crm:E53_Place", namespaces=NS_MAP)
        if loc:
            g.add((subj, CRM.P55_has_current_location, Literal(loc)))

        subj_elem = item.find("tei:note/dc:subject", namespaces=NS_MAP)
        if subj_elem is not None and subj_elem.get("ref"):
            g.add(
                (subj, DC.subject, parse_ref_to_uri(subj_elem.get("ref"), g))
            )

        for idno in item.xpath("tei:idno", namespaces=NS_MAP):
            g.add((subj, RDFS.seeAlso, URIRef(idno.text.strip())))

    # ----------------------------------------------------
    # B. ESTRAZIONE RELAZIONI (listRelation)
    # ----------------------------------------------------
    for rel in root.xpath("//tei:listRelation/tei:relation", namespaces=NS_MAP):
        active_ref = rel.get("active")
        passive_ref = rel.get("passive")
        rel_name = rel.get("name")

        if active_ref and passive_ref and rel_name:
            active_uri = parse_ref_to_uri(active_ref, g)
            passive_uri = parse_ref_to_uri(passive_ref, g)
            pred_uri = parse_ref_to_uri(rel_name, g)

            if active_uri and passive_uri and pred_uri:
                g.add((active_uri, pred_uri, passive_uri))

    # 3. Serializzazione e Salvataggio in formato TTL (Turtle)
    g.serialize(destination=output_ttl_path, format="turtle")
    print(
        f" File RDF generato con successo in formato Turtle: '{output_ttl_path}'"
    )


if __name__ == "__main__":
    tei_to_rdf_ttl()