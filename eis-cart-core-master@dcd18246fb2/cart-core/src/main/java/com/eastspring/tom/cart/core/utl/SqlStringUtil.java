package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.SqlFieldDef;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class SqlStringUtil {

    /**
     * This method zip items in the list and then join them together with delimiters in between.
     *
     * @param items
     * @param delimiter
     * @param prefix
     * @param postfix
     * @return
     */
    public String zipJoin(List<String> items, String delimiter, String prefix, String postfix) {
        if (items == null) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "zipJoin: items must not be null");
        }
        return String.join(delimiter, items.stream().map(s -> prefix + s + postfix).toArray(String[]::new));
    }

    public String zipJoinJoinClause(List<String> fields, String prefix1, String prefix2) {
        if (fields == null) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "zipJoinJoinClause: fields must not be null");
        }
        return String.join(" AND ", fields.stream().map(field -> prefix1 + "." + field + "=" + prefix2 + "." + field).toArray(String[]::new));
    }

    public String zipJoinWithDelimiter(int count, String item, String delimiter) {
        List<String> items = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            items.add(item);
        }
        return String.join(delimiter, items.toArray(new String[0]));
    }

    public String getPreparedCallableStatementWithParams(String spName, final int paramCount) {
        return "{call " + spName + "(" + zipJoinWithDelimiter(paramCount, "?", ",") + ")}";
    }

    public String getSqlCreateTableDdl(String tableName, List<SqlFieldDef> fieldDefs) {
        List<String> fields = fieldDefs.stream().map(x -> {
            StringBuilder sb1 = new StringBuilder();
            sb1.append("  [").append(x.getFieldName()).append("] ").append(x.getFieldType());
            int size = x.getSize() > 0 ? x.getSize() : 1;
            if (SqlFieldDef.FieldType.VARCHAR.equals(x.getFieldType())) {
                sb1.append("(").append(size).append(")");
            }
            return sb1.toString();
        }).collect(Collectors.toList());

        StringBuilder sb = new StringBuilder();
        sb.append("CREATE TABLE [").append(tableName).append("] (\n");
        sb.append(zipJoin(fields, ",\n", "", ""));
        sb.append("\n)\n");
        return sb.toString();
    }

    public List<String> splitQueries(final String queries, final String delimiter) {
        return Arrays.stream(queries.split(delimiter))
                .map(String::trim)
                .collect(Collectors.toList());

    }
}
