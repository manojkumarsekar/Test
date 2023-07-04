Feature: TC_FXSPOT_020 - Trade Lifecycle

  @tlc9000 @tlc9000_fx @tlc9000_fxspots
  Scenario Outline: TC_FXSPOT_020: BUY_JPYSGD_<TxnStatus>

    Given I place "FXSpot" order for:
      | Portfolio | FundId | Instrument | TxnType |
      | TSTALCHEF | 4033   | JPYSGD     | BUY     |

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
      | TxnStatus | TradeDate | SettleDate | TrdQty    | TrdPrice     | ExBroker | ExDeskType |
      | New       | T         | T+1        | 100000000 | 0.0091444457 | UBS-ES   | UBS-AU     |
      | Amend     | T         | T+1        | 100000100 | 0.0091444457 | UBS-ES   | UBS-AU     |
      | Cancel    | T         | T+1        | 100000100 | 0.0091444457 | UBS-ES   | UBS-AU     |