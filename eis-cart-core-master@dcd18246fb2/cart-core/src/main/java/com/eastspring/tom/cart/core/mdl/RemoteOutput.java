package com.eastspring.tom.cart.core.mdl;

public class RemoteOutput {
    private String output;
    private String error;

    public RemoteOutput(String output, String error) {
        this.output = output;
        this.error = error;
    }

    public String getOutput() {
        return output;
    }

    public String getError() {
        return error;
    }

    public String toString() {
        return String.format("(output: [%s],\nerror: [%s])", output, error);
    }
}
