package com.eastspring.tom.cart.core.utl;


import java.util.Formatter;
import java.util.Locale;

/**
 *
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class FormatterUtil {

    /**
     * @param formatString
     * @param args
     * @return
     */
    public String format(String formatString, Object... args) {
        StringBuilder sb = new StringBuilder();

        try (Formatter formatter = new Formatter(sb, Locale.US)) {
            formatter.format(formatString, args);
            return sb.toString();
        }
    }
}
