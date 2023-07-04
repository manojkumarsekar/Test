Feature: TC_FUT_022 - Trade Lifecycle

  @tlc9000 @tlc9000_futures
  Scenario Outline: TC_FUT_022: SELL_TWH920190_<TxnStatus>

    Given I place "Futures" order for:
      | Portfolio | FundId | Instrument | TxnType |
      | TSTALCHEF | 4033   | TWH920190  | SELL    |

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
      | TxnStatus | TradeDate | SettleDate | TrdQty | TrdPrice | ExBroker | ExDeskType | CptyCode   |
      | New       | T         | T+1        | 100    | 402.4    | GOLD-ES  | FUT        | CITIFUT-ES |
      | Cancel    | T         | T+1        | 100    | 402.4    | GOLD-ES  | FUT        | CITIFUT-ES |
 
