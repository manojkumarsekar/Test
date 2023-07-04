Feature: Control-M passthru workflow for Korea HSBC files

Scenario Outline: Test Korea HSBC files

    Given I have a file "<file-name>" in folder "${dmp.dir.dmp.in.korea}"
    When I trigger the Control-M job "<task-name>"
    Then I expect below files to be archived to the host "${dmp.ssh.inbound}" into folder "${dmp.dir.brs.korea.inprogress}" after processing:
        | <file-name> |
    Then I expect below files to be archived to the host "${dmp.ssh.inbound}" into folder "${dmp.dir.brs.korea.completed}" after processing:
        | <file-name> |

    And I expect DMP job log has '<file-name>'
    
    Examples:
        |                 task-name               |                   file-name                  |
        |UEISATOM_DEV_DMP_LOAD_HSBC_TO_DMP_BM_PNFX|esi_Korea_benchmark_positionnonfx_20180718.csv|
        |UEISATOM_DEV_DMP_LOAD_HSBC_TO_DMP_NAV    |esi_Korea_netassetvalue_20180718.csv          |
        |UEISATOM_DEV_DMP_LOAD_HSBC_TO_DMP_PFX    |esi_Korea_positionfx_20180718.csv             |
        |UEISATOM_DEV_DMP_LOAD_HSBC_TO_DMP_PNFX   |esi_Korea_positionnonfx_20180718.csv          |
        |UEISATOM_DEV_DMP_LOAD_HSBC_TO_DMP_PRICE  |esi_Korea_price_20180718.csv                  |
        |UEISATOM_DEV_DMP_LOAD_HSBC_TO_DMP_PTF    |esi_Korea_portfolio_20180718.csv              |
        |UEISATOM_DEV_DMP_LOAD_HSBC_TO_DMP_SEC    |esi_Korea_security_20180718.csv               |