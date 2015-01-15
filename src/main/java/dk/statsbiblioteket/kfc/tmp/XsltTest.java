package dk.statsbiblioteket.kfc.tmp;

import org.xml.sax.InputSource;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.XMLReaderFactory;

import dk.statsbiblioteket.util.xml.XSLT;

import javax.xml.XMLConstants;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamResult;
import java.io.ByteArrayOutputStream;
import java.io.InputStreamReader;
import java.io.Reader;

/**
 * Created by kfc on 1/15/15.
 */
public class XsltTest {
    public static void main(String[] args) throws Exception {
        Reader reader = new InputStreamReader(Thread.currentThread().getContextClassLoader().getResourceAsStream(
                        "post.xml"));
        Transformer transformer = XSLT.createTransformer(Thread.currentThread().getContextClassLoader().getResource(
                "newspapr_sboi.xsl"));
        transformer.setParameter(XMLConstants.FEATURE_SECURE_PROCESSING, false);
        transformer.setParameter("recordID", "domsSBOICollection:uuid:...");
        transformer.setParameter("recordBase", "domsSBOICollection");
        XMLReader xml;
        xml = XMLReaderFactory.createXMLReader();
        ByteArrayOutputStream out = new ByteArrayOutputStream(1000);
        out.reset();
        Result result = new StreamResult(out);
        InputSource is = new InputSource(reader);
        Source source = new SAXSource(xml, is);

        transformer.transform(source, result);
        System.out.println(out);
    }
}
