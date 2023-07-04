#!/bin/bash -e

env_config_file="$1"
tags="$2"
ignore_tags="${3:-"~@ignore"}"
logging_level="$4"
registry_username="${5:-$bamboo_common_eis_common_svc_id_rw}"
registry_password="${6:-$bamboo_common_eis_common_svc_id_rw_password}"
http_proxy=${bamboo_common_HTTP_PROXY_PROTOCOL}://${bamboo_common_eis_common_proxy_username}:${bamboo_common_eis_common_proxy_password}@${bamboo_common_HTTP_PROXY_DOMAIN}

echo "--> Ignoring $ignore_tags tags"

if [[ "$logging_level" != "DEBUG" && "$logging_level" != "INFO" && "$logging_level" != "WARN" ]]; then
    logging_level="INFO"
fi

echo "--> Logging level set as: " ${logging_level}

base_dir="$(pwd)"
target_env=$(expr "$env_config_file" : "env_\(.*\).properties")

# Confirm config file
# generic-eis-common-stage to be changed to generic-eis-dmp-local

if [ ! -f "config/${env_config_file}" ]
then
  curl -k \
    -u ${bamboo_common_ARTIFACTORY_ID}:${bamboo_common_ARTIFACTORY_ID_PASSWORD_TOKEN} \
    -O \
    "${bamboo_common_ARTIFACTORY_URL}/generic-eis-dmp/cart-test/config/${env_config_file}" \
    --fail
  mv "$env_config_file" config/
fi

# Setup test output directory and permissions
mkdir -p testout/report/summary reports target
chmod -R ugo+rwx testout
chmod -R ugo+rwx tests

docker login -u "$registry_username" -p "$registry_password" "$bamboo_common_DOCKER_REGISTRY"

echo "--> Run the test tags $tags"

#docker image to be latest, just to test the image we are testing with :candidate
docker run \
  --rm \
  --shm-size=512m \
  -v /etc/localtime:/etc/localtime:ro \
  -v "${base_dir}/tests:/opt/tomcart/ws/cart-tests/tests" \
  -v "${base_dir}/testout:/opt/tomcart/ws/cart-tests/testout" \
  -v "${base_dir}/config:/opt/tomcart/ws/cart-tests/config" \
  -e "TZ=Asia/Singapore" \
  -e "SELENIUM_PROXY=${http_proxy}" \
  -e "TOMCART_ENV_NAME=${target_env}" \
  -e "TOMCART_QTEST=false" \
  -e "TOMCART_LOGGING_LEVEL=${logging_level}" \
  -e "ARTIFACTORY_URL"="${bamboo_common_ARTIFACTORY_URL}" \
  -e "ARTIFACTORY_USERNAME"="${bamboo_common_ARTIFACTORY_ID}" \
  -e "ARTIFACTORY_PASSWORD"="${bamboo_common_ARTIFACTORY_ID_PASSWORD_TOKEN}" \
  "${bamboo_common_DOCKER_REGISTRY}/cart:latest" \
  /opt/tomcart/bin/runtests.bash "$tags" --tags "$ignore_tags"

docker logout
