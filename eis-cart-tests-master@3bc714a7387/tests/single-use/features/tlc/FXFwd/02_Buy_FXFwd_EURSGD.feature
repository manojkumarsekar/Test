Feature: TC_FXFWD_02 - Trade Lifecycle

  @tlc9000 @tlc9000_fx @tlc9000_fxfwds
  Scenario Outline: TC_FXFWD_02: BUY_EURSGD_<TxnStatus>

    Given I place "FXFwd" order for:
      | Portfolio | FundId | Instrument | TxnType |
      | TSTALCHEF | 4033   | EURSGD     | BUY     |

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
      | TxnStatus | TradeDate | SettleDate | TrdQty  | TrdPrice | ExBroker | ExDeskType |
      | New       | T         | T+1        | 1000000 | 1.6161   | SCB-ES   | SCB-SG     |
      | Amend     | T         | T+1        | 1000000 | 1.62     | SCB-ES   | SCB-SG     |
      | Cancel    | T         | T+1        | 1000000 | 1.62     | SCB-ES   | SCB-SG     |
