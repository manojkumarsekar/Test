Feature: TC_FXSPOT_01 - Trade Lifecycle

  @tlc9000 @tlc9000_fx @tlc9000_fxspots
  Scenario Outline: TC_FXSPOT_01: BUY_GBPSGD_<TxnStatus>

    Given I place "FXSpot" order for:
      | Portfolio | FundId | Instrument | TxnType |
      | TSTALCHEF | 4033   | GBPSGD     | BUY     |

    And I generate trade nuggets for below trade params:
      | TxnStatus  | <TxnStatus>  |
      | TradeDate  | <TradeDate>  |
      | SettleDate | <SettleDate> |
      | TradeQty   | <TrdQty>     |
      | TradePrice | <TrdPrice>   |
      | ExBroker   | <ExBroker>   |
      | ExDeskType | <ExDeskType> |

    When I initiate trade life cycle workflow

    Then I expect trade nuggets are successfully archived
    And I expect trade nuggets entry is made in DMP

    Then I expect trade ack status file is successfully archived
    And I expect trade ack status entry is made in DMP

    Examples: Trade Params
      | TxnStatus | TradeDate | SettleDate | TrdQty | TrdPrice | ExBroker | ExDeskType |
      | New       | T         | T+1        | 370000 | 1.834072 | CITI-ES  | CITI-SG    |
      | Amend     | T         | T+1        | 370000 | 1.834072 | ANZG-ES  | ANZG-SG    |
      | Cancel    | T         | T+1        | 370000 | 1.834072 | ANZG-ES  | ANZG-SG    |
