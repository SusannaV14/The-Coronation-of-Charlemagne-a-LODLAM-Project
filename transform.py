import os
import webbrowser
from lxml import etree


def trasforma_xml_in_html(
    xml_path="tei_document.xml",
    xslt_path="transform.xslt",
    output_path="TheCoronation.html",
    apri_nel_browser=True,
):
    try:
        # 1. Upload and analyze the XML file and the XSLT stylesheet
        print("Caricamento dei file XML e XSLT...")
        xml_doc = etree.parse(xml_path)
        xslt_doc = etree.parse(xslt_path)

        # 2. Prepare the XSLT transformer
        transform = etree.XSLT(xslt_doc)

        # 3. Perform the transformation
        print("Esecuzione della trasformazione XSLT...")
        result_tree = transform(xml_doc)

        # 4. Save the result in a HTML file
        with open(output_path, "wb") as f:
            f.write(etree.tostring(result_tree, pretty_print=True, method="html"))

        print(f" Trasformazione completata con successo! Salvato in: {output_path}")

        # 5. Automatically open the generated file in the default browser
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
    # Make sure the file names match those in your folder.
    trasforma_xml_in_html()