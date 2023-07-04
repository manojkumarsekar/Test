eis-qa-solvency
project repo with automated tests for solvency application

Libraries used
eis-cart-lite
Before you start
Understand eis-cart-lite
Understand SDET Guide
Understand solvency application
Folders
refer eis-cart-lite
App configurations
Properties File	parameter	dataType	mandatory	default	description
app-config-{env}	solvency.web.UI.url	string	conditional	EMPTY	solvency web application url; mandatory for UI tests
app-config-{env}	solvency.db.type	string	conditional	EMPTY	solvency db type; mandatory for DB tests; allowed values: jdbc_a
app-config-{env}	solvency.db.jdbc.url	string	conditional	EMPTY	solvency db connection url; mandatory for DB tests
app-config-{env}	solvency.db.jdbc.user	string	conditional	EMPTY	solvency db user id; mandatory for DB tests
app-config-{env}	solvency.db.jdbc.encrypted.password	string	conditional	EMPTY	solvency db user password (encrypted) which will be decrypted using master-password from core-config; mandatory for DB tests
app-config-{env}	solvency.db.jdbc.description	string	optional	EMPTY	description about solvency db
Test data
Most of the behavioural test data are parameterized via feature files

Base LBU files
To be updated
Reference report files
To be updated
Tags
refer ReadMe in eis-cart-lite
Other important tags to note:
NA
Run tests
refer ReadMe in eis-cart-lite
Logging and Reports
refer ReadMe in eis-cart-lite