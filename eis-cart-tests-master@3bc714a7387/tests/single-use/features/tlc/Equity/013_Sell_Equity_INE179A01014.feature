Feature: TC_EQUITY_013 - Trade Lifecycle


  @tlc9000 @tlc9000_equities
  Scenario Outline: TC_EQUITY_013: SELL_INE179A01014_<TxnStatus>

    Given I place "Equity" order for:
      | Portfolio | FundId | Instrument   | TxnType |
      | TSTALCHEF | 4033   | INE179A01014 | Sell    |

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
      | TxnStatus | TradeDate | SettleDate | TrdQty | TrdPrice       | ExBroker | ExDeskType |
      | New       | T         | T+1        | 1436   | 9535.726288301 | IDFC-ES  | CASH       |
      | Amend     | T         | T+1        | 1436   | 9535.726288301 | IDFC-ES  | CASH       |
      | Cancel    | T         | T+1        | 1436   | 9535.726288301 | IDFC-ES  | CASH       |
