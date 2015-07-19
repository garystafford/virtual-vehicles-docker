#!/bin/sh

########################################################################
#
# title:          Virtual-Vehicles Project Integration Tests
# author:         Gary A. Stafford (https://programmaticponderings.com)
# url:            https://github.com/garystafford/virtual-vehicles-docker  
# description:    Performs integration tests on the Virtual-Vehicles
#                 microservices
# to run:         sh tests.sh
# docker-machine: sh tests.sh $(docker-machine ip test)
#
########################################################################

echo --- Integration Tests ---
echo

########## VARIABLES ##########
hostname=${1-'localhost'} # use input param or default to localhost
application="Test API Client $(date +%s)" # randomized
secret="$(date +%s | sha256sum | base64 | head -c 15)" # randomized
make="Test"
model="Foo"

echo hostname: ${hostname}
echo application: ${application}
echo secret: ${secret}
echo make: ${make}
echo model: ${model}
echo


########## AUTHENTICATION MICROSERVICE ##########
echo "TEST: GET request should return 'true' in the response body"
url="http://${hostname}/vehicles/utils/ping.json"
echo ${url}
curl -X GET -H 'Accept: application/json; charset=UTF-8' \
--url "${url}" \
| grep true > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo


echo "TEST: POST request should return a new client in the response body with an 'id'"
url="http://${hostname}/clients"
echo ${url}
curl -X POST -H "Cache-Control: no-cache" -d "{
    \"application\": \"${application}\",
    \"secret\": \"${secret}\"
}" --url "${url}" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
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
echo apiKey: ${apiKey}
echo


echo "TEST: GET request should return a new jwt in the response body"
url="http://${hostname}/jwts?apiKey=${apiKey}&secret=${secret}"
echo ${url}
curl -X GET -H "Cache-Control: no-cache" \
--url "${url}" \
| grep '[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}' > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo


echo "SETUP: Get a new jwt using the new client for the next test"
url="http://${hostname}/jwts?apiKey=${apiKey}&secret=${secret}"
echo ${url}
jwt=$(curl -X GET -H "Cache-Control: no-cache" \
--url "${url}" \
| grep '[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}' \
| sed -e 's/^"//'  -e 's/"$//')
echo jwt: ${jwt}
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
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo


echo "SETUP: Get id from new vehicle for the next test"
url="http://${hostname}/vehicles?filter=make::${make}|model::${model}&limit=1"
echo ${url}
vehicle_id=$(curl -X GET -H "Cache-Control: no-cache" \
-H "Authorization: Bearer ${jwt}" \
--url "${url}" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' \
| grep -o '[a-zA-Z0-9]\{24\}' \
| tail -1 \
| sed -e 's/^"//'  -e 's/"$//')
echo vehicle id: ${vehicle_id}
echo


echo "TEST: GET request should return a vehicle in the response body with the requested 'id'"
url="http://${hostname}/vehicles/${vehicle_id}"
echo ${url}
curl -X GET -H "Cache-Control: no-cache" \
-H "Authorization: Bearer ${jwt}" \
--url "${url}" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo


########## MAINTENANCE MICROSERVICE ##########
echo "TEST: POST request should return a new maintenance record in the response body with an 'id'"
url="http://${hostname}/maintenances"
echo ${url}
curl -X POST -H "Cache-Control: no-cache" \
-H "Authorization: Bearer ${jwt}" \
-d "{
    \"vehicleId\": \"${vehicle_id}\",
    \"serviceDateTime\": \"2015-27-00T15:00:00.400Z\",
    \"mileage\": 1000,
    \"type\": \"Test Maintenance\",
    \"notes\": \"This is a test note.\"
}" --url "${url}" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
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
echo maintenance record id: ${maintenance_id}
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
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo


echo "TEST: DELETE should remove new maintenance record and return a 204"
url="http://${hostname}/maintenances/${maintenance_id}"
echo ${url}
curl -X DELETE -I -H "Cache-Control: no-cache" \
-H "Authorization: Bearer ${jwt}" \
--url "${url}" \
| grep '204 No Content' > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
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
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
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
echo valet transaction id: ${valet_id}
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
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo


echo "TEST: DELETE should remove new valet transaction and return a 204"
url="http://${hostname}/valets/${valet_id}"
echo ${url}
curl -X DELETE -I -H "Cache-Control: no-cache" \
-H "Authorization: Bearer ${jwt}" \
--url "${url}" \
| grep '204 No Content' > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo

########## NEGATIVE TESTING ##########
echo "TEST: GET request with bad JWT should return a 401 Unauthorized"
url="http://${hostname}/vehicles"
echo ${url}
curl -X GET -I -H "Cache-Control: no-cache" \
-H "Authorization: Bearer not.valid.jwt" \
--url "${url}" \
| grep '401 Unauthorized' > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo