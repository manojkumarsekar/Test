Feature: Environment Smoke Test

	Environment smoke test provides assurance that we are running tests in 
	a sufficiently verified environment.
	
	The test will provide fail fast feedback whether it makes senses at all to 
	start performing any tests on the specified environment.

	@dmp_env_smoke @EISST-766
    Scenario: Check availability of network components

	Then I expect to be able to reach TCP service listening to port "${dmp.ssh.inbound.port}" on host "${dmp.ssh.inbound.host}"
	Then I expect to be able to reach TCP service listening to port "${dmp.ssh.outbound.port}" on host "${dmp.ssh.outbound.host}"
	Then I expect to be able to reach TCP service listening to port "${dmp.ssh.archive.port}" on host "${dmp.ssh.archive.host}"

	Then I expect to be able to login to named host "dmp.ssh.inbound"
	Then I expect to be able to login to named host "dmp.ssh.outbound"
	Then I expect to be able to login to named host "dmp.ssh.archive"

	Then I expect to be able to connect to Oracle database with named connection "dmp.db.GC"

