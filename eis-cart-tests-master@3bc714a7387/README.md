## Cart tests

Guidelines and points to writing cart tests.

### Tags

*****************************************************
Running tests with single tag:
*****************************************************

WINDOWS:

$C:\tomrt-win\bin\runbytag @tag1

UNIX:

$/opt/tomcart/bin/runtests.bash @tag1

*****************************************************
Running tests with multiple tags:
*****************************************************

WINDOWS:

$C:\tomrt-win\bin\runbytag "@tag1,@tag2....@tagN"

UNIX:

$/opt/tomcart/bin/runtests.bash "@tag1,@tag2....@tagN"


*****************************************************
Running tests with multiple tags by ignoring single tag
*****************************************************

want to run tag1 and tag2 but ignore tag3

WINDOWS:

$C:\tomrt-win\bin\runbytag "@tag1,@tag2" --tags "~@tag3"

UNIX:

$/opt/tomcart/bin/runtests.bash "@tag1,@tag2" --tags "~@tag3"


want to run tag1 and tag2 but ignore tag3 and tag4

WINDOWS:

$C:\tomrt-win\bin\runbytag "@tag1,@tag2" --tags "~@tag3,~@tag4"

UNIX:

$/opt/tomcart/bin/runtests.bash "@tag1,@tag2" --tags "~@tag3,~@tag4"


### Environment properties files
Naming convention:
```
config/env_<ENVIRONMENT_NAME>.properties
```
