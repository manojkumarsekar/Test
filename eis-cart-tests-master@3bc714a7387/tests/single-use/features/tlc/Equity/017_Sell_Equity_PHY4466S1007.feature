Feature: TC_EQUITY_017 - Trade Lifecycle

  @tlc9000 @tlc9000_equities
  Scenario Outline: TC_EQUITY_017: SELL_PHY4466S1007_<TxnStatus>

    Given I place "Equity" order for:
      | Portfolio | FundId | Instrument   | TxnType |
      | TSTALCHEF | 4033   | PHY4466S1007 | Sell    |

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
      | TxnStatus | TradeDate | SettleDate | TrdQty | TrdPrice  | ExBroker | ExDeskType |
      | New       | T         | T+1        | 49820  | 285.15608 | CLSA-ES  | PROGRAM    |
      | Amend     | T         | T+1        | 49820  | 285.15608 | CLSA-ES  | PROGRAM    |
      | Cancel    | T         | T+1        | 49820  | 285.15608 | CLSA-ES  | PROGRAM    |
