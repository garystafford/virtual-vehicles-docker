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

### VARIABLES ###
# colorize output
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # no color

hostname=${1-'localhost'} # use input param or default to localhost
application="Test API Client $(date +%s)" # randomized
secret="$(date +%s | sha256sum | base64 | head -c 15)" # randomized

echo "${CYAN}hostname: ${hostname}${NC}"
echo "${CYAN}nginx_port: ${nginx_port}${NC}"
echo "${CYAN}application: ${application}${NC}"
echo "${CYAN}secret: ${secret}${NC}"
echo


### TESTS ###
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


echo "TEST: POST request should return a new vehicle in the response body with an 'id'"
url="http://${hostname}/vehicles"
echo ${url}
curl -X POST -H "Cache-Control: no-cache" \
-H "Authorization: Bearer ${jwt}" \
-d '{
    "year": 2015,
    "make": "Test",
    "model": "Foo",
    "color": "White",
    "type": "Sedan",
    "mileage": 250
}' --url "${url}" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' > /dev/null
[ "$?" -ne 0 ] && echo "${RED}RESULT: fail${NC}" && exit 1
echo "${GREEN}RESULT: pass${NC}"
echo


echo "SETUP: Get id from new vehicle for the next test"
url="http://${hostname}/vehicles?filter=make::Test|model::Foo&limit=1"
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