# It is used to zip cucumber-html-reports folder from the testout directory
# and upload to Artifactory based on the pipeline in which it is running
# Usage: upload_reports_to_artifactory.sh -
#   Ex: Adhoc pipeline reports are uploaded with name: "${BRANCH_NAME}"_reports_"${BUILD_NUM}".tar.gz
# Usage: upload_reports_to_artifactory.sh "rerun_"
#   Ex: Adhoc pipeline reports are uploaded with name: "${BRANCH_NAME}"_rerun_reports_"${BUILD_NUM}".tar.gz

#!/bin/bash


echo "Copy execution time csv file into cucumber-html-reports"
cp testout/report/execution_time.tsv testout/report/summary/cucumber-html-reports/

echo "Zip cucumber reports..."
cd testout/report/summary && tar -czf reports.tar.gz cucumber-html-reports

echo "Upload to Artifactory"
BRANCH_NAME=$(echo $bamboo_repository_branch_name | cut -d'/' -f2)
BUILD_NUM=`echo ${bamboo_buildNumber}`
RELEASE_FIX_VERSION_ID=`echo ${bamboo_release_FIX_VERSION_ID}`

case $bamboo_planKey in
    *"ADHOCTEST"*)
       REPORTS_ZIP="${BRANCH_NAME}"_"$@"reports_"${BUILD_NUM}".tar.gz
       FOLDER="adhoc";;
    *"RELEASEREGRESSION"*)
        REPORTS_ZIP="${BRANCH_NAME}"_regression_"$@"reports_"${BUILD_NUM}".tar.gz
        FOLDER="${RELEASE_FIX_VERSION_ID}";;
    *"GSREGRESSIONNONUIINTEGRATION"*)
       REPORTS_ZIP=non_ui_regression_integration_tests_"$@"reports_"$(date +'%d%m%Y')".tar.gz
       FOLDER="regression";;
    *"GSREGRESSIONNONUIUNIT"*)
       REPORTS_ZIP=non_ui_regression_unit_tests_"$@"reports_"$(date +'%d%m%Y')".tar.gz
       FOLDER="regression";;
    *"GSREGRESSIONUI"*)
       REPORTS_ZIP=ui_regression_"$@"reports_"$(date +'%d%m%Y')".tar.gz
       FOLDER="regression";;
     *)
       echo "Reports upload to artifactory is not supported for this plan $bamboo_planKey"
   	   exit 1;;
esac

cat <<EOF >> inject_vars.txt
APRO_FOLDER=${FOLDER}
REPORTS_ZIP=${REPORTS_ZIP}
EOF

mv reports.tar.gz $REPORTS_ZIP

curl -s -k -u "$bamboo_common_eis_common_svc_id_rw:$bamboo_common_eis_common_svc_id_rw_password" \
    -X PUT \
    "$bamboo_common_ARTIFACTORY_URL/generic-eis-dmp/automation-reports/${FOLDER}/${REPORTS_ZIP}" \
    -T $REPORTS_ZIP \
    --fail

rm $REPORTS_ZIP