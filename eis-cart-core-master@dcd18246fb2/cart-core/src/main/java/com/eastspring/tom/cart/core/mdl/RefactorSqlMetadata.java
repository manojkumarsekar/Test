package com.eastspring.tom.cart.core.mdl;

public class RefactorSqlMetadata {

    private boolean isQueryRefactored;
    private String refactoredQuery;

    public boolean isQueryRefactored() {
        return isQueryRefactored;
    }

    public void setIsQueryRefactored(boolean queryRefactored) {
        isQueryRefactored = queryRefactored;
    }

    public String getRefactoredQuery() {
        return refactoredQuery;
    }

    public void setRefactoredQuery(String refactoredQuery) {
        this.refactoredQuery = refactoredQuery;
    }


}
