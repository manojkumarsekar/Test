package com.eastspring.qa.solvency.utils.business;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.solvency.lookup.LBURegionCode;
import com.eastspring.qa.solvency.lookup.ReportType;
import com.eastspring.qa.solvency.utils.common.DateTimeUtil;
import stepdefinitions.Solvency.BaseSolvencySteps;


import java.text.SimpleDateFormat;


public class ReportFileUtil extends BaseSolvencySteps {

    public static String  monthEndTimeStamp ="";

    public static String getActualReportFileName(LBURegionCode lbuRegionCode, ReportType reportType, String targetMonth) {
        monthEndTimeStamp = new SimpleDateFormat("yyyyMMdd").format(DateTimeUtil.getMonthEndDate(targetMonth));
        String lookupReferenceReportName = getReferenceReportFileName(reportType, lbuRegionCode);
        return lookupReferenceReportName.replace("REFERENCE_REPORT", monthEndTimeStamp);
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
        if (reportType.equals(ReportType.LBU_REPORTS) && lbuRegionCode.equals(LBURegionCode.LBU_1090)) {
            referenceReportFileName = "4-00_ALL_1090.xls";
        } else if (reportType.equals(ReportType.GHO_REPORT_ICP) && lbuRegionCode.equals(LBURegionCode.LBU_1090)) {
            referenceReportFileName = "4-00_ICP_PCAP_1090.csv";
        } else if (reportType.equals(ReportType.GHO_REPORT_INS) && lbuRegionCode.equals(LBURegionCode.LBU_1090)) {
            referenceReportFileName = "4-00_INS_PCAP_1090.csv";
        } else if (reportType.equals(ReportType.GHO_REPORT_POR) && lbuRegionCode.equals(LBURegionCode.LBU_1090)) {
            referenceReportFileName = "4-00_POR_PCAP_1090.csv";
        } else if (reportType.equals(ReportType.GHO_REPORT_TRP) && lbuRegionCode.equals(LBURegionCode.LBU_1090)) {
            referenceReportFileName = "4-00_TRP_PCAP_1090.csv";
        } else if (reportType.equals(ReportType.REGIONAL_REPORT) && lbuRegionCode.equals(LBURegionCode.LBU_1090)) {
            referenceReportFileName = "4-00_ALL_PITL_1090.xls";
        } else if (reportType.equals(ReportType.LBUCONSOL_REPORT) && lbuRegionCode.equals(LBURegionCode.LBU_1090)) {
            referenceReportFileName = "4-00_LBUConsolCompareReport_TRP_PITL_1090_REFERENCE_REPORT.xls";
        } else if (reportType.equals(ReportType.GHO_INTEGRITY) && lbuRegionCode.equals(LBURegionCode.LBU_1090)) {
            referenceReportFileName = "4-00_GHOIntegrityReport_PITL_1090_REFERENCE_REPORT.xls";
        }   else if (reportType.equals(ReportType.CIC_D1_D2O) && lbuRegionCode.equals(LBURegionCode.LBU_1090)) {
            referenceReportFileName = "4-00_GHOValidationReport_PITL_1090_REFERENCE_REPORT.xls";
        }else if (reportType.equals(ReportType.FXRATECOMPARISON_REPORT) && lbuRegionCode.equals(LBURegionCode.LBU_1090)) {
            referenceReportFileName = "4-00_FXRateComparisonReport_PITL_1090_REFERENCE_REPORT.xls";

        } else {
            throw new CartException(CartExceptionType.INVALID_PARAM, "test is not configured for [{}]-[{}]", lbuRegionCode, reportType);
        }
        return referenceReportFileName;
    }

    public static int getLastRowNumber(String lastRow) {
        int lastRowNumber = 0;
        switch (lastRow.toLowerCase()) {
            case "remove-1":
                lastRowNumber = 1;
                break;
            case "remove-2":
                lastRowNumber = 2;
                break;
            case "remove-4":
                lastRowNumber = 4;
                break;
            case "current":
                break;
            case "remove-5":
            case "previous":
            case "last":
                lastRowNumber = -1;
                break;
            default:
                throw new CartException(CartExceptionType.INVALID_PARAM,
                        "Input lastRow target '[{}]' is invalid",
                        lastRowNumber);
        }
        return  lastRowNumber;
    }


}