#!/bin/sh

########################################################################
#
# title:          Virtual-Vehicles Project Integration Tests
# author:         Gary A. Stafford (https://programmaticponderings.com)
# url:            https://github.com/garystafford/virtual-vehicles-docker  
# description:    Performs integration tests on the Virtual-Vehicles
#                 microservices
# to run:         sh tests.sh -v
# docker-machine: sh tests.sh $(docker-machine ip test) -v
#
########################################################################

echo --- Integration Tests ---
echo

### VARIABLES ###
hostname=${1-'localhost'} # use input param or default to localhost
application="Test API Client $(date +%s)" # randomized
secret="$(date +%s | sha256sum | base64 | head -c 15)" # randomized

echo hostname: ${hostname}
echo application: ${application}
echo secret: ${secret}
echo


### TESTS ###
echo "TEST: GET request should return 'true' in the response body"
url="http://${hostname}:8581/vehicles/utils/ping.json"
echo ${url}
curl -X GET -H 'Accept: application/json; charset=UTF-8' \
--url "${url}" \
| grep true > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo


echo "TEST: POST request should return a new client in the response body with an 'id'"
url="http://${hostname}:8587/clients"
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
url="http://${hostname}:8587/clients"
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
url="http://${hostname}:8587/jwts?apiKey=${apiKey}&secret=${secret}"
echo ${url}
curl -X GET -H "Cache-Control: no-cache" \
--url "${url}" \
| grep '[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}' > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo


echo "SETUP: Get a new jwt using the new client for the next test"
url="http://${hostname}:8587/jwts?apiKey=${apiKey}&secret=${secret}"
echo ${url}
jwt=$(curl -X GET -H "Cache-Control: no-cache" \
--url "${url}" \
| grep '[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}' \
| sed -e 's/^"//'  -e 's/"$//')
echo jwt: ${jwt}
echo


echo "TEST: POST request should return a new vehicle in the response body with an 'id'"
url="http://${hostname}:8581/vehicles"
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
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo


echo "SETUP: Get id from new vehicle for the next test"
url="http://${hostname}:8581/vehicles?filter=make::Test|model::Foo&limit=1"
echo ${url}
id=$(curl -X GET -H "Cache-Control: no-cache" \
-H "Authorization: Bearer ${jwt}" \
--url "${url}" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' \
| grep -o '[a-zA-Z0-9]\{24\}' \
| tail -1 \
| sed -e 's/^"//'  -e 's/"$//')
echo vehicle id: ${id}
echo


echo "TEST: GET request should return a vehicle in the response body with the requested 'id'"
url="http://${hostname}:8581/vehicles/${id}"
echo ${url}
curl -X GET -H "Cache-Control: no-cache" \
-H "Authorization: Bearer ${jwt}" \
--url "${url}" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo