# cihm-repomanage
Repository management (replication, validation)

This is a docker image used to manage the files on a repository host.  This includes walking filesystems (to check which AIPs are stored or missing), replication (from other repository hosts) or fixity checking (BagIt verification).

Commands are intended to be run from cron, and need write access to the repository.

