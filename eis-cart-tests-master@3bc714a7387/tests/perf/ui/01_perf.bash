#!/bin/bash -ex

$JMETER_HOME/bin/jmeter.sh -n -t ./ui-login.jmx -l ui-login-result.jtl -q ../../../config/jmeter-env-DEV.properties
