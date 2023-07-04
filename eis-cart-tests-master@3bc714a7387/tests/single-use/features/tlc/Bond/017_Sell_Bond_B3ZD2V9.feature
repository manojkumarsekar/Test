Feature: TC_BOND_017 - Trade Lifecycle

  @tlc9000 @tlc9000_bonds
  Scenario Outline: TC_BOND_017: SELL_B3ZD2V9_<TxnStatus>

    Given I place "Bond" order for:
      | Portfolio | FundId | Instrument | TxnType |
      | TSTALCHEF | 4033   | B3ZD2V9    | SELL    |

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
      | TxnStatus | TradeDate | SettleDate | TrdQty    | TrdPrice | ExBroker | ExDeskType |
      | New       | T         | T+2        | 100000000 | 98.075   | CITI-ES  | GEN        |