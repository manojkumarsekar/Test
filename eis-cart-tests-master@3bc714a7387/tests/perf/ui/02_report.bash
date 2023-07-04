#!/bin/bash -ex
# Define the OUTPUT_DIR environment variable, e.g.
#   OUTPUT_DIR=/home/tester/cart-tests/tests/perf/out
# Clean the %OUTPUT_DIR% first, e.g.
#   rm -rf %OUTPUT_DIR%
$JMETER_HOME/bin/jmeter -g ui-login-result.jtl -o $OUTPUT_DIR
