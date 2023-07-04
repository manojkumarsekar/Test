package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;

import java.net.Socket;

public class TcpUtil {
    public void openSocket(String host, int tcpPort) {
        try(Socket socket = new Socket(host, tcpPort)) {
            // intentionally left empty
        } catch(Exception e) {
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "TCP endpoint (host:port) [{}:{}] is not reachable", host, tcpPort);
        }
    }
}
