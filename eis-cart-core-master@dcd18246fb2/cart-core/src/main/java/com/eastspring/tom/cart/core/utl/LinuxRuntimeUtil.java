package com.eastspring.tom.cart.core.utl;

public class LinuxRuntimeUtil implements IRuntimeUtil {
    @Override
    public String getRuntimeDir() {
        return "/opt/tomrt-linux";
    }
}
