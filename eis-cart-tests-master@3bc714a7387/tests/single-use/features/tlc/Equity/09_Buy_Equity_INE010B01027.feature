Feature: TC_EQUITY_09 - Trade Lifecycle
# NO amendement or cancel

  @tlc9000 @tlc9000_equities
  Scenario Outline: TC_EQUITY_09: BUY_INE010B01027_<TxnStatus>

    Given I place "Equity" order for:
      | Portfolio | FundId | Instrument   | TxnType |
      | TSTALCHEF | 4033   | INE010B01027 | Buy     |

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
      | TxnStatus | TradeDate | SettleDate | TrdQty | TrdPrice     | ExBroker | ExDeskType |
      | New       | T         | T+3        | 83006  | 412.00148664 | CSR-ES   | CASH       |
