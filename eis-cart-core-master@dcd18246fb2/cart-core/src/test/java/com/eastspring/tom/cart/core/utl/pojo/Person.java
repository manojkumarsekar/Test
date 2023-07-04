package com.eastspring.tom.cart.core.utl.pojo;

import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

public class Person {

    @JacksonXmlProperty(localName = "NAME")
    private String name;

    @JacksonXmlProperty(localName = "AGE")
    private int age;

    public String getName() {
        return name;
    }

    public int getAge() {
        return age;
    }
}
