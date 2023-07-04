#Feature History
#TOM-4402 : Initial Feature File
# regression tag is not required as this is one time check.
@tom_4402 @verify_trdss_installation
Feature: TR-DSS | Pre-Installation Script to create Markets for RTEXCH

  Scenario: Verification for MKID Set up for RTEXCH Codes

    Given I expect value of column "RTEXCH_COUNT" in the below SQL query equals to "66":
    """
    SELECT COUNT(*) AS RTEXCH_COUNT FROM FT_T_MKID WHERE MKT_ID IN ('CCE','CLU','CMA','COK','CTE','CWS','EXR','FSP','GME','LIP','MCA','MG2','MKX','NPG',
    'NYF','NYQ','PSM','IMQ','ST1','CLI','MTO','NFX','NOX','PQX','TGE','TRA','UNL','BKG','CMU','COX','MCH','MFO','NGA','PWX','ABM',
    'CBA','MS2','MST','SIK','ICP','XIM','BYX','CBE','CLT','MCS','IMC','TWB','ASG','BBK','CAT','CPR','CRN','CVA','EOE','LQN','MRF',
    'POD','CBU','ENO','LBA','MX2','TBS','TUD','BT1','CPL','BZX')
    AND MKT_ID_CTXT_TYP = 'RTEXCH'
    """