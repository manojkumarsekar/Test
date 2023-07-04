#Feature History
#TOM-4336 : Initial Feature File
# regression tag is not required as this is one time check.
@tom_4336 @verify_trdss_installation
Feature: TR-DSS | Package Installation

  Scenario: Verify 'Reuters DataScope Select Bond Schedules' is successfully installed in GC

    Given I expect value of column "PKG_VER" in the below SQL query equals to "1":
    """
    select count(*) as PKG_VER from ft_t_iicp
    where DEPLOY_PKG_NME='Reuters DataScope Select Bond Schedules'
    and PKG_VER_ID = '8.99.20.0'
    """

  Scenario: Verify 'Reuters DataScope Select Terms and Conditions' is successfully installed in GC

    Given I expect value of column "PKG_VER" in the below SQL query equals to "1":
    """
    select count(*) as PKG_VER from ft_t_iicp
    where DEPLOY_PKG_NME='Reuters DataScope Select Terms and Conditions'
    and PKG_VER_ID = '8.99.40.2'
    """

  Scenario: Verify 'Reuters DataSets' is successfully installed in GC

    Given I expect value of column "PKG_VER" in the below SQL query equals to "1":
    """
    select count(*) as PKG_VER from ft_t_iicp
    where DEPLOY_PKG_NME='Reuters DataSets'
    and PKG_VER_ID = '2019.02.14.0'
    """

  Scenario: Verify 'Starterset GSDM VDDB Oracle' is successfully installed in GC

    Given I expect value of column "PKG_VER" in the below SQL query equals to "1":
    """
    select count(*) as PKG_VER from ft_t_iicp
    where DEPLOY_PKG_NME='Starterset GSDM VDDB Oracle'
    and PKG_VER_ID = '8.7.0.92'
    """

  Scenario: Verify 'Datamodel GSDM Oracle' is successfully installed in GC

    Given I expect value of column "PKG_VER" in the below SQL query equals to "1":
    """
    select count(*) as PKG_VER from ft_t_iicp
    where DEPLOY_PKG_NME='Datamodel GSDM Oracle'
    and PKG_VER_ID = '8.7.0.90'
    """

  Scenario: Verify 'Datamodel Meta Model Oracle' is successfully installed in GC

    Given I expect value of column "PKG_VER" in the below SQL query equals to "1":
    """
    select count(*) as PKG_VER from ft_t_iicp
    where DEPLOY_PKG_NME='Datamodel Meta Model Oracle'
    and PKG_VER_ID = '8.7.0.77'
    """

  Scenario: Verify 'Connection Base' is successfully installed in GC

    Given I expect value of column "PKG_VER" in the below SQL query equals to "1":
    """
    select count(*) as PKG_VER from ft_t_iicp
    where DEPLOY_PKG_NME='Connection Base'
    and PKG_VER_ID = '8.99.24.0'
    """

  Scenario: Verify 'Reuters-Common' is successfully installed in GC

    Given I expect value of column "PKG_VER" in the below SQL query equals to "1":
    """
    select count(*) as PKG_VER from ft_t_iicp
    where DEPLOY_PKG_NME='Reuters-Common'
    and PKG_VER_ID = '8.99.17.0'
    """

  Scenario: Verify 'Reuters Base' is successfully installed in GC

    Given I expect value of column "PKG_VER" in the below SQL query equals to "1":
    """
    select count(*) as PKG_VER from ft_t_iicp
    where DEPLOY_PKG_NME='Reuters Base'
    and PKG_VER_ID = '8.7.0.07'
    """

  Scenario: Verify 'Reuters Workflows' is successfully installed in GC

    Given I expect value of column "PKG_VER" in the below SQL query equals to "1":
    """
    select count(*) as PKG_VER from ft_t_iicp
    where DEPLOY_PKG_NME='Reuters Workflows'
    and PKG_VER_ID = '8.7.0.67'
    """

  Scenario: Verify 'Reuters DataSets' is successfully installed in VDDB

    Given I set the database connection to configuration "dmp.db.VD"

    Given I expect value of column "PKG_VER" in the below SQL query equals to "1":
    """
    select count(*) as PKG_VER from ft_t_iicp
    where DEPLOY_PKG_NME='Reuters DataSets'
    and PKG_VER_ID = '2019.02.14.0'
    """

  Scenario: Verify 'Reuters Base' is successfully installed in VDDB

    Given I set the database connection to configuration "dmp.db.VD"

    Given I expect value of column "PKG_VER" in the below SQL query equals to "1":
    """
    select count(*) as PKG_VER from ft_t_iicp
    where DEPLOY_PKG_NME='Reuters Base'
    and PKG_VER_ID = '8.7.0.07'
    """

  Scenario: Verify 'Starterset GSDM VDDB Oracle' is successfully installed in VDDB

    Given I set the database connection to configuration "dmp.db.VD"

    Given I expect value of column "PKG_VER" in the below SQL query equals to "1":
    """
    select count(*) as PKG_VER from ft_t_iicp
    where DEPLOY_PKG_NME='Starterset GSDM VDDB Oracle'
    and PKG_VER_ID = '8.7.0.92'
    """

  Scenario: Verify 'Datamodel VDDB Oracle' is successfully installed in VDDB

    Given I set the database connection to configuration "dmp.db.VD"

    Given I expect value of column "PKG_VER" in the below SQL query equals to "1":
    """
    select count(*) as PKG_VER from ft_t_iicp
    where DEPLOY_PKG_NME='Datamodel VDDB Oracle'
    and PKG_VER_ID = '8.7.0.90'
    """

  Scenario: Verify 'Datamodel Meta Model Oracle' is successfully installed in VDDB

    Given I set the database connection to configuration "dmp.db.VD"

    Given I expect value of column "PKG_VER" in the below SQL query equals to "1":
    """
    select count(*) as PKG_VER from ft_t_iicp
    where DEPLOY_PKG_NME='Datamodel Meta Model Oracle'
    and PKG_VER_ID = '8.7.0.77'
    """