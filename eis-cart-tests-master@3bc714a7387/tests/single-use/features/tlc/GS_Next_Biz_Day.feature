@gs_cal
Feature: GS Calendar functionality should consider Public Holidays, Weekends of a specific region

  Background:
    Given Date is ISO Format YYYY-MM-DD
    And An Increment is in the format T+x where x is a number of Business Days

  Scenario Outline: GS Functionality to Consider weekends and Public Holidays

    Given A date <Curr_Date>
    When I add <Increment> business days to given date
    Then I expect next date as <New_Date>

    Examples:
      | Curr_Date  | Increment | New_Date   |
      | 2018-06-08 | 0         | 2018-06-08 |
      | 2018-06-08 | 1         | 2018-06-11 |
      | 2018-06-08 | 2         | 2018-06-12 |
      | 2018-06-14 | 1         | 2018-06-18 |
      | 2018-06-13 | 2         | 2018-06-18 |
      | 2018-06-14 | 2         | 2018-06-19 |
      | 2018-02-28 | 1         | 2018-03-01 |
      | 2018-02-28 | 2         | 2018-03-02 |
      | 2018-02-28 | 3         | 2018-03-05 |
      | 2017-12-29 | 2         | 2018-01-03 |
      | 2016-02-26 | 1         | 2016-02-29 |
      | 2016-02-25 | 2         | 2016-02-29 |
      | 2016-02-29 | 2         | 2016-03-02 |
      | 2018-12-21 | 2         | 2018-12-26 |
      | 2018-12-21 | 3         | 2018-12-27 |
      | 2018-12-24 | 2         | 2018-12-27 |
      | 2018-01-02 | 1         | 2018-01-03 |
      | 2018-01-02 | 4         | 2018-01-08 |
      | 2018-08-14 | 2         | 2018-08-16 |
      | 2018-08-20 | 2         | 2018-08-23 |
