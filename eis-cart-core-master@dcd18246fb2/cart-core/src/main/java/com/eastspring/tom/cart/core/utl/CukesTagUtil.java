package com.eastspring.tom.cart.core.utl;

import java.util.Set;
import java.util.regex.Pattern;

public class CukesTagUtil {

    public Pattern getJiraTicketTagPattern(Set<String> jiraSpaces) {
        if(jiraSpaces == null || jiraSpaces.isEmpty()) {
            return null;
        } else if(jiraSpaces.size() == 1) {
            String jiraSpace = jiraSpaces.iterator().next();
            String pattern = "@" + jiraSpace.toLowerCase() + "_(\\d+)";
            return Pattern.compile(pattern);
        } else {
            int size = jiraSpaces.size();
            String tagKeys = "(" + String.join("|", jiraSpaces.toArray(new String[size])) + ")";
            String pattern = "@" + tagKeys.toLowerCase() + "_(\\d+)";
            return Pattern.compile(pattern);
        }
    }

    public String getJiraTicketFromTag(String tag, Pattern pattern) {
        if(tag == null || !tag.contains("_") || pattern == null || !pattern.matcher(tag).find()) {
            return null;
        }
        int underscoreIdx = tag.indexOf('_');
        String jiraSpace = tag.substring(1, underscoreIdx);
        String jiraNum = tag.substring(underscoreIdx + 1);
        return jiraSpace.toUpperCase() + "-" + jiraNum;
    }
}
