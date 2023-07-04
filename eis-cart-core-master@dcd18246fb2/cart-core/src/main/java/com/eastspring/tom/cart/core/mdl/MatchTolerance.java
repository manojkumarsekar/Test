package com.eastspring.tom.cart.core.mdl;

public enum MatchTolerance {
    EXACT("exact"),
    NUMERIC_ABS("absolute"),
    NUMERIC_REL("relative");

    private String typeName;

    MatchTolerance(String typeName) {
        this.typeName = typeName;
    }

    public String getTypeName() {
        return typeName;
    }

    public MatchTolerance valueOfTypeName(String matchToleranceString) {
        String lowercaseMatchToleranceString = matchToleranceString == null ? "" : matchToleranceString.toLowerCase();
        for(MatchTolerance mt: MatchTolerance.values()) {
            if(mt.getTypeName().equals(lowercaseMatchToleranceString)) {
                return mt;
            }
        }
        return null;
    }
}
