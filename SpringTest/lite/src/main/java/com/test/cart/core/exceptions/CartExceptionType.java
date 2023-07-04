package com.eastspring.qa.cart.core.exceptions;


public enum CartExceptionType {

    //generic
    UNDEFINED,
    PROCESSING_FAILED,
    UNSATISFIED_IMPLICIT_ASSUMPTION,

    //config
    INVALID_CONFIG,
    INCOMPLETE_PARAMS,
    INVALID_INVOCATION_PARAMS,
    INVALID_PARAM,

    //verification
    ASSERTION_ERROR,

    //secret
    ENCRYPTION_FAILED,

    // file
    UNSUPPORTED_ENCODING,
    INVALID_DATA_TABLE,
    FILE_NOT_FOUND,
    IO_ERROR,

    //data
    NO_DATA_AVAILABLE,

    // gui elements
    ELEMENT_NOT_FOUND,
    ELEMENT_NOT_ENABLED,
    ELEMENT_NOT_VISIBLE,
    ELEMENT_NOT_CLICKABLE,

    //application
    FAILED_LAUNCH,
    APP_CRASHED,
}