package com.eastspring.qa.cart.core.lookUps;

public enum AttachmentType {
    XML("text/html"),
    TXT("text/plain"),
    CSV("text/csv"),
    JSON("text/plain"),
    PNG("image/png"),
    HTML("text/html");
    public final String mimeType;

    private AttachmentType(String mimeType) {
        this.mimeType = mimeType;
    }
}