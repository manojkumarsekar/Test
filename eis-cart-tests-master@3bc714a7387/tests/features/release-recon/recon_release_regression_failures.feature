@ignore_hooks @release_recon
Feature: This feature is to reconcile release failures with latest master regression

  As a DMP user,
  I expect there should not be any new failures in release regression
  and even if failures exists they should reconcile with master failures.

  This feature expected to run only in Bamboo during Recon stage.
  consolidated_master_failures.txt and failures.txt expected to create during Bamboo execution.

  Scenario: Reconcile release failures with master regression

    * I assign "tests/test-data/release-recon" to variable "PATH"

    * Check "${PATH}/consolidated_master_failures.txt" file exists
    * Check "${PATH}/failures.txt" file exists

    * I expect there are no new failures in release regression compared to latest master regression
      | release | ${PATH}/failures.txt                     |
      | master  | ${PATH}/consolidated_master_failures.txt |