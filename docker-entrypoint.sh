#!/bin/bash
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

set -e

export PERL5LIB=/home/tdr/CIHM-TDR/lib:/home/tdr/CIHM-Swift/lib
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/tdr/CIHM-TDR/bin:/home/tdr/CIHM-Swift/bin

# This seems to be owned by wrong user from time to time.
mkdir -p /var/lock/tdr/
chown tdr.tdr /var/lock/tdr/
mkdir -p /var/log/tdr/
chown tdr.tdr /var/log/tdr/

cronandmail ()
{


    # Set up so that hostname --fqdn is correct (needed for mailing)
	sed -e "s/^\([^ \t]*\).*$HOSTNAME.*$/\1 $HOSTNAME.c7a.ca $HOSTNAME/" /etc/hosts >/etc/hosts.new
	cat /etc/hosts.new >/etc/hosts


	# For debugging purposes it is possible to exec into a running container and start rsyslogd to see output of cron.
	# rsyslogd

	# Postfix setup
	# needs to be in running container so local hostname can be in main.cf
	debconf-set-selections /home/tdr/postfix-debconf.conf
	rm /etc/postfix/*.cf
    dpkg-reconfigure -f noninteractive postfix
    # Some configuration not set correctly by defaults
	postconf mailbox_size_limit=0
	postconf mydestination=$HOSTNAME
	postconf masquerade_domains=c7a.ca


    # Finally, start postfix
	service postfix start


	# Cron in foreground	
	/usr/sbin/cron -f

}


echo "export PATH=$PATH" >> /root/.profile
echo "export PERL5LIB=$PERL5LIB" >> /root/.profile

echo "export PATH=$PATH" >> /home/tdr/.profile
echo "export PERL5LIB=$PERL5LIB" >> /home/tdr/.profile
chown tdr.tdr /home/tdr/.profile

echo "MAILTO=sysadmin@c7a.ca" > /etc/cron.d/repomanage
echo "PATH=$PATH" >> /etc/cron.d/repomanage
echo "PERL5LIB=$PERL5LIB" >> /etc/cron.d/repomanage


if [ "$1" = 'repomanagefrom' ]; then
# Used by Romano, Eclipse
# 72000 seconds = 20 hours
	cat <<-RMFCRON >>/etc/cron.d/repomanage
# Repository Validation each evening
47 8 * * * tdr /bin/bash -c "date ; tdr verify --timelimit=72000 --maxprocs=8 ; date ; tdr walk ; date"
# Empty the trashcans every 6 hours
34 5,11,17,22 * * * tdr /bin/bash -c "find /cihmz*/repository/trashcan/ -mindepth 1 -maxdepth 1 -mmin +360 -exec rm -rf {} \;"
# Replication check every 10 minutes (find work and put in queue, then run rsync to add to repository)
*/10 * * * * tdr /bin/bash -c "tdr-replicationwork ; tdr-swiftreplicate --fromswift"
RMFCRON
	cronandmail
elif [ "$1" = 'romano' ]; then
# Used by Romano during refresh
# 72000 seconds = 20 hours
	cat <<-RCRON >>/etc/cron.d/repomanage
# Empty the trashcans every 6 hours
34 5,11,17,22 * * * tdr /bin/bash -c "find /cihmz*/repository/trashcan/ -mindepth 1 -maxdepth 1 -mmin +360 -exec rm -rf {} \;"
# Replication check every 10 minutes (find work and put in queue, then run rsync to add to repository)
# timelimit is 60*60*6 (6 hours) for replicating, which might help with zombies or other odd issues.
*/10 * * * * tdr /bin/bash -c "tdr-replicationwork ; tdr-swiftreplicate --fromswift --maxprocs=20 --timelimit=21600"
RCRON
	cronandmail

elif [ "$1" = 'swiftvalidate' ]; then
# Used by Gouda to validate Swift repository
# 43200 seconds = 12 hours
	        cat <<-SVCRON >>/etc/cron.d/repomanage
# Repository Validation each evening
47 16 * * * tdr /bin/bash -c "date ; tdr-swiftvalidate --timelimit=43200 ; date ; tdr-swiftwalk ; date"
SVCRON
        cronandmail
else
    # Otherwise run what was asked as the 'tdr' user
    exec sudo -u tdr -i "$@"
fi
