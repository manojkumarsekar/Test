package com.eastspring.tom.cart.core.utl;

import java.util.List;

public class HtmlGenUtil {

    private static final String TABLE_START_TAG = "<table style=\"width:100%\" border=\"1\" cellpadding=\"10\">";
    private static final String TABLE_END_TAG = "</table>";

    private static final String BODY_START_TAG = "<tbody>";
    private static final String BODY_END_TAG = "</tbody>";


    public String createHeader(List<String> headers) {
        StringBuilder headerRow = new StringBuilder("<tr>");
        for (String header : headers) {
            headerRow.append("<th>")
                    .append(header)
                    .append("</th>");
        }
        return headerRow.append("</tr>").toString();
    }

    public String createRow(List<String> entries) {
        StringBuilder headerRow = new StringBuilder("<tr>");
        for (String header : entries) {
            headerRow.append("<td style=\"text-align:center\" >")
                    .append(header)
                    .append("</td>");
        }
        return headerRow.append("</tr>").toString();
    }

    public String generateHtmlCode(final String body) {
        return TABLE_START_TAG +
                BODY_START_TAG +
                body +
                BODY_END_TAG +
                TABLE_END_TAG;
    }

    public String generateHtmlCode(final List<String> records) {
        StringBuilder table = new StringBuilder(TABLE_START_TAG)
                .append(BODY_START_TAG);

        for (String record : records) {
            table.append(record);
        }

        table.append(BODY_END_TAG)
                .append(TABLE_END_TAG);

        return table.toString();
    }


}
