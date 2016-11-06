#!/bin/sh

########################################################################
#
# title:          Virtual-Vehicles Project Integration Tests
# author:         Gary A. Stafford (https://programmaticponderings.com)
# url:            https://github.com/garystafford/virtual-vehicles-docker
# description:    Performs integration tests on the Virtual-Vehicles
#                 microservices
# to run:         sh tests_color.sh
# docker-machine: sh tests_color.sh $(docker-machine ip test)
#
########################################################################

echo --- Integration Tests ---
echo

########## VARIABLES ##########
# colorize output
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # no color

hostname=${1-'localhost'} # use input param or default to localhost
application="Test API Client $(date +%s)" # randomized
secret="$(date +%s | shasum | base64 | head -c 15)" # randomized
make="Test"
model="Foo"

echo "${CYAN}hostname: ${hostname}${NC}"
echo "${CYAN}nginx_port: ${nginx_port}${NC}"
echo "${CYAN}application: ${application}${NC}"
echo "${CYAN}secret: ${secret}${NC}"
echo "${CYAN}make: ${make}${NC}"
echo "${CYAN}model: ${model}${NC}"
echo


########## AUTHENTICATION MICROSERVICE ##########
echo "TEST: GET request should return 'true' in the response body"
url="http://${hostname}/vehicles/utils/ping.json"
echo ${url}
curl -X GET -H 'Accept: application/json; charset=UTF-8' \
  --url "${url}" \
  | grep true > /dev/null
  [ "$?" -ne 0 ] && echo "${RED}RESULT: fail${NC}" && exit 1
echo "${GREEN}RESULT: pass${NC}"
echo


echo "TEST: POST request should return a new client in the response body with an 'id'"
url="http://${hostname}/clients"
echo ${url}
curl -X POST -H "Cache-Control: no-cache" -d "{
      \"application\": \"${application}\",
      \"secret\": \"${secret}\"
  }" --url "${url}" \
  | grep '"id":"[a-zA-Z0-9]\{24\}"' > /dev/null
  [ "$?" -ne 0 ] && echo "${RED}RESULT: fail${NC}" && exit 1
echo "${GREEN}RESULT: pass${NC}"
echo


echo "SETUP: Get the new client's apiKey for next test"
url="http://${hostname}/clients"
echo ${url}
apiKey=$(curl -X POST -H "Cache-Control: no-cache" -d "{
      \"application\": \"${application}\",
      \"secret\": \"${secret}\"
  }" --url "${url}" \
  | grep -o '"apiKey":"[a-zA-Z0-9]\{24\}"' \
  | grep -o '[a-zA-Z0-9]\{24\}' \
  | sed -e 's/^"//'  -e 's/"$//')
echo ${CYAN}apiKey: ${apiKey}${NC}
echo


echo "TEST: GET request should return a new jwt in the response body"
url="http://${hostname}/jwts?apiKey=${apiKey}&secret=${secret}"
echo ${url}
curl -X GET -H "Cache-Control: no-cache" \
  --url "${url}" \
  | grep '[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}' > /dev/null
  [ "$?" -ne 0 ] && echo "${RED}RESULT: fail${NC}" && exit 1
echo "${GREEN}RESULT: pass${NC}"
echo


echo "SETUP: Get a new jwt using the new client for the next test"
url="http://${hostname}/jwts?apiKey=${apiKey}&secret=${secret}"
echo ${url}
jwt=$(curl -X GET -H "Cache-Control: no-cache" \
  --url "${url}" \
  | grep '[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}' \
  | sed -e 's/^"//'  -e 's/"$//')
echo ${CYAN}jwt: ${jwt}${NC}
echo


########## VEHICLE MICROSERVICE ##########
echo "TEST: POST request should return a new vehicle in the response body with an 'id'"
url="http://${hostname}/vehicles"
echo ${url}
curl -X POST -H "Cache-Control: no-cache" \
  -H "Authorization: Bearer ${jwt}" \
  -d "{
      \"year\": 2015,
      \"make\": \"${make}\",
      \"model\": \"${model}\",
      \"color\": \"White\",
      \"type\": \"Sedan\",
      \"mileage\": 250
  }" --url "${url}" \
  | grep '"id":"[a-zA-Z0-9]\{24\}"' > /dev/null
  [ "$?" -ne 0 ] && echo "${RED}RESULT: fail${NC}" && exit 1
echo "${GREEN}RESULT: pass${NC}"
echo


echo "SETUP: Get id from new vehicle for the next test"
url="http://${hostname}/vehicles?filter=make::${make}|model::${model}&limit=1"
echo ${url}
id=$(curl -X GET -H "Cache-Control: no-cache" \
  -H "Authorization: Bearer ${jwt}" \
  --url "${url}" \
  | grep '"id":"[a-zA-Z0-9]\{24\}"' \
  | grep -o '[a-zA-Z0-9]\{24\}' \
  | tail -1 \
  | sed -e 's/^"//'  -e 's/"$//')
echo ${CYAN}vehicle id: ${id}${NC}
echo


echo "TEST: GET request should return a vehicle in the response body with the requested 'id'"
url="http://${hostname}/vehicles/${id}"
echo ${url}
  curl -X GET -H "Cache-Control: no-cache" \
  -H "Authorization: Bearer ${jwt}" \
  --url "${url}" \
  | grep '"id":"[a-zA-Z0-9]\{24\}"' > /dev/null
  [ "$?" -ne 0 ] && echo "${RED}RESULT: fail${NC}" && exit 1
echo "${GREEN}RESULT: pass${NC}"
echo


########## MAINTENANCE MICROSERVICE ##########
echo "TEST: POST request should return a new maintenance record in the response body with an 'id'"
url="http://${hostname}/maintenances"
echo ${url}
curl -X POST -H "Cache-Control: no-cache" \
  -H "Authorization: Bearer ${jwt}" \
  -d "{
      \"vehicleId\": \"${id}\",
      \"serviceDateTime\": \"2015-27-00T15:00:00.400Z\",
      \"mileage\": 1000,
      \"type\": \"Test Maintenance\",
      \"notes\": \"This is a test notes.\"
  }" --url "${url}" \
  | grep '"id":"[a-zA-Z0-9]\{24\}"' > /dev/null
  [ "$?" -ne 0 ] && echo "${RED}RESULT: fail${NC}" && exit 1
echo "${GREEN}RESULT: pass${NC}"
echo


echo "SETUP: Get maintenance record id from new maintenance record for the next test"
url="http://${hostname}/maintenances?filter=vehicleId::${vehicle_id}&limit=1"
echo ${url}
maintenance_id=$(curl -X GET -H "Cache-Control: no-cache" \
  -H "Authorization: Bearer ${jwt}" \
  --url "${url}" \
  | grep '"id":"[a-zA-Z0-9]\{24\}"' \
  | grep -o '[a-zA-Z0-9]\{24\}' \
  | tail -1 \
  | sed -e 's/^"//'  -e 's/"$//')
echo ${CYAN}maintenance record id: ${maintenance_id}${NC}
echo


echo "TEST: PUT request should return the modified maintenance record in the response body with an 'id'"
url="http://${hostname}/maintenances/${maintenance_id}"
echo ${url}
curl -X PUT -H "Cache-Control: no-cache" \
  -H "Authorization: Bearer ${jwt}" \
  -d "{
      \"vehicleId\": \"${vehicle_id}\",
      \"serviceDateTime\": \"2015-27-00T15:00:00.400Z\",
      \"mileage\": 1000,
      \"type\": \"Test Maintenance\",
      \"notes\": \"This is an updated test note.\",
      \"createdAt\": \"2015-26-00T10:30:00.400Z\"
  }" --url "${url}" \
  | grep '"id":"[a-zA-Z0-9]\{24\}"' > /dev/null
  [ "$?" -ne 0 ] && echo "${RED}RESULT: fail${NC}" && exit 1
echo "${GREEN}RESULT: pass${NC}"
echo


echo "TEST: DELETE should remove new maintenance record and return a 204"
url="http://${hostname}/maintenances/${maintenance_id}"
echo ${url}
curl -X DELETE -I -H "Cache-Control: no-cache" \
  -H "Authorization: Bearer ${jwt}" \
  --url "${url}" \
  | grep '204 No Content' > /dev/null
  [ "$?" -ne 0 ] && echo "${RED}RESULT: fail${NC}" && exit 1
echo "${GREEN}RESULT: pass${NC}"
echo

########## VALET MICROSERVICE ##########
echo "TEST: POST request should return a new valet transaction in the response body with an 'id'"
url="http://${hostname}/valets"
echo ${url}
curl -X POST -H "Cache-Control: no-cache" \
  -H "Authorization: Bearer ${jwt}" \
  -d "{
      \"vehicleId\": \"${id}\",
      \"dateTimeIn\": \"2015-27-00T15:00:00.400Z\",
      \"parkingLot\": \"Test Parking Ramp\",
      \"parkingSpot\": 10,
      \"notes\": \"This is a test notes.\"
  }" --url "${url}" \
  | grep '"id":"[a-zA-Z0-9]\{24\}"' > /dev/null
  [ "$?" -ne 0 ] && echo "${RED}RESULT: fail${NC}" && exit 1
echo "${GREEN}RESULT: pass${NC}"
echo


echo "SETUP: Get valet transaction id from new valet transaction for the next test"
url="http://${hostname}/valets?filter=vehicleId::${vehicle_id}&limit=1"
echo ${url}
valet_id=$(curl -X GET -H "Cache-Control: no-cache" \
  -H "Authorization: Bearer ${jwt}" \
  --url "${url}" \
  | grep '"id":"[a-zA-Z0-9]\{24\}"' \
  | grep -o '[a-zA-Z0-9]\{24\}' \
  | tail -1 \
  | sed -e 's/^"//'  -e 's/"$//')
echo ${CYAN}valet transaction id: ${valet_id}${NC}
echo


echo "TEST: PUT request should return the modified valet transaction in the response body with an 'id'"
url="http://${hostname}/valets/${valet_id}"
echo ${url}
curl -X PUT -H "Cache-Control: no-cache" \
  -H "Authorization: Bearer ${jwt}" \
  -d "{
      \"dateTimeIn\": \"2015-27-00T15:00:00.400Z\",
      \"dateTimeOut\": \"2015-27-00T21:30:00.400Z\",
      \"parkingLot\": \"Test Parking Ramp\",
      \"parkingSpot\": 10,
      \"notes\": \"This is an updated test note.\",
      \"createdAt\": \"2015-26-00T10:30:00.400Z\"
  }" --url "${url}" \
  | grep '"id":"[a-zA-Z0-9]\{24\}"' > /dev/null
  [ "$?" -ne 0 ] && echo "${RED}RESULT: fail${NC}" && exit 1
echo "${GREEN}RESULT: pass${NC}"
echo


echo "TEST: DELETE should remove new valet transaction and return a 204 No Content"
url="http://${hostname}/valets/${valet_id}"
echo ${url}
curl -X DELETE -I -H "Cache-Control: no-cache" \
  -H "Authorization: Bearer ${jwt}" \
  --url "${url}" \
  | grep '204 No Content' > /dev/null
  [ "$?" -ne 0 ] && echo "${RED}RESULT: fail${NC}" && exit 1
echo "${GREEN}RESULT: pass${NC}"
echo

########## NEGATIVE TESTING ##########
echo "TEST: GET request with bad JWT should return a 401 Unauthorized"
url="http://${hostname}/vehicles"
echo ${url}
curl -X GET -I -H "Cache-Control: no-cache" \
  -H "Authorization: Bearer nOTaREalJwt99.eyJpc3MizNdpc3RlciJ9.5ciAxpfnW2C" \
  --url "${url}" \
  | grep '401 Unauthorized' > /dev/null
  [ "$?" -ne 0 ] && echo "${RED}RESULT: fail${NC}" && exit 1
echo "${GREEN}RESULT: pass${NC}"
echo
