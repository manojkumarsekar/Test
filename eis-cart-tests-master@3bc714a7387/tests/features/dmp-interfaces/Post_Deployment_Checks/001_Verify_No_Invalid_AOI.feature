#eisdev-4693 : AOI can become INVALID if there is change in the underlying GSO. Publishing Profile must be committed to rebuild AOI.
#eisdev-6294 : as part of this jira invalid publishing profile EIS_DMP_TO_RDM_SSDR_TRADE_UAT_SUB has been removed. removing the check for it's corresponding aofi from ff

@dmp_regression_unittest
@post_deployment_check
@eisdev_4693 @eisdev_6294
Feature: 001 | Misc | AOI Verification
  Verify all AOI are valid post deployment of new package

  Scenario: Data verification in GC for ISSU
  Expect no invalid AOI entry are present in AOFI table

    Given I expect value of column "aoi_count" in the below SQL query equals to "0":
    """
    select count(*) as aoi_count from ft_cfg_aofi
    where aofi_used_typ = 'D'
    and end_tms is null
    """