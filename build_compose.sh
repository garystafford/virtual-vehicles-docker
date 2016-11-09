#!/bin/sh

########################################################################
#
# title:          Docker Compose YAML Template Variable Substitution Script
# author:         Gary A. Stafford (https://programmaticponderings.com)
# url:            https://github.com/garystafford/virtual-vehicles-docker
# description:    Replaces tokens in template and create docker-compose.yml
#
# to run:         sh run_comppse.sh
#
########################################################################

# reference: http://www.cyberciti.biz/faq/unix-linux-replace-string-words-in-many-files/
# http://www.cyberciti.biz/faq/howto-sed-substitute-find-replace-multiple-patterns/

base_url_token="{{ base_url }}"
base_url="api.virtual-vehicles.com" # url of public rest api

host_ip_token="{{ host_ip }}"
host_ip=$(docker-machine ip $(docker-machine active)) # ip of host

echo "  ${base_url_token} = ${base_url}"
echo "  ${host_ip_token} = ${host_ip}"

sed -e "s/${base_url_token}/${base_url}/g" \
    -e "s/${host_ip_token}/${host_ip}/g" \
    < docker-compose-template-v2.yml \
    > docker-compose.yml
