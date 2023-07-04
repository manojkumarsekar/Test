#Feature History
#TOM-4409 : Initial Feature File
# regression tag is not required as this is one time check.
@tom_4409 @verify_trdss_installation
Feature: TR-DSS | Package Installation

  Scenario: Verify 'Reuters-Common' is successfully installed in GC

    Given I expect value of column "PKG_VER" in the below SQL query equals to "1":
    """
    select count(*) as PKG_VER from ft_t_iicp
    where DEPLOY_PKG_NME='Reuters-Common'
    and PKG_VER_ID = '8.99.17.0'
    """