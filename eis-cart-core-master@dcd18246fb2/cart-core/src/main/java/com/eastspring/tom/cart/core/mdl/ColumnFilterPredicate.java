package com.eastspring.tom.cart.core.mdl;

public interface ColumnFilterPredicate {
    String operation(int columnNum, String value);
}
