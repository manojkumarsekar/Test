package com.eastspring.tom.cart.core.utl;

import org.apache.poi.ss.usermodel.*;

public class ExcelFormatUtil {
    public class ComparisonHighlightCellStyles{
        private CellStyle left;
        private CellStyle right;

        public ComparisonHighlightCellStyles(CellStyle left, CellStyle right) {
            this.left = left;
            this.right = right;
        }

        public CellStyle getLeft() {
            return left;
        }

        public CellStyle getRight() {
            return right;
        }
    }

    public ComparisonHighlightCellStyles getComparisonHighlightCellStyles(Workbook workbook) {
        CellStyle left = workbook.createCellStyle();
        left.setFillForegroundColor(IndexedColors.LIGHT_YELLOW.getIndex());
        left.setBorderTop(BorderStyle.THIN);
        left.setBorderLeft(BorderStyle.THIN);
        left.setBorderRight(BorderStyle.DASHED);
        left.setBorderBottom(BorderStyle.THIN);
        left.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        left.setRightBorderColor(IndexedColors.RED.getIndex());
        Font font = workbook.createFont();
        font.setBold(true);
        font.setColor(IndexedColors.RED.getIndex());
        left.setFont(font);

        CellStyle right = workbook.createCellStyle();
        right.setFillForegroundColor(IndexedColors.LIGHT_YELLOW.getIndex());
        right.setBorderTop(BorderStyle.THIN);
        right.setBorderRight(BorderStyle.THIN);
        right.setBorderBottom(BorderStyle.THIN);
        right.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        right.setFont(font);

        return new ComparisonHighlightCellStyles(left, right);
    }
    public CellStyle getComparisonHighlightCellStyle(Workbook workbook) {
        CellStyle redCellStyle = workbook.createCellStyle();
        redCellStyle.setFillForegroundColor(IndexedColors.ROSE.getIndex());
        redCellStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        Font font = workbook.createFont();
        font.setBold(true);
        font.setColor(IndexedColors.BLACK.getIndex());
        redCellStyle.setFont(font);
        return redCellStyle;
    }
}
