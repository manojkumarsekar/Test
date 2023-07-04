package com.eastspring.qa.solvency.utils.business;


import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.solvency.lookup.LBURegionCode;
import com.eastspring.qa.solvency.lookup.ReportType;
import com.eastspring.qa.solvency.utils.common.DateTimeUtil;
import org.apache.commons.lang3.EnumUtils;
import stepdefinitions.Solvency.BaseSolvencySteps;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.stream.Collectors;


public class ValidationReportFileUtil extends BaseSolvencySteps {


    public static String  monthEndTimeStamp ="";

    public static ReportType lookupReportType(String reportType) {
        if (!EnumUtils.isValidEnum(ReportType.class, reportType.toUpperCase())) {
            throw new CartException(CartExceptionType.INVALID_PARAM,
                    "Input validation report type '[{}]' is invalid. List of valid values: [{}]",
                    reportType,
                    Arrays.stream(ReportType.values()).map(Enum::toString).collect(Collectors.joining(","))
            );
        }

        return ReportType.valueOf(reportType.toUpperCase());
    }


    public static String getActualReportFileName(LBURegionCode lbuRegionCode, ReportType reportType, String targetMonth) {
        monthEndTimeStamp = new SimpleDateFormat("yyyyMMdd").format(DateTimeUtil.getMonthEndDate(targetMonth));
        String lookupReferenceReportName = getReferenceReportFileName(reportType, lbuRegionCode);
        return lookupReferenceReportName.replace("REFERENCE_REPORT", monthEndTimeStamp);
    }

    public static String getActualReportFileName(String targetMonth, ReportType reportType, LBURegionCode lbuRegionCode, String inputReferenceReportName) {
        String monthEndTimeStamp = new SimpleDateFormat("yyyyMMdd").format(DateTimeUtil.getMonthEndDate(targetMonth));
        assertReferenceReportFileName(reportType, lbuRegionCode, inputReferenceReportName);
        return inputReferenceReportName.replace("REFERENCE_REPORT", monthEndTimeStamp);
    }

    public static void assertReferenceReportFileName(ReportType reportType, LBURegionCode lbuRegionCode, String inputReferenceReportName) {
        String lookupReferenceReportName = getReferenceReportFileName(reportType, lbuRegionCode);
        if (!lookupReferenceReportName.equalsIgnoreCase(inputReferenceReportName)) {
            throw new CartException(CartExceptionType.ASSERTION_ERROR,
                    "The input reference report name '[{}]' is not as expected ('[{}]') for [{}]-[{}]",
                    inputReferenceReportName, lookupReferenceReportName, lbuRegionCode, reportType);
        }
        CartLogger.info("Input reference report file name '[{}]' is same as expected", lookupReferenceReportName);
    }

    public static String getReferenceReportFileName(ReportType reportType, LBURegionCode lbuRegionCode) {
        String referenceReportFileName = "";
        if (reportType.equals(ReportType.CIC_D1_D2O) && lbuRegionCode.equals(LBURegionCode.LBU_1090)) {
            referenceReportFileName = "4-00_GHOValidationReport_PITL_1090_REFERENCE_REPORT.xls";
        } else if (reportType.equals(ReportType.GHO_INTEGRITY) && lbuRegionCode.equals(LBURegionCode.LBU_1090)) {
            referenceReportFileName = "4-00_GHOIntegrityReport_PITL_1090_REFERENCE_REPORT.xls";
        } else if (reportType.equals(ReportType.LBUCONSOL_REPORT) && lbuRegionCode.equals(LBURegionCode.LBU_1090)) {
            referenceReportFileName = "4-00_LBUConsolCompareReport_TRP_PITL_1090_REFERENCE_REPORT.xls";
        } else if (reportType.equals(ReportType.FXRATECOMPARISON_REPORT) && lbuRegionCode.equals(LBURegionCode.LBU_1090)) {
            referenceReportFileName = "4-00_FXRateComparisonReport_PITL_1090_REFERENCE_REPORT.xls";

        } else{
            throw new CartException(CartExceptionType.INVALID_PARAM, "test is not configured for [{}]-[{}]", lbuRegionCode, reportType);
        }
        return referenceReportFileName;
    }

}