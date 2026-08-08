import os
import webbrowser
from lxml import etree


def trasforma_xml_in_html(
    xml_path="tei_document.xml",
    xslt_path="transform.xslt",
    output_path="index.html",
    apri_nel_browser=True,
):
    try:
        # 1. Carica e analizza il file XML e il foglio di stile XSLT
        print("Caricamento dei file XML e XSLT...")
        xml_doc = etree.parse(xml_path)
        xslt_doc = etree.parse(xslt_path)

        # 2. Prepara il trasformatore XSLT
        transform = etree.XSLT(xslt_doc)

        # 3. Esegui la trasformazione
        print("Esecuzione della trasformazione XSLT...")
        result_tree = transform(xml_doc)

        # 4. Salva il risultato in un file HTML
        with open(output_path, "wb") as f:
            f.write(etree.tostring(result_tree, pretty_print=True, method="html"))

        print(f" Trasformazione completata con successo! Salvato in: {output_path}")

        # 5. Apri automaticamente il file generato nel browser predefinito
        if apri_nel_browser:
            file_abs_path = os.path.abspath(output_path)
            webbrowser.open(f"file://{file_abs_path}")

    except etree.XSLTParseError as e:
        print(f" Errore di parsing nel file XSLT: {e}")
    except etree.XMLSyntaxError as e:
        print(f" Errore di sintassi nel file XML: {e}")
    except Exception as e:
        print(f" Si è verificato un errore: {e}")


if __name__ == "__main__":
    # Assicurati che i nomi dei file corrispondano a quelli presenti nella tua cartella
    trasforma_xml_in_html()