Feature: TC_FUT_010 - Trade Lifecycle

  @tlc9000 @tlc9000_futures
  Scenario Outline: TC_FUT_010: BUY_FVU100001_<TxnStatus>

    Given I place "Futures" order for:
      | Portfolio | FundId | Instrument | TxnType |
      | TSTALCHEF | 4033   | FVU100001  | Buy     |

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
      | New       | T         | T+1        | 100    | 100.86   | GOLD-ES  | FUT        | CITIFUT-ES |
      | Cancel    | T         | T+1        | 100    | 100.86   | GOLD-ES  | FUT        | CITIFUT-ES |
 
