Feature: TC_FXSPOT_018 - Trade Lifecycle

  @tlc9000 @tlc9000_fx @tlc9000_fxspots
  Scenario Outline: TC_FXSPOT_018: SELL_USDJPY_<TxnStatus>

    Given I place "FXSpot" order for:
      | Portfolio | FundId | Instrument | TxnType |
      | TSTALCHEF | 4033   | USDJPY     | SELL    |

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
      | TxnStatus | TradeDate | SettleDate | TrdQty     | TrdPrice         | ExBroker | ExDeskType |
      | New       | T         | T+1        | 2120526.42 | 109.317194925588 | CONV     | GEN        |
      | Amend     | T         | T+1        | 2120526    | 109.317194925588 | CONV     | GEN        |
      | Cancel    | T         | T+1        | 2120526    | 109.317194925588 | CONV     | GEN        |