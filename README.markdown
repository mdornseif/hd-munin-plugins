= Collected Munin Plugins =

This is collection of [Munin-Plugins][0] we use internally at Hudora. Most
are developed by ourselfs, some are taken from other locations and are
bundled here for convenience.

[0]: http://munin.projects.linpro.no/

* `couchdb_` - graph information about about a [CouchDB][1] database
* `cupsactivejobs` - graph the number of active Jobs in a [CUPS Printsterver][2]
* `filecount` - Count numberso of files in a directory tree
* `fogbugz_tickets` - graph tickets in [fogbugz][3]
* `fogbugz_tickets2` - graph tickets in [fogbugz][3]
* `freeradius` - this file is from from http://munin.projects.linpro.no/attachment/wiki/plugin-freeradius/freeradius
* `hppages` - graph pages printed on a HP or Brother Printer
* `hptoner` - graph toner usage on a HP or Brother Printer
* `httploadtime`  - graph number of milliseconds it took to access an url
* `mobotixinfo` - graph different information about a bunch of mobotix cameras
* `nutch_last_modified.py` - graph index age of a nutch instance using statistics.jsp
* `nutch_total_docs.py` - graph number of documents of a nutch instance using statistics.jsp
* `nutch_total_terms.py` - graph number of terms of a nutch instance using statistics.jsp
* `odbc_bridge` - graph latency of the AS/400 odbc_bridge, which is part of http://github.com/hudora/huSoftM
* `oldestfile.py` - graph the age in hours of the oldest file in a directory hierachy
* `postgres_block_read_` - this file is from http://munin.projects.linpro.no/changeset/1326
* `postgres_connections` - this file is from http://munin.projects.linpro.no/changeset/1326
* `postgres_locks` - this file is from http://munin.projects.linpro.no/changeset/1326
* `postgres_space_` - this file is from http://munin.projects.linpro.no/changeset/1326
* `rabbitmq-connections` - this file is part of http://github.com/ask/rabbitmq-munin
* `rabbitmq-consumers` - this file is part of http://github.com/ask/rabbitmq-munin
* `rabbitmq-messages` - this file is part of http://github.com/ask/rabbitmq-munin
* `rabbitmq-messages_unacknowledged` - this file is part of http://github.com/ask/rabbitmq-munin
* `rabbitmq-messages_uncommitted` - this file is part of http://github.com/ask/rabbitmq-munin
* `rabbitmq-queue_memory` - this file is part of http://github.com/ask/rabbitmq-munin
* `ubnt__signal` graph Ubiquiti Networks Nano Station signal strength using HTTP
* `ubnt_rates_` - graph Ubiquiti Networks Nano Station RX/TX rates using SNMP
* `uptime` - this file is from http://munin.projects.linpro.no/browser/trunk/node/node.d.freebsd/uptime.in

[1]: http://couchdb.apache.org/
[2]: http://www.cups.org/
[3]: http://www.fogcreek.com/FogBUGZ/


= Plugins for internal use at Hudora =

This Polugins are probably only usefull internally at Hudora because they rely on onternal-only applications.

* `mypl_stats_a` - statistics about myPL/kernelE our internal Warehouse Managment System
* `mypl_stats_b` - statistics about myPL/kernelE our internal Warehouse Managment System
* `mypl_stats_c` - statistics about myPL/kernelE our internal Warehouse Managment System
* `mypl_stats_d` - statistics about myPL/kernelE our internal Warehouse Managment System
* `softm_auftragsschnittstelle` - Checks hanging Transactions in SoftM. Compare http://github.com/hudora/huSoftM
* `softm_dfsl` - Checks hanging Transactions in SoftM. Compare http://github.com/hudora/huSoftM
* `softm_ischnittstellen` - Checks hanging Transactions in SoftM. Compare http://github.com/hudora/huSoftM
* `softm_vorgangsanzahl` - Checks number of Transactions in SoftM. Compare http://github.com/hudora/huSoftM
* `softm_vorgangsanzahl_offen` - Checks number of  Transactions in SoftM. Compare http://github.com/hudora/huSoftM
* `stapler_munin.sh` - Checks staplr - our internal fork lift application
