#EISDEV-7188: Created New Feature file to test "Request Reply for Bloomberg Per Security for MultiListed Securities"

@gc_interface_positions @gc_interface_request_reply
@dmp_regression_integrationtest
@eisdev_7188
Feature: Request Reply | Bloomberg | MultiListing

  Scenario: Fetch MultiListed Security

    Given I assign "tests/test-data/dmp-interfaces/RequestReply/Bloomberg/General" to variable "testdata.path"

    Given I execute below query and extract values of "INSTR_ID" into same variables
     """
      select INSTR_ID from (
      select count(*), isid.instr_id from ft_t_mixr mixr, ft_t_isid isid, ft_t_isgp isgp
      where mixr.isid_oid = isid.isid_oid
      and isid.end_tms is null
      and mixr.end_Tms is null
      and isgp.instr_id = isid.instr_id
      and isgp.end_tms is null
      and isgp.PRNT_ISS_GRP_OID = '=00000FEEF'
      and isid.id_ctxt_typ = 'BBGLOBAL' group by isid.instr_id having count(*) = 2) where rownum =1
     """

    And I execute below query and extract values of "BBGLOBAL1;BBGLOBAL2" into same variables
    """
      select bbg1.iss_id BBGLOBAL1, bbg2.iss_id BBGLOBAL2 from ft_T_isid bbg1, ft_t_isid bbg2
      where bbg1.instr_id = bbg2.instr_id
      and bbg1.id_ctxt_typ = 'BBGLOBAL'
      and bbg2.id_ctxt_typ = 'BBGLOBAL'
      and bbg1.end_tms is null
      and bbg2.end_tms is null
      and bbg1.iss_id != bbg2.iss_id
      and bbg1.instr_id = '${INSTR_ID}'
      and rownum=1
    """

  Scenario: Set up Positions for Test Securities

    Given I execute below query to "Create BALH for Test Security with AS_OF_TMS = SYSDATE+1"
    """
    ${testdata.path}/sql/balh_plus1.sql;
    """

  Scenario: Verify Execution of Workflow with all parameters for Request Type EIS_Price

    Given I assign "/dmp/in/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "/dmp/out/bloomberg" to variable "BB_UPLOAD_DIR"
    And I assign "gs_price_response_template.out" to variable "RESPONSE_TEMPLATENAME"

      #This is to generate the response filename which is driven by database sequence
    And I execute below query and extract values of "SEQ" into same variables
    """
    SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS SEQ FROM DUAL
    """
      #This is to generate the response filename taking sequence value from previous step.

    And I execute below query and extract values of "RESPONSE_FILE_NAME" into same variables
    """
    SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ}' || '.out' AS RESPONSE_FILE_NAME
    FROM FT_CFG_VRTY
    WHERE VND_RQST_TYP = 'EIS_Price'
    """

      # We are copying the response file on server because request reply workflow will generate request file and expect response file with same sequence number.
      # Since, we are not connecting to Bloomberg for testing this is to simulate the process of request reply
    When I copy files below from local folder "${testdata.path}/template" to the host "dmp.ssh.inbound" folder "${BB_DOWNLOAD_DIR}":
      | ${RESPONSE_TEMPLATENAME} |

    And I rename file "${BB_DOWNLOAD_DIR}/${RESPONSE_TEMPLATENAME}" as "${BB_DOWNLOAD_DIR}/${RESPONSE_FILE_NAME}" in the named host "dmp.ssh.inbound"

    And I process BBPerSecurity workflow with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR | ${BB_DOWNLOAD_DIR} |
      | BB_UPLOAD_DIR   | ${BB_UPLOAD_DIR}   |
      | FIRM_NAME       | dl790188           |
      | REQUEST_TYPE    | EIS_Price          |
      | SN              | 191305             |
      | USER_NUMBER     | 3650834            |
      | WORK_STATION    | 0                  |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BB_UPLOAD_DIR}" after processing:
      | gs_price${SEQ}.req |

    Then I expect workflow is processed in DMP with success record count as "1"

    Then I expect value of column "REQ_COUNT" in the below SQL query equals to "2":
     """
     select count(*) as REQ_COUNT from ft_t_vreq where VND_RESP_FILE_NME like 'gs_price${SEQ}.out' and VND_RQST_XREF_ID in ('${BBGLOBAL1}','${BBGLOBAL2}')
     """