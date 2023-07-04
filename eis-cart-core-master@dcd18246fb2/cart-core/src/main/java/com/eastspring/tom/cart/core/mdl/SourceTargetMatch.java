package com.eastspring.tom.cart.core.mdl;

public class SourceTargetMatch {
    private final String source;
    private final String target;
    private final String match;

    public SourceTargetMatch(final String source, final String target, final String match) {
        this.source = source;
        this.target = target;
        this.match = match;
    }

    public String getSource() {
        return source;
    }

    public String getTarget() {
        return target;
    }

    public String getMatch() {
        return match;
    }
}
