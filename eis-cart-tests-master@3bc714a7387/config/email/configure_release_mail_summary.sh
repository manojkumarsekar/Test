#!/bin/bash

FIX_VERSION=`echo ${bamboo_01_FIX_VERSION_NAME}`
ARTIFACTS_URL=`echo ${bamboo_buildResultsUrl}`

temp=`sed "s/- ${bamboo_shortPlanName}//g" <<< "${bamboo_planName}"`
PLAN_NAME=`sed "s/EIS - DMP - Nonprod - //g" <<< $temp`
BRANCH_NAME=`echo ${bamboo_shortPlanName}`
BUILD_NUM=`echo ${bamboo_buildNumber}`
BUILD_TIMESTAMP=`echo ${bamboo_buildTimeStamp}`
VM_NAME=`echo ${bamboo_gs_vm_name}`

#bamboo_reports_APRO_FOLDER and bamboo_reports_REPORTS_ZIP are injected by Inject vars which are initialized in upload_reports_to_artifactory.sh
APRO_REPORTS_PATH="https://$bamboo_common_ARTIFACTORY_INTERNET/artifactory/list/generic-eis-dmp/automation-reports/$bamboo_reports_APRO_FOLDER/$bamboo_reports_REPORTS_ZIP"

BUILD_URL="https://$bamboo_common_BAMBOO_INTERNET"/browse/${bamboo_planKey}-$BUILD_NUM

USER=`echo ${bamboo_ManualBuildTriggerReason_userName}`

if [ -z $USER ]
then
    USER="Bamboo"
fi

#TAGS must be injected in release name space with result scope
TAGS=`echo ${bamboo_release_TAGS}`

#extract footer.html
cat testout/report/summary/cucumber-html-reports/overview-features.html | sed -n -e '/tfoot class="total"/,/tfoot/p' > footer.html
FAILED_SCENARIOS_COUNT=`xmllint --xpath '//tfoot/tr[1]/td[9]/text()' footer.html --html`

if [ -z $FAILED_SCENARIOS_COUNT ]
then
    RECON_STATUS="ABORTED/STOPPED"
    COLOR_CODE='"red"'
elif [ $FAILED_SCENARIOS_COUNT -eq 0 ]
then
    RECON_STATUS="PASSED"
    COLOR_CODE='"green"'
else
    RECON_STATUS=$(grep 'CartException' testout/report/summary/cucumber-html-reports/overview-failures.html | grep '<pre>' | cut -d":" -f2)
    RELEASE_FAILURES_URL="Check [Release Specific Failures] in $ARTIFACTS_URL/artifact"
    COLOR_CODE='"red"'
fi

eval "echo \"$(< config/email/release_mail.txt)\"" > temp.txt
awk 'sub("$", "\r")' temp.txt > winmail.txt && rm temp.txt