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
	# Postfix setup
	# needs to be in running container so local randomly generated hostname can be in main.cf
	debconf-set-selections /home/tdr/postfix-debconf.conf
	rm /etc/postfix/*.cf
        dpkg-reconfigure -f noninteractive postfix
	service postfix start

	# Cron in foreground	
	/usr/sbin/cron -f

	# For debugging purposes it is possible to exec into a running container and start rsyslogd to see output of cron.
}


echo "export PATH=$PATH" >> /root/.profile
echo "export PERL5LIB=$PERL5LIB" >> /root/.profile

echo "export PATH=$PATH" >> /home/tdr/.profile
echo "export PERL5LIB=$PERL5LIB" >> /home/tdr/.profile
chown tdr.tdr /home/tdr/.profile

echo "MAILTO=sysadmin@c7a.ca" > /etc/cron.d/repomanage
echo "PATH=$PATH" >> /etc/cron.d/repomanage
echo "PERL5LIB=$PERL5LIB" >> /etc/cron.d/repomanage


if [ "$1" = 'repomanage' ]; then
	cat <<-RMCRON >>/etc/cron.d/repomanage
# Repository Validation each evening
47 16 * * * tdr /bin/bash -c "date ; tdr verify --timelimit=43200 --maxprocs=8 ; date ; tdr walk ; date"
# Empty the trashcans every 6 hours
34 5/6 * * * tdr /bin/bash -c "find /cihmz*/repository/trashcan/ -mindepth 1 -maxdepth 1 -mmin +360 -exec rm -rf {} \;"
# Replication check every 10 minutes (find work and put in queue, then run rsync to add to repository)
0-59/10 * * * * tdr /bin/bash -c "tdr-replicationwork ; tdr-replicate"
RMCRON
        cronandmail
elif [ "$1" = 'repomanagefrom' ]; then
	cat <<-RMCRON >>/etc/cron.d/repomanage
# Repository Validation each evening
47 16 * * * tdr /bin/bash -c "date ; tdr verify --timelimit=43200 --maxprocs=8 ; date ; tdr walk ; date"
# Empty the trashcans every 6 hours
34 5/6 * * * tdr /bin/bash -c "find /cihmz*/repository/trashcan/ -mindepth 1 -maxdepth 1 -mmin +360 -exec rm -rf {} \;"
# Replication check every 10 minutes (find work and put in queue, then run rsync to add to repository)
0-59/10 * * * * tdr /bin/bash -c "tdr-replicationwork ; tdr-swiftreplicate --fromswift"
RMCRON
        cronandmail
elif [ "$1" = 'replicate' ]; then
	cat <<-REPLI >>/etc/cron.d/repomanage
# Empty the trashcans every 6 hours
34 5/6 * * * tdr /bin/bash -c "find /cihmz*/repository/trashcan/ -mindepth 1 -maxdepth 1 -mmin +360 -exec rm -rf {} \;"
# Replication check every 10 minutes (find work and put in queue, then run rsync to add to repository)
0-59/10 * * * * tdr /bin/bash -c "tdr-replicationwork ; tdr-replicate"
REPLI
	cronandmail
elif [ "$1" = 'swiftvalidate' ]; then
	        cat <<-SVCRON >>/etc/cron.d/repomanage
# Repository Validation each evening
47 16 * * * tdr /bin/bash -c "date ; tdr-swiftvalidate --timelimit=43200 ; date ; tdr-swiftwalk ; date"
SVCRON
        cronandmail
elif [ "$1" = 'swiftreplicate' ]; then
	        cat <<-SRCRON >>/etc/cron.d/repomanage
# Replication check every 10 minutes (find work and put in queue, then copy to Swift)
5-59/10 * * * * tdr /bin/bash -c "tdr-swiftreplicationwork ; tdr-swiftreplicate --maxprocs=8"
SRCRON
        cronandmail
else
    # Otherwise run what was asked as the 'tdr' user
    exec sudo -u tdr -i "$@"
fi
