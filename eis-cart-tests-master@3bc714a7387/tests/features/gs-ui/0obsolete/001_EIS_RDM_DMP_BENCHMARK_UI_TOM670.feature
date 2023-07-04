Feature: Golden Source Portal Web UI Benchmark Tests

    The Data Management Platform (DMP) leverages the solutions from vendor Golden Source.
    One of the components of the Golden Source is the Golden Source Portal where users will
    be able to view and manage the data through the Web User Interface.

  Background:
    Given I open a web session from URL "http://vsgeisldapp07.pru.intranet.asia:8780/GS"
    When I enter the text "test1" into web element with id "j_username"
    And I enter the text "test1@123" into web element with id "j_password"
    And I submit the form of the web element with id "login"

    @web @benchmark @create
  Scenario: Create New Benchmark

      And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"

      And I assign "50% Test Benchmark ${VAR_RANDOM}" to variable "gs.new.benchmark.name"
      And I assign "SGX Benchmark ${VAR_RANDOM}" to variable "gs.new.official.benchmark.name"

      When I select from GS menu "Benchmark Master::Benchmark"
      And I click the web element "gs.web.menu.Setup"

      When I enter the text "${gs.new.benchmark.name}" into web element "gs.web.create.benchmark.EISBenchmarkName"
      And I enter the text "${gs.new.official.benchmark.name}" into web element "gs.web.create.benchmark.OfficialBenchmarkName"
      And I enter the text "SGD-Singapore Dollar" into web element "gs.web.create.benchmark.Currency" followed by "ENTER" key
      And I enter the text "A - Pending Active" into web element "gs.web.create.benchmark.HedgeIndicator" followed by "ENTER" key
      And I enter the text "AN - Annually" into web element "gs.web.create.benchmark.RebalanceFrequency" followed by "ENTER" key
      And I enter the text "Country Level" into web element "gs.web.create.benchmark.BenchmarkLevelAccess" followed by "ENTER" key
      And I enter the text "UOB - UOB" into web element "gs.web.create.benchmark.BenchmarkProviderName" followed by "ENTER" key
      And I enter the text "Fixed" into web element "gs.web.create.benchmark.BenchmarkCategory" followed by "ENTER" key
      And I enter the text "CRTSCD${VAR_RANDOM}" into web element "gs.web.create.benchmark.CRTSCode"

      And I click the web element "gs.web.menu.Save"
      And I pause for 2 seconds

      Then I expect to see the web element with xpath "//*[@class='v-Notification-caption'][text()='Entity Saved Successfully.']"
      And I take a screenshot
      Then I close all opened web browsers


  @web @benchmark @verify
  Scenario: Verify New Benchmark is created

      When I select from GS menu "Benchmark Master::Benchmark"

      Then I search GS table input column "ESI Benchmark Name" with "${gs.new.benchmark.name}" followed by "ENTER" key
      And I pause for 1 seconds

      Then I expect GS table should have 1 rows
      And I expect GS table column "ESI Benchmark Name" should be "${gs.new.benchmark.name}" for row 1
      And I expect GS table column "Official Benchmark Name" should be "${gs.new.official.benchmark.name}" for row 1
      And I expect GS table column "Currency" should be "SGD-Singapore Dollar" for row 1
      And I expect GS table column "Benchmark Category" should be "Fixed" for row 1

      And I take a screenshot
      Then I close GS tab "Benchmark"
      Then I close all opened web browsers


      @testweb
    Scenario: Login
    Then I close all opened web browsers
