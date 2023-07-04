@echo off
rem Define the OUTPUT_DIR environment variable, e.g.
rem   set OUTPUT_DIR=c:/tomwork/cart-tests/tests/perf/out
rem Clean the %OUTPUT_DIR% first, e.g.
rem   rm -rf %OUTPUT_DIR%
%JMETER_HOME%\bin\jmeter -g wf-soap-result.jtl -o %OUTPUT_DIR%
