package com.eastspring.tom.cart.core.mdl;


import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 *
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class HeaderMetadata {
    private List<String> headerNames = new ArrayList<>();
    private boolean hasHeaderRow = false;

    public void addHeader(String headerName) {
        headerNames.add(headerName);
    }

    public int getHeaderCount() {
        return headerNames.size();
    }

    public boolean isHasHeaderRow() {
        return hasHeaderRow;
    }

    public void setHasHeaderRow(boolean hasHeaderRow) {
        this.hasHeaderRow = hasHeaderRow;
    }

    public List<String> getHeaderNames() {
        return Collections.unmodifiableList(headerNames);
    }

    public String toString() {
        return "{hasHeaderRow:" + hasHeaderRow + "," + Arrays.toString(headerNames.toArray()) + "}";
    }
}
