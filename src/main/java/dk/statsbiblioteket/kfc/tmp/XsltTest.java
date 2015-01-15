package dk.statsbiblioteket.kfc.tmp;

import dk.statsbiblioteket.util.xml.XSLT;

import java.util.HashMap;

/**
 * Created by kfc on 1/15/15.
 */
public class XsltTest {
    public static void main(String[] args) throws Exception {
        System.out.println(XSLT.transform(Thread.currentThread().getContextClassLoader().getResource("newspapr_sboi.xsl"), Thread.currentThread().getContextClassLoader().getResourceAsStream(
                "post.xml"), new HashMap()));
    }
}
