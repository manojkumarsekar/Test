Feature: TC_FUT_05 - Trade Lifecycle

  @tlc9000  @tlc9000_futures
  Scenario Outline: TC_FUT_05: BUY_IBU020200_<TxnStatus>

    Given I place "Futures" order for:
      | Portfolio | FundId | Instrument | TxnType |
      | TSTALCHEF | 4033   | IBU020200  | Buy     |

    And I generate trade nuggets for below trade params:
      | TxnStatus  | <TxnStatus>  |
      | TradeDate  | <TradeDate>  |
      | SettleDate | <SettleDate> |
      | TradeQty   | <TrdQty>     |
      | TradePrice | <TrdPrice>   |
      | ExBroker   | <ExBroker>   |
      | ExDeskType | <ExDeskType> |
      | CptyCode   | <CptyCode>   |

    When I initiate trade life cycle workflow

    Then I expect trade nuggets are successfully archived
    And I expect trade nuggets entry is made in DMP

    Then I expect trade ack status file is successfully archived
    And I expect trade ack status entry is made in DMP

    Examples: Trade Params
      | TxnStatus | TradeDate | SettleDate | TrdQty | TrdPrice | ExBroker | ExDeskType | CptyCode  |
      | New       | T         | T+1        | 100    | 8974     | MACQ-ES  | FUT        | NATFUT-ES |
      | Amend     | T         | T+1        | 100    | 8975     | MACQ-ES  | FUT        | NATFUT-ES |

