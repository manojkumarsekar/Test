#!/bin/bash -e

function getLatestSuccessfulBuildNumber(){
 local projectKey="$1"
 local projectPlan="$2"
 local bambooApiUrl="$3"
 local user="$4"
 local password="$5"

 local endPoint="$bambooApiUrl/result/$projectKey-$projectPlan-latest.json"

 local response=$(curl -s -k -w "status_code:[%{http_code}]" -u "${user}:${password}" -X GET $endPoint)

 local responseBody=$(echo $response | awk -F'status_code:' '{print $1}')
 local responseStatus=$(echo $response | awk -F'status_code:' '{print $2}' | awk -F'[][]' '{print $2}')

 if [[ $responseStatus -ne 200 ]]; then
   echo "[ERROR] $BASH_SOURCE (line:$LINENO): Return code not 200: $responseStatus"
   echo "$response"
   exit 1
 fi

 latest_valid_build=$(echo $responseBody | jq -r '.buildNumber')
 buildSummary=$(echo $responseBody | jq -r '.buildTestSummary')

 counter=1
 MAX_RETRIES=5

 while [ "$buildSummary" == "No tests found" -o  "$buildSummary" == 'null' ] && [ $counter -le $MAX_RETRIES ]
 do
    latest_valid_build=$(($latest_valid_build-1))
    endPoint="$bambooApiUrl/result/$PROJECT_KEY-$projectPlan-$latest_valid_build.json"
    buildSummary=$(curl -s -k -u "${user}:${password}" -X GET $endPoint | jq -r '.buildTestSummary')
    counter=$(($counter+1))
 done

 if [[ "$buildSummary" == "No tests found" ]]; then
   echo "[ERROR] $BASH_SOURCE (line:$LINENO): Unable to find successful build after $MAX_RETRIES attempts from the latest build"
   exit 2
 fi
 echo $latest_valid_build
}

user="${1:-${bamboo_common_eis_common_proxy_username}}"
password="${2:-${bamboo_common_eis_common_proxy_password}}"

PROJECT_KEY="EISDMP"

UI_REGRESSION_KEY="GSREGRESSIONUI"
UNIT_REGRESSION_KEY="GSREGRESSIONNONUIUNIT"
INTEGRATION_REGRESSION_KEY="GSREGRESSIONNONUIINTEGRATION"

UI_REGRESION_VALUE="ui_regression"
UNIT_REGRESSION_VALUE="unit_regression"
INTEGRATION_REGRESSION_VALUE="integration_regression"

RERUN_STAGE="RERUN"
RUNTEST_STAGE="RUNTEST"

CONSOLIDATED_FILE="consolidated_master_failures.txt"
LATEST_BUILDS_INFO="latest_builds_info.txt"

declare -A plans=( [${UI_REGRESSION_KEY}]=${UI_REGRESION_VALUE} [${UNIT_REGRESSION_KEY}]=${UNIT_REGRESSION_VALUE} [${INTEGRATION_REGRESSION_KEY}]=${INTEGRATION_REGRESSION_VALUE})

bambooIntranetUrl="https://${bamboo_common_BAMBOO_INTRANET}"
bambooApiUrl="$bambooIntranetUrl/rest/api/latest"

#remove if exists
rm -f $CONSOLIDATED_FILE 2> /dev/null
rm -f $LATEST_BUILDS_INFO 2> /dev/null

for plan in "${!plans[@]}";
do
    set -x
    echo "[INFO] $BASH_SOURCE (line:$LINENO): Reading $PROJECT_KEY-$plan artifacts"

    latest_valid_build=$(getLatestSuccessfulBuildNumber $PROJECT_KEY $plan $bambooApiUrl $user $password)

    echo "Latest Valid Build for $plan is $latest_valid_build" >> $LATEST_BUILDS_INFO

    echo "[INFO] $BASH_SOURCE (line:$LINENO): Latest Valid Build $latest_valid_build"

    artifactsLink=$(curl -s -k -u "${user}:${password}" -X GET "$bambooApiUrl/result/$PROJECT_KEY-$plan-$RERUN_STAGE-$latest_valid_build.json?expand=artifacts" | jq -r '.artifacts.artifact[].link.href' | grep 'failures.txt')

    if [[ $? -ne 0 ]]; then
        echo "[DEBUG] $BASH_SOURCE (line:$LINENO): Unable to fetch failures.txt for $RERUN_STAGE stage with Build number $latest_valid_build"
        echo "[DEBUG] $BASH_SOURCE (line:$LINENO): Trying to fetch failures.txt from $RUNTEST_STAGE stage..."

        artifactsLink=$(curl -s -k -u "${user}:${password}" -X GET "$bambooApiUrl/result/$PROJECT_KEY-$plan-$RUNTEST_STAGE-$latest_valid_build.json?expand=artifacts" | jq -r '.artifacts.artifact[].link.href' | grep 'failures.txt')
        if [[ $? -ne 0 ]]; then
           echo "[ERROR] $BASH_SOURCE (line:$LINENO): Unable to fetch failures.txt with Build number $latest_valid_build from both $RERUN_STAGE stage and $RUNTEST_STAGE stage"
           exit 3
        fi
    fi

    failuresFileUrl=$(echo $artifactsLink  | sed -e "s/${bamboo_common_BAMBOO_INTERNET}/${bamboo_common_BAMBOO_INTRANET}/g")
    echo "[INFO] $BASH_SOURCE (line:$LINENO): Artifacts url $failuresFileUrl"

    curl -s -k -u "${user}:${password}" -L $failuresFileUrl -o ${plans[$plan]}.txt

    set +e
    cat ${plans[$plan]}.txt >> $CONSOLIDATED_FILE
    echo >> $CONSOLIDATED_FILE
done

## Truncate Empty Lines from a Consolidated file
awk 'NF' $CONSOLIDATED_FILE > temp.txt && mv temp.txt $CONSOLIDATED_FILE