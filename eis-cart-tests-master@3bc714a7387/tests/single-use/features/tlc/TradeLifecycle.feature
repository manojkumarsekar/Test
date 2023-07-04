Feature: Trade Lifecycle

  @tlc9000_new_curr @tlc9000
  Scenario Outline: TC_EQUITY_01: BUY_SG1F60858221_<TxnStatus>

    When I place "<AssetType>" trade with below trade economics
      | Portfolio  | <Portfolio>  |
      | Instrument | <Instrument> |
      | TxnType    | <TxnType>    |
      | TxnStatus  | <TxnStatus>  |
      | TradeDate  | <TradeDate>  |
      | SettleDate | <SettleDate> |
      | TradeQty   | <TrdQty>     |
      | TradePrice | <TrdPrice>   |
      | ExBroker   | <ExBroker>   |
      | ExDeskType | <ExDeskType> |

    Then I expect the transaction xml is generated with expected trade economics

    Examples: Equity Trade Params
      | AssetType | Portfolio | Instrument   | TxnType | TxnStatus | TradeDate | SettleDate | TrdQty | TrdPrice | ExBroker | ExDeskType |
      | Equity    | TSTALCHEF | SG1F60858221 | Buy     | New       | T         | T+3        | 119800 | 3.4806   | CGML-ES  | CASH       |
      | Equity    | TSTALCHEF | SG1F60858221 | Buy     | Amend     | T         | T+3        | 129800 | 3.4806   | CGML-ES  | CASH       |
      | Equity    | TSTALCHEF | SG1F60858221 | Buy     | Cancel    | T         | T+3        | 129800 | 3.4806   | CGML-ES  | CASH       |

    Examples: Fixed Income Trade Params
      | AssetType | Portfolio | Instrument | TxnType | TxnStatus | TradeDate | SettleDate | TrdQty     | TrdPrice | ExBroker | ExDeskType |
      | Bond      | TSTALCHEF | B4QWH17    | Buy     | New       | T         | T+3        | 3000000000 | 96.5     | SCB-ES   | GEN        |
      | Bond      | TSTALCHEF | B4QWH17    | Buy     | Amend     | T         | T+3        | 3000000000 | 96.5     | SCLO-ES  | GEN        |
      | Bond      | TSTALCHEF | B4QWH17    | Buy     | Cancel    | T         | T+3        | 3000000000 | 96.5     | SCLO-ES  | GEN        |

    Examples: Fx Fwrd Trade Params
      | AssetType | Portfolio | Instrument | TxnType | TxnStatus | TradeDate | SettleDate | TrdQty  | TrdPrice | ExBroker | ExDeskType |
      | FXFwd     | TSTALCHEF | EURSGD     | Buy     | New       | T         | T+1        | 1000000 | 1.6161   | SCB-ES   | SCB-SG     |
      | FXFwd     | TSTALCHEF | EURSGD     | Buy     | Amend     | T         | T+1        | 1000000 | 1.62     | SCB-ES   | SCB-SG     |
      | FXFwd     | TSTALCHEF | EURSGD     | Buy     | Cancel    | T         | T+1        | 1000000 | 1.62     | SCB-ES   | SCB-SG     |

    Examples: Fx Spot Trade Params
      | AssetType | Portfolio | Instrument | TxnType | TxnStatus | TradeDate | SettleDate | TrdQty | TrdPrice | ExBroker | ExDeskType |
      | FXSpot    | TSTALCHEF | GBPSGD     | Buy     | New       | T         | T+1        | 370000 | 1.834072 | CITI-ES  | CITI-SG    |
      | FXSpot    | TSTALCHEF | GBPSGD     | Buy     | Amend     | T         | T+1        | 370000 | 1.834072 | ANZG-ES  | ANZG-SG    |
      | FXSpot    | TSTALCHEF | GBPSGD     | Buy     | Cancel    | T         | T+1        | 370000 | 1.834072 | ANZG-ES  | ANZG-SG    |

    Examples: Futures Trade Params
      | AssetType | Portfolio | Instrument | TxnType | TxnStatus | TradeDate | SettleDate | TrdQty | TrdPrice | ExBroker | ExDeskType |
      | Futures   | TSTALCHEF | RTSH92016  | Sell    | New       | T         | T+1        | 200    | 111.945  | NATW-ES  | GEN        |
      | Futures   | TSTALCHEF | RTSH92016  | Sell    | Amend     | T         | T+1        | 200    | 111.945  | JPM-ES   | FUT        |
      | Futures   | TSTALCHEF | RTSH92016  | Sell    | Cancel    | T         | T+1        | 200    | 111.945  | JPM-ES   | FUT        |

    Examples: Equity Options Trade Params
      | AssetType    | Portfolio | Instrument | TxnType | TxnStatus | TradeDate | SettleDate | TrdQty   | TrdPrice | ExBroker | ExDeskType |
      | EquityOption | TSTALCHEF | BPM1EW218  | Sell    | New       | T         | T+2        | 13000000 | 1.88     | OCBC-ES  | ALGO       |
      | EquityOption | TSTALCHEF | BPM1EW218  | Sell    | Amend     | T         | T+4        | 13000000 | 1.88     | OCBC-ES  | ALGO       |
      | EquityOption | TSTALCHEF | BPM1EW218  | Sell    | Cancel    | T         | T+4        | 13000000 | 1.88     | OCBC-ES  | ALGO       |
