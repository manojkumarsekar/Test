Feature: Golden Source Web UI Smoke Test

    Scenario Outline: Open all menu items and tabs
        Given I open a web session from URL "http://vsgeisldapp07.pru.intranet.asia:8780/GS" only when I don't have an existing sessions
        And I define the login landing page "http://vsgeisldapp07.pru.intranet.asia:8780/GS/protected/index/layout.vm"
        When I enter text "test1" into web element with id "j_username" if I am in login landing page
        And I enter text "test1@123" into web element with id "j_password" if I am in login landing page
        And I submit the form of the web element with id "login" if I am in login landing page
        Then I select from GS menu "<menuitem>"

        Examples:
            |menuitem|
            |Security Master::Issue|
            |Security Master::Instrument Group|
            |Security Master::Issue Type|
            |Security Master::Issue Type Group|
            |Security Master::Issue Ratings|
            |Security Master::Issue Rating Opinions|
            |Security Master::Underlying Issue|
            |Security Master::Mortgage Pool Prefix|
            |Security Master::Property Document|
            |Security Master::Request for Issues|
            |Security Master::Vendor Request Schedule|
            |Security Master::Vendor Request Management|
            |Security Master::Issuer|
            |Security Master::Issuer Group|
            |Security Master::Issuance Conflict Match|
            |Security Master::Issuance Likely Match|
            |Security Master::Exclude Criteria|
            |Security Master::Financial Institution (Multientity)|
            |Security Master::Institution|
            |Security Master::Institution Group|
            |Security Master::Institution Role|
            |Security Master::Institution Role Group|
            |Security Master::Institution Hierarchy|
            |Security Master::Institution Ratings|
            |Security Master::Institution Ratings Opinions|
            |Security Master::Central Cross Reference Group|
            |Security Master::CA Declaration|
            |Security Master::CA Type|
            |Security Master::CA Type Group|
            |Security Master::CA Merge|
            |Security Master::CA Eligibility|
            |Security Master::CA Related Events Query|
            |Security Master::Financial Market|
            |Security Master::Market Group|
            |Security Master::PSET-Subcustodian Master|
            |Security Master::Downstream System Definition|
            |Security Master::Publishing Log|
            |Security Master::Publishing Log Report|
            |Customer Master::Customer|
            |Customer Master::Customer Type|
            |Customer Master::Account|
            |Customer Master::Account Master|
            |Customer Master::Account Group|
            |Customer Master::Account Type|
            |Customer Master::Account Type Group|
            |Customer Master::External Account Search|
            |Customer Master::Internal Account Purpose|
            |Customer Master::Product|
            |Customer Master::Product Group|
            |Customer Master::Product Feature|
            |Customer Master::Product Line|
            |Customer Master::Product Feature Character Definition|
            |Customer Master::Book of Accounts|
            |Customer Master::Enterprise|
            |Customer Master::Subdivisions|
            |Customer Master::Enterprise Group|
            |Customer Master::Employees|
            |Customer Master::Financial Institution|
            |Customer Master::Issuer|
            |Customer Master::Legal Owner|
            |Customer Master::Account|
            |Customer Master::Document Definition|
            |Customer Master::Financial Professionals|
            |Customer Master::Dealer|
            |Customer Master::Dealer Group|
            |Customer Master::Dealer Representative Group|
            |Customer Master::Financial Services Professional|
            |Customer Master::Consulting Firm|
            |Customer Master::Marketing Division|
            |Customer Master::Marketing Group|
            |Customer Master::New Dealer Merge Instructions|
            |Customer Master::Edit Dealer Merge Instructions|
            |Customer Master::New Branch Merge Instructions|
            |Customer Master::Edit Branch Merge Instructions|
            |Customer Master::Table Merge Instructions|
            |Customer Master::Phone Update Instructions|
            |Customer Master::Legal Agreement|
            |Pricing::Issue Price|
            |Benchmark Master::Simple Benchmark|
            |Benchmark Master::Blended Benchmark|
            |Benchmark Master::Enable/Disable Benchmark|
            |Benchmark Master::Constituent Participation|
            |Benchmark Master::Benchmark / Participation Search|
            |Benchmark Master::Benchmark|
            |Benchmark Master::Vendor Benchmark|
            |Benchmark Master::Benchmark & Index Type|
            |Benchmark Master::Benchmark Calculation Options|
            |Benchmark Master::Benchmark Calculation|
            |Benchmark Master::Ad hoc Rebalance|
            |Benchmark Master::Vendor Corrections|
            |Benchmark Master::Benchmark Correction Sequence|
            |Benchmark Master::Benchmark Processing Status|
            |Generic Setup::Geographic Unit|
            |Generic Setup::Geographic Unit Group|
            |Generic Setup::Country Information|
            |Generic Setup::Address|
            |Generic Setup::Statistic Definition|
            |Generic Setup::External Field Definition|
            |Generic Setup::Internal Domain for Data Field|
            |Generic Setup::Internal Domain for Data Field Class|
            |Generic Setup::Industry Classification Set|
            |Generic Setup::Document Definition|
            |Generic Setup::Industry Relationship|
            |Generic Setup::Rating Set Definition|
            |Generic Setup::Calendar Definition|
            |Exception Management::Summary Statistics|
            |Exception Management::Load Error Report|
            |Exception Management::Grouped Exceptions|
            |Exception Management::Transactions & Exceptions|
            |Exception Management::VDDB Compare Exception Details|
            |Exception Management::EOI for Exception|
            |Exception Management::Grouped Configuration|
            |Exception Management::Prioritize Exceptions|
            |Exception Management::VDDB Comparison|
            |Admin::Change Label|
            |Admin::Core Data Setup|
            |Admin::Entity Management|
            |Admin::Exceptions Severity|
            |Admin::GSO Designer|
            |Admin::Match Key Creation|
            |Admin::Model Definition|
            |Admin::Manage Template|
            |Admin::Notification Definition|
            |Admin::Rule UI Configuration|
            |Admin::VSH Configuration|
            |Admin::Listing Level Configuration|
            |Admin::Listing Identifier Configuration|
            |Admin::Application Users|
            |Admin::Application User  Group|
            |Admin::Application Roles|
            |Admin::Class Identifiers|
            |Admin::Entitlements|
            |Admin::Workflow Enabled Models|
            |Admin::Workflow Enabled GSO|
            |DataLineage::Traceability|
            |My Worklist::Vendor Data Compare Details|
            |My Worklist::Issue Completeness - Missing Fields|
            |My Worklist::Issue Completeness - By Asset|
            |My Worklist::Issue Completeness - By Asset & Date|
            |My Worklist::Price Exception Details|
            |My Worklist::Price Exception Summary|
            |My Worklist::My Worklist|
            |My Worklist::Change Approval|
            |My Worklist::Locked Fields Summary|
            |My Worklist::Customer Worklist|
            |My Worklist::Customer Amend|
            |My Worklist::Customer Onboarding|
            |My Worklist::Products & Limits|
