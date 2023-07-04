package com.eastspring.tom.cart.dmp.svc;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.impl.client.BasicCredentialsProvider;

public class DmpWorkflowContext {
    private String protocol;
    private String host;
    private int port;
    private String context;
    private String username;
    private String password;

    public String getProtocol() {
        return protocol;
    }

    public void setProtocol(String protocol) {
        this.protocol = protocol;
    }

    public String getHost() {
        return host;
    }

    public void setHost(String host) {
        this.host = host;
    }

    public int getPort() {
        return port;
    }

    public void setPort(int port) {
        this.port = port;
    }

    public String getContext() {
        return context;
    }

    public void setContext(String context) {
        this.context = context;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }

    public String getEndpoint() {
        return protocol + "://" + host + ":" + port + context;
    }

    public CredentialsProvider getCredentialsProvider() {
        CredentialsProvider result = new BasicCredentialsProvider();
        result.setCredentials(new AuthScope(host, port), new UsernamePasswordCredentials(username, password));
        return result;
    }
}
