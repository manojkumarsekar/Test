package com.eastspring.tom.cart.core.mdl;

import java.util.List;

public class RegexVars {

    private String expression;
    private List<String> vars;

    public RegexVars(String expression, List<String> vars) {
        this.expression = expression;
        this.vars = vars;
    }

    public String getExpression() {
        return expression;
    }

    public List<String> getVars() {
        return vars;
    }
}
