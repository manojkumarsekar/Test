Feature: TC_EQOP_06 - Trade Lifecycle

  @tlc9000 @tlc9000_eq_options
  Scenario Outline: TC_EQOP_06: SELL_BPM1EW218_<TxnStatus>

    Given I place "EquityOption" order for:
      | Portfolio | FundId | Instrument | TxnType |
      | TSTALCHEF | 4033   | BPM1EW218  | Sell    |

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
      | TxnStatus | TradeDate | SettleDate | TrdQty   | TrdPrice | ExBroker | ExDeskType |
      | New       | T         | T+2        | 12000000 | 2.86   | OCBC-ES  | ALGO       |
      | Amend     | T         | T+2        | 12000000 | 2.86   | OCBC-ES  | OCBC-MY    |
 
