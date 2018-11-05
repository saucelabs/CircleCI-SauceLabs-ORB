#!/usr/bin/env bats

# load custom assertions and functions
load bats_helper


# setup is run beofre each test
function setup {
  INPUT_PROJECT_CONFIG=${BATS_TMPDIR}/input_config-${BATS_TEST_NUMBER}
  PROCESSED_PROJECT_CONFIG=${BATS_TMPDIR}/packed_config-${BATS_TEST_NUMBER} 
  JSON_PROJECT_CONFIG=${BATS_TMPDIR}/json_config-${BATS_TEST_NUMBER} 
	echo "#using temp file ${BATS_TMPDIR}/"

  # the name used in example config files.
  INLINE_ORB_NAME="saucelabs"
}


@test "A full job expands properly" {
  # given
  process_config_with test/inputs/simple.yml

  # then
  assert_jq_match '.jobs | length' 1
  assert_jq_match '.jobs["saucelabs/with_proxy"].steps | length' 5
  assert_jq_match '.jobs["saucelabs/with_proxy"].steps[0]' "checkout"
  assert_jq_match '.jobs["saucelabs/with_proxy"].steps[1].run.name' "Install SauceLabs Connect"
  assert_jq_match '.jobs["saucelabs/with_proxy"].steps[2].run.name' "Open Sauce Connect Tunnel"
  assert_jq_match '.jobs["saucelabs/with_proxy"].steps[3].run.command' "mvn verify -B"
  assert_jq_match '.jobs["saucelabs/with_proxy"].steps[4].run.name' "Close Sauce Connect Tunnels"

}

@test "A job using tunnel_identifier included in sc command" {
  # given
  process_config_with test/inputs/simple.yml

  # then
  assert_jq_match '.jobs | length' 1
  assert_jq_match '.jobs["saucelabs/with_proxy"].steps | length' 5
  assert_jq_match '.jobs["saucelabs/with_proxy"].steps[2].run.name' "Open Sauce Connect Tunnel"
  assert_jq_contains '.jobs["saucelabs/with_proxy"].steps[2].run.command' 'sc -u ${SAUCELABS_USER} -k ${SAUCELABS_KEY}  -i chrome  &'

}


@test "A workflow with parallel jobs expands properly" {
  # given
  process_config_with test/inputs/parallel.yml

  # then
  assert_jq_match '.jobs | length' 2
  assert_jq_match '.jobs["Chrome Tests"].steps | length' 5
  assert_jq_match '.jobs["Chrome Tests"].steps[0]' "checkout"
  assert_jq_match '.jobs["Chrome Tests"].steps[1].run.name' "Install SauceLabs Connect"
  assert_jq_match '.jobs["Chrome Tests"].steps[2].run.name' "Open Sauce Connect Tunnel"
  assert_jq_contains '.jobs["Chrome Tests"].steps[2].run.command' 'sc -u ${SAUCELABS_USER} -k ${SAUCELABS_KEY}  -i chrome  &'
  #user step
  assert_jq_match '.jobs["Chrome Tests"].steps[3].run.command' 'mvn verify -B -Dsauce.browser=chrome  -Dsauce.tunnel="chrome"'
  assert_jq_match '.jobs["Chrome Tests"].steps[4].run.name' "Close Sauce Connect Tunnels"

  #and
  assert_jq_match '.jobs["Safari Tests"].steps | length' 5
  assert_jq_match '.jobs["Safari Tests"].steps[0]' "checkout"
  assert_jq_match '.jobs["Safari Tests"].steps[1].run.name' "Install SauceLabs Connect"
  assert_jq_match '.jobs["Safari Tests"].steps[2].run.name' "Open Sauce Connect Tunnel"
  assert_jq_contains '.jobs["Chrome Tests"].steps[2].run.command' 'sc -u ${SAUCELABS_USER} -k ${SAUCELABS_KEY}  -i chrome  &'
  #user step
  assert_jq_match '.jobs["Safari Tests"].steps[3].run.command' 'mvn verify -B -Dsauce.browser=safari  -Dsauce.tunnel="safari"'
  assert_jq_match '.jobs["Safari Tests"].steps[4].run.name' "Close Sauce Connect Tunnels"

}









