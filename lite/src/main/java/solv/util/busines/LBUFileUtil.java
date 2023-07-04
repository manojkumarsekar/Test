package com.eastspring.qa.solvency.utils.business;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.solvency.lookup.LBUFileType;
import com.eastspring.qa.solvency.lookup.LBURegionCode;
import com.eastspring.qa.solvency.utils.common.DateTimeUtil;
import org.apache.commons.lang3.EnumUtils;
import stepdefinitions.Solvency.BaseSolvencySteps;

import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.stream.Collectors;


public class LBUFileUtil extends BaseSolvencySteps {

    public static LBUFileType lookupFileType(String fileType) {
        if (!EnumUtils.isValidEnum(LBUFileType.class, fileType.toUpperCase())) {
            throw new CartException(CartExceptionType.INVALID_PARAM,
                    "Input LBU file type '[{}]' is invalid. List of valid values: [{}]",
                    fileType,
                    Arrays.stream(LBUFileType.values()).map(Enum::toString).collect(Collectors.joining(","))
            );
        }
        return LBUFileType.valueOf(fileType.toUpperCase());
    }

    public static LBURegionCode lookupLbuCode(String lbuRegionCode) {
        if (!EnumUtils.isValidEnum(LBURegionCode.class, lbuRegionCode.toUpperCase())) {
            throw new CartException(CartExceptionType.INVALID_PARAM,
                    "Input LBU region code '[{}]' is invalid. List of valid values: [{}]",
                    lbuRegionCode,
                    Arrays.stream(LBURegionCode.values()).map(Enum::toString).collect(Collectors.joining(","))
            );
        }
        return LBURegionCode.valueOf(lbuRegionCode);
    }

    public static String getTestFileName(LBURegionCode lbuRegionCode, LBUFileType fileType, String targetMonth) {
        String monthEndTimeStamp = new SimpleDateFormat("ddMMyyyy").format(DateTimeUtil.getMonthEndDate(targetMonth));
        String lookupBaseFileName = getBaseFileName(fileType, lbuRegionCode);
        return lookupBaseFileName.replace("BASE_FILE", monthEndTimeStamp);
    }

    // overload with inputBaseFileName - for user readability from features
    public static String getTestFileName(LBURegionCode lbuRegionCode, LBUFileType lbuFileType, String targetMonth, String inputBaseFileName) {
        String monthEndTimeStamp = new SimpleDateFormat("ddMMyyyy").format(DateTimeUtil.getMonthEndDate(targetMonth));
        String lookupBaseFileName = getBaseFileName(lbuFileType, lbuRegionCode);
        if (!lookupBaseFileName.equalsIgnoreCase(inputBaseFileName)) {
            throw new CartException(CartExceptionType.ASSERTION_ERROR,
                    "The input base-file name '[{}]' is not as expected ('[{}]') for [{}]-[{}]",
                    inputBaseFileName, lookupBaseFileName, lbuRegionCode, lbuFileType);
        }
        return lookupBaseFileName.replace("BASE_FILE", monthEndTimeStamp);
    }

    public static String getBaseFileName(LBUFileType lbuFileType, LBURegionCode lbuRegionCode) {
        String templateFileName = "";
        if (lbuFileType.equals(LBUFileType.PORTFOLIO) && lbuRegionCode.equals(LBURegionCode.LBU_1090)) {
            templateFileName = "1090_POR_01_BASE_FILE.csv";
        }
        else if(lbuFileType.equals(LBUFileType.POSITION) && lbuRegionCode.equals(LBURegionCode.LBU_1090)) {
            templateFileName = "1090_POS_01_BASE_FILE.csv";
        }
        else if(lbuFileType.equals(LBUFileType.POSITION) && lbuRegionCode.equals(LBURegionCode.LBU_984)) {
            templateFileName = "984_POS_01_BASE_FILE.csv";
        }

        else {
            throw new CartException(CartExceptionType.INVALID_PARAM, "test is not configured for [{}]-[{}]", lbuRegionCode, lbuFileType);
        }
        return templateFileName;
    }



}