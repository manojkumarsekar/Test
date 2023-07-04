#https://jira.pruconnect.net/browse/EISDEV-7300 : Enable SSDR Fundapps fields GS UI Issue Screen

@web @gc_ui_instrument @gs_ui_regression @eisdev_7300 @eisdev_7300_ui_issue @eisdev_7359

Feature: Create New Issue for SSDR editable controls which are enabled by EISDEV7300 ticket

  This feature file can be used to check the SSDR editable controls.
  List of newly added controls are commented in the issue screen

  Scenario: Create new issue with SSDR editable fields under different tabs and
  Verify new issue has created successfully.

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "HMs" and assign to variable "VAR_RANDOM"
    And I assign "TST_INSTNAME_${VAR_RANDOM}" to variable "INTSR_NAME"

    When I enter below Instrument Details for new Issue
      | Instrument Name          | ${INTSR_NAME}           |
      | Instrument Description   | TST_INSTDESC            |
      | Instrument Type          | Equity Share            |
      | Pricing Method           | 100 Pieces              |
      | Instrument System Status | Active                  |
      | Source Currency          | HKD - Hong Kong Dollar  |
      | Target Currency          | AUD - Australian Dollar |

    And I add below Market Listing details
      | Exchange Name             | UBS AG LONDON BRANCH EMEA TRADING |
      | Primary Market Indicator  | Original                          |
      | Market Status             | Acquired                          |
      | Trading Currency          | HKD - Hong Kong Dollar            |
      | Market Listing Created On | T                                 |

    And I add below Market level Identifiers under Market Listing
      | RDM Code | RDM_${VAR_RANDOM} |

    And I add below Classification
      | Reuters Classification Scheme | EQUITY ETFS |

    And I add below Market Features under Market Listing
      | SSDR Round Lot | 1 |

    And I add below Fundapps Issue Attributes
      | Delta                             | 11           |
      | Convertible Data Indicator        | No           |
      | Close Price                       | 12           |
      | Total Issued Nominal Cap          | 13           |
      | Total Shares In Treasury          | 14           |
      | RDM SecType                       | COM          |
      | Fund Shares Outstanding           | 15.15        |
      | Total Net Assets                  | 16.35        |
      | Reuters Shares Outstanding        | 17           |
      | Listed Shares Issue Shares Amount | 18           |
      | Total Shares Outstanding          | 19           |
      | Conversion Ratio                  | 20           |
      | Asset Ratio Against               | 21.22        |
      | Asset Ratio For                   | 22.5         |
      | Market Capitalization             | 23           |
      | Exchange Country Code             | AUSTRALIA    |
      | Total Shares Issued               | 24           |
      | Total Voting Rights               | 25.7         |
      | Total Voting Rights Unlisted      | 26.3         |
      | Total Voting Rights Listed        | 27.5         |
      | Total Voting Shares               | 28.87        |
      | Total Voting Shares Issued        | 29           |
      | Total Voting Shares Unlisted      | 30           |
      | Total Voting Shares Listed        | 31           |
      | Total Voting Shares Outstanding   | 32           |
      | Close Price Currency              | Indian Rupee |
      | Close Price Date                  | 16-Feb-2021  |

    And I add below Fundapps MIC List
      | MIC Code             | ZZZZ |
      | Participation Amount | 33   |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "${INTSR_NAME}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "${INTSR_NAME}"

    And I relogin to golden source UI with "task_assignee" role
    And I open existing Issue "${INTSR_NAME}"

    And I update below Classification
      | Reuters Classification Scheme | EXTF |

    And I update below Market Features under Market Listing
      | SSDR Round Lot | 10 |

    And I update below Fundapps Issue Attributes
      | Delta                             | 110          |
      | Convertible Data Indicator        | Cum Dividend |
      | Close Price                       | 120          |
      | Total Issued Nominal Cap          | 130          |
      | Total Shares In Treasury          | 140          |
      | RDM SecType                       | COM          |
      | Fund Shares Outstanding           | 150.07       |
      | Total Net Assets                  | 160.6        |
      | Reuters Shares Outstanding        | 170          |
      | Listed Shares Issue Shares Amount | 180          |
      | Total Shares Outstanding          | 190          |
      | Conversion Ratio                  | 200          |
      | Asset Ratio Against               | 210.56       |
      | Asset Ratio For                   | 220.09       |
      | Market Capitalization             | 230          |
      | Exchange Country Code             | AUSTRIA      |
      | Total Shares Issued               | 240          |
      | Total Voting Rights               | 250.9        |
      | Total Voting Rights Unlisted      | 260.72       |
      | Total Voting Rights Listed        | 270.12       |
      | Total Voting Shares               | 280.03       |
      | Total Voting Shares Issued        | 290          |
      | Total Voting Shares Unlisted      | 300          |
      | Total Voting Shares Listed        | 310          |
      | Total Voting Shares Outstanding   | 320          |

    And I update below Fundapps MIC List
      | MIC Code             | KOME |
      | Participation Amount | 330  |

    And I save the modified data

    Then I expect a record in My WorkList with entity name "${INTSR_NAME}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "${INTSR_NAME}"

    And I relogin to golden source UI with "task_assignee" role
    And I open existing Issue "${INTSR_NAME}"

    And  I expect below Classification details updated
      | Reuters Classification Scheme | EXTF |

    And I expect below Market Features under Market Listing updated
      | SSDR Round Lot | 10 |

    And I expect below Fundapps Issue Attributes details updated
      | Delta                             | 110          |
      | Convertible Data Indicator        | Cum Dividend |
      | Close Price                       | 120          |
      | Total Issued Nominal Cap          | 130          |
      | Total Shares In Treasury          | 140          |
      | RDM SecType                       | COM          |
      | Fund Shares Outstanding           | 150.07       |
      | Total Net Assets                  | 160.6        |
      | Reuters Shares Outstanding        | 170          |
      | Listed Shares Issue Shares Amount | 180          |
      | Total Shares Outstanding          | 190          |
      | Conversion Ratio                  | 200          |
      | Asset Ratio Against               | 210.56       |
      | Asset Ratio For                   | 220.09       |
      | Market Capitalization             | 230          |
      | Exchange Country Code             | AUSTRIA      |
      | Total Shares Issued               | 240          |
      | Total Voting Rights               | 250.9        |
      | Total Voting Rights Unlisted      | 260.72       |
      | Total Voting Rights Listed        | 270.12       |
      | Total Voting Shares               | 280.03       |
      | Total Voting Shares Issued        | 290          |
      | Total Voting Shares Unlisted      | 300          |
      | Total Voting Shares Listed        | 310          |
      | Total Voting Shares Outstanding   | 320          |

    And I expect below Fundapps MIC List details updated
      | MIC Code             | KOME |
      | Participation Amount | 330  |