#!/bin/bash

FIX_VERSION=`echo ${bamboo_01_FIX_VERSION_NAME}`

temp=`sed "s/- ${bamboo_shortPlanName}//g" <<< "${bamboo_planName}"`
PLAN_NAME=`sed "s/EIS - DMP - Nonprod - //g" <<< $temp`
BRANCH_NAME=`echo ${bamboo_shortPlanName}`
BUILD_NUM=`echo ${bamboo_buildNumber}`
BUILD_TIMESTAMP=`echo ${bamboo_buildTimeStamp}`

BUILD_URL="https://$bamboo_common_BAMBOO_INTERNET"/browse/${bamboo_planKey}-$BUILD_NUM

USER=`echo ${bamboo_ManualBuildTriggerReason_userName}`

eval "echo \"$(< config/email/smart_regression_initiated_mail.txt)\"" > temp.txt
awk 'sub("$", "\r")' temp.txt > winmail.txt && rm temp.txt