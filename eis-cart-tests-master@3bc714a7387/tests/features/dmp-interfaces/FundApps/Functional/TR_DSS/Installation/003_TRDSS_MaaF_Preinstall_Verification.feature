#Feature History
#TOM-4403 : Initial Feature File
# regression tag is not required as this is one time check.
@tom_4403 @verify_trdss_installation
Feature: TR-DSS | Post-Installation Script to create Align ALADDIN Codes with RTEXCH Codes

  Scenario: Verification for Delinking ALADDIN codes from MIC Market and set up for ALADDIN Codes on RTEXCH Market

    Given I expect value of column "ALADDIN_COUNT_END_DATED" in the below SQL query equals to "29":
    """
    SELECT COUNT(*) AS ALADDIN_COUNT_END_DATED FROM FT_T_MKID WHERE MKT_ID IN ('ACE','ARM','AFF','ELS','MTR','ODE','PFF','ROS','COR',
    'MTZ','RUS','ISL','TOF','MTT','PDE','HUM','LFX','IFE','ASU','MSL','OTI','CT1','MAN','MTU','UEX','AIF','MTI','MTK','SFX')
    AND MKT_ID_CTXT_TYP = 'ALADDIN'
    AND END_TMS IS NOT NULL
    AND LAST_CHG_USR_ID='TOM-4403:MKT_ALIGN'
    """


    Given I expect value of column "ALADDIN_COUNT_ACTIVE" in the below SQL query equals to "29":
    """
    SELECT COUNT(*) AS ALADDIN_COUNT_ACTIVE FROM FT_T_MKID WHERE MKT_ID IN ('ACE','ARM','AFF','ELS','MTR','ODE','PFF','ROS','COR',
    'MTZ','RUS','ISL','TOF','MTT','PDE','HUM','LFX','IFE','ASU','MSL','OTI','CT1','MAN','MTU','UEX','AIF','MTI','MTK','SFX')
    AND MKT_ID_CTXT_TYP = 'ALADDIN'
    AND END_TMS IS NULL
    AND LAST_CHG_USR_ID='TOM-4403:MKT_ALIGN'
    """