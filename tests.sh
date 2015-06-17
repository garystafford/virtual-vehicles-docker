#!/bin/sh

########################################################################
#
# title:       Virtual-Vehicles Project Integration Tests
# author:      Gary A. Stafford (https://programmaticponderings.com)
# url:         https://github.com/garystafford/virtual-vehicles-docker  
# description: Performs integration tests on the Virtual-Vehicles Java
#              microservices example REST API
# to run:      sh test.sh
#
########################################################################

echo --- Integration Tests ---
echo

# variables
hostname="localhost"
application="Test API Client"
secret="pbZCmrFSBqkYtMh"

#tests
echo "TEST: GET request should return 'true' in the response body"
curl -X GET -H 'Accept: application/json; charset=UTF-8' \
--url "http://${hostname}:8581/vehicles/utils/ping.json" \
| grep true > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo


echo "TEST: POST request should return a new client in the response body with an 'id'"
curl -X POST -H "Cache-Control: no-cache" -d '{
    "application": "${application}",
    "secret": "${secret}"
}' --url "http://${hostname}:8587/clients" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo


echo "SETUP: Get the new client's apiKey for next test"
apiKey=$(curl -X POST -H "Cache-Control: no-cache" -d '{
    "application": "${application}",
    "secret": "${secret}"
}' --url "http://${hostname}:8587/clients" \
| grep -o '"apiKey":"[a-zA-Z0-9]\{24\}"' \
| grep -o '[a-zA-Z0-9]\{24\}' \
| sed -e 's/^"//'  -e 's/"$//')

echo
#echo apiKey: ${apiKey} && echo


echo "TEST: GET request should return a new jwt in the response body"
curl -X GET -H "Cache-Control: no-cache" \
--url "http://${hostname}:8587/jwts?apiKey=${apiKey}&secret=pbZCmrFSBqkYtMh" \
| grep '[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}' > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo


echo "SETUP: Get a new jwt using the new client for the next test"
 jwt=$(curl -X GET -H "Cache-Control: no-cache" \
--url "http://${hostname}:8587/jwts?apiKey=2bv1JOK6M3o4ah9dUDPi8SRs&secret=pbZCmrFSBqkYtMh" \
| grep '[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}' \
| sed -e 's/^"//'  -e 's/"$//')

echo
#echo jwt: ${jwt} && echo


echo "TEST: POST request should return a new vehicle in the response body with an 'id'"
curl -X POST -H "Cache-Control: no-cache" \
-H "Authorization: Bearer ${jwt}" \
-d '{
    "year": 2015,
    "make": "Test",
    "model": "Foo",
    "color": "White",
    "type": "Sedan",
    "mileage": 250
}' --url "http://${hostname}:8581/vehicles" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo