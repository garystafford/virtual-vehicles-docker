#!/bin/sh

########################################################################
#
# title:          Pull Latest Build Artifacts Script
# author:         Gary A. Stafford (https://programmaticponderings.com)
# url:            https://github.com/garystafford/virtual-vehicles-docker
# description:    Pull latest build artifacts from virtual-vehicles-demo repo
#                 and build Dockerfile and YAML templates
#
# to run:         sh pull_build_artifacts.sh
#
########################################################################

echo "Removing all existing build artifacts"
rm -rf build-artifacts

rm -rf authentication/build-artifacts/
rm -rf maintenance/build-artifacts/
rm -rf valet/build-artifacts/
rm -rf vehicle/build-artifacts/

echo "Pulling latest build artficats"
git clone https://github.com/garystafford/virtual-vehicles-demo.git \
  --branch build-artifacts \
  --single-branch build-artifacts

echo "Moving build artifacts to each microservice directory"
mv build-artifacts/authentication/  authentication/build-artifacts/
mv build-artifacts/maintenance/     maintenance/build-artifacts/
mv build-artifacts/valet/           valet/build-artifacts/
mv build-artifacts/vehicle/         vehicle/build-artifacts/

echo "Removing local clone of build artifacts repo"
rm -rf build-artifacts

echo "Pulling build artifacts complete"

echo "Executing Dockerfile template builders"
pushd authentication && sh build_dockerfile.sh && popd
pushd maintenance    && sh build_dockerfile.sh && popd
pushd valet          && sh build_dockerfile.sh && popd
pushd vehicle        && sh build_dockerfile.sh && popd

echo "Executing docker-compose.yml template builder"
sh build_compose.sh

echo deleting previous images and all containers
docker rm -f $(docker ps -a -q)
docker rmi -f test_vehicle \
  test_authentication \
  test_maintenance \
  test_valet

#echo "run docker-compose.yml"
#docker-compose -p vehicle up -d

echo "Template building process complete"
