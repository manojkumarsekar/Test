package com.eastspring.tom.cart.core.mdl;

import java.util.List;

public class ControlMSegregatedOutputLines {
    private List<ControlMOutputLine> toRetain;
    private List<ControlMOutputLine> toKill;

    public ControlMSegregatedOutputLines(List<ControlMOutputLine> toRetain, List<ControlMOutputLine> toKill) {
        this.toRetain = toRetain;
        this.toKill = toKill;
    }

    public List<ControlMOutputLine> getToRetain() {
        return toRetain;
    }

    public List<ControlMOutputLine> getToKill() {
        return toKill;
    }
}
