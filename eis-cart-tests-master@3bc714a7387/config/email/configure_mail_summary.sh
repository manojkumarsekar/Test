#!/bin/bash

temp=`sed "s/- ${bamboo_shortPlanName}//g" <<< "${bamboo_planName}"`
PLAN_NAME=`sed "s/EIS - DMP - Nonprod - //g" <<< $temp`
BRANCH_NAME=`echo ${bamboo_shortPlanName}`
BUILD_NUM=`echo ${bamboo_buildNumber}`
BUILD_TIMESTAMP=`echo ${bamboo_buildTimeStamp}`
VM_NAME=`echo ${bamboo_gs_vm_name}`
BUILD_URL="https://$bamboo_common_BAMBOO_INTERNET"/browse/${bamboo_planKey}-$BUILD_NUM
APRO_REPORTS_PATH="https://$bamboo_common_ARTIFACTORY_INTERNET/artifactory/list/generic-eis-dmp/automation-reports/$bamboo_reports_APRO_FOLDER/$bamboo_reports_REPORTS_ZIP"

#If Default TAGS variable is empty, then fetch from release namespace TAGS to support release regression pipelines
TAGS=`echo ${bamboo_TAGS}`
if [ -z $TAGS ]
then
    TAGS=`echo ${bamboo_release_TAGS}`
fi

#To add as an Artifact in Bamboo
echo ${APRO_REPORTS_PATH} > testout/report/summary/reports_path.txt

USER=`echo ${bamboo_ManualBuildTriggerReason_userName}`

if [ -z $USER ]
then
    USER="Bamboo"
fi

#extract body.html
cat testout/report/summary/cucumber-html-reports/overview-features.html | sed -n -e '/tbody/,/tbody/p' > body.html
PASSED_FEATURES_COUNT=`grep -c '<td class="passed">Passed</td>' body.html`
FAILED_FEATURES_COUNT=`grep -c '<td class="failed">Failed</td>' body.html`
TOTAL_FEATURES_COUNT=`expr $PASSED_FEATURES_COUNT + $FAILED_FEATURES_COUNT`

#extract footer.html
cat testout/report/summary/cucumber-html-reports/overview-features.html | sed -n -e '/tfoot class="total"/,/tfoot/p' > footer.html

TOTAL_SCENARIOS_COUNT=`xmllint --xpath '//tfoot/tr[1]/td[10]/text()' footer.html --html`
FAILED_SCENARIOS_COUNT=`xmllint --xpath '//tfoot/tr[1]/td[9]/text()' footer.html --html`

PASSED_SCENARIOS_COUNT=`expr $TOTAL_SCENARIOS_COUNT - $FAILED_SCENARIOS_COUNT`

EXECUTION_TIME=`xmllint --xpath '//tfoot/tr[1]/td[11]/text()' footer.html --html`

trimDuration=${EXECUTION_TIME%%.*}
array=(${trimDuration//:/ })

if [ ${#array[@]} -eq 3 ]; then
    DURATION="${array[0]} hrs ${array[1]} mins ${array[2]} sec"
elif [ ${#array[@]} -eq 2 ]; then
    DURATION="${array[0]} mins ${array[1]} sec"
elif [ ${#array[@]} -eq 1 ]; then
    DURATION="${array[0]} secs"
fi

if [ -z $FAILED_SCENARIOS_COUNT ]
then
    RUN_STATUS="ABORTED/STOPPED"
    COLOR_CODE='"red"'
    REPORT_URL=""
elif [ $FAILED_SCENARIOS_COUNT -eq 0 ]
then
    RUN_STATUS="PASSED"
    COLOR_CODE='"green"'
elif [ $FAILED_SCENARIOS_COUNT -ge 1 ]
then
    RUN_STATUS="$FAILED_FEATURES_COUNT FEATURE/S ($FAILED_SCENARIOS_COUNT SCENARIOS) FAILED !!! PLEASE CHECK HTML REPORT FOR DETAILS."
    COLOR_CODE='"red"'
fi

#RERUN value will be explicitly set in the pipeline
RERUN=`echo $RERUN`

eval "echo \"$(< config/email/mail.txt)\"" > temp.txt
awk 'sub("$", "\r")' temp.txt > winmail.txt && rm temp.txt