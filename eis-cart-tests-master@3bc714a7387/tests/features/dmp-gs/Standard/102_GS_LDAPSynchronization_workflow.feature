#Feature History
#TOM-3768: Created New Feature file to sanity test "LDAP Synchronization" workflow

@dmp_smoke @ldap_sync_wf @tom_3768
Feature: GC Smoke | Orchestrator | GS | Standard OOB | LDAP Synchronization

  Scenario: Verify Execution of Workflow

  #Assign Variables
    Given I set the workflow template parameter "DELETENONEXISTENTUSERS" to "true"
    And I set the workflow template parameter "LDAPPASSWORD" to "XcPkJ23h"
    And I set the workflow template parameter "LDAPSERVERURL" to "ldap://DSG001.pru.intranet.asia:389"
    And I set the workflow template parameter "LDAPUSER" to "cn=goldensource_svc,ou=Users,ou=EIS,ou=SG,dc=PRU,dc=intranet,dc=asia"
    And I set the workflow template parameter "ROLEBASEPATH" to "OU=Groups,OU=EIS,OU=SG,DC=PRU,DC=intranet,DC=asia"
    And I set the workflow template parameter "ROLEFILTER" to "(cn=GSGEIS-Goldensource*)"
    And I set the workflow template parameter "ROLEIDENTIFIERATTRIBUTE" to "sAMAccountName"
    And I set the workflow template parameter "ROLEMEMBERATTRIBUTE" to "member"
    And I set the workflow template parameter "USERBASEPATH" to "OU=Users,OU=EIS,OU=SG,DC=PRU,DC=intranet,DC=asia"
    And I set the workflow template parameter "USERFILTER" to "(cn=*)"
    And I set the workflow template parameter "USERIDENTIFIERATTRIBUTE" to "sAMAccountName"
    And I set the workflow template parameter "USERROLESATTRIBUTE" to "memberOf"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/LDAPSynchronization/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/LDAPSynchronization/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
        """
        SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
        """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}' AND TASK_SUCCESS_CNT !=0
      """