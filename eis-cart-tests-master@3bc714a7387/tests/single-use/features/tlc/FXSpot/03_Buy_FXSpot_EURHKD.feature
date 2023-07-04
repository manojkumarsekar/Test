Feature: TC_FXSPOT_03 - Trade Lifecycle

  @tlc9000 @tlc9000_fx @tlc9000_fxspots
  Scenario Outline: TC_FXSPOT_03: BUY_EURHKD_<TxnStatus>

    Given I place "FXSpot" order for:
      | Portfolio | FundId | Instrument | TxnType |
      | TSTALCHEF | 4033   | EURHKD     | Buy     |

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
      | TxnStatus | TradeDate | SettleDate | TrdQty  | TrdPrice | ExBroker | ExDeskType |
      | New       | T         | T+1        | 4600000 | 9.4736   | HSBC-ES  | HSBC-SG     |
      | Amend     | T         | T+1        | 5600000 | 9.4736   | HSBC-ES  | HSBC-SG     |
      | Cancel    | T         | T+1        | 5600000 | 9.4736   | HSBC-ES  | HSBC-SG     |
