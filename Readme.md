# VuFind Z39.50/SRU Gateway

A Z39.50 and SRU gateway integration for [VuFind](https://vufind.org) using [Metaproxy](https://www.indexdata.com/resources/software/metaproxy/) with Solr backend connectivity.

## Overview

This project provides a bridge between Z39.50/SRU protocols and VuFind's Solr index, allowing other library systems to search VuFind using Z39.50/SRU protocols for copy cataloguing.

The metaproxy configuration is based on the example by Michael Lackhoff as discussed in [VUFIND-1530](https://openlibraryfoundation.atlassian.net/browse/VUFIND-1530).

## Requirements

- Metaproxy 1.15.0 or higher
- YAZ toolkit (only for testing)
- Linux/Unix environment

#### Install Metaproxy and dependencies

For example, on Debian 12:
```bash
sudo mkdir -p /etc/apt/keyrings
sudo wget https://ftp.indexdata.com/debian/indexdata.asc -O /etc/apt/keyrings/indexdata.asc
sudo echo 'deb [signed-by=/etc/apt/keyrings/indexdata.asc] http://ftp.indexdata.dk/debian bookworm main' > /etc/apt/sources.list.d/indexdata.list
apt update
sudo apt install metaproxy yaz
```

## Configure VuFind and Solr

1. Edit `[vufind]/import/marc_local.properties` file before indexing:
    - Set `fullrecord = FullRecordAsXML`

2. **Important**: Ensure that default response format on biblio core of Solr is set to XML:
    - Edit `[vufind]/solr/vufind/biblio/conf/solrconfig.xml`
    - Look for `<requestHandler name="standard" class="solr.SearchHandler" default="true">`
    - Under `<lst name="defaults">` add `<str name="wt">xml</str>`
    - Restart Solr


## Download

```bash
git clone https://github.com/semanticlib/vufind-metaproxy.git
```

**Optional**: Edit `[vufind-metaproxy]/vufind.xml`:
- Update Port binding (if needed): `<port>@:2100</port>`
- Update ZURL (if needed): `<zurl>localhost:8983/solr/biblio/select</zurl>`

## Test Run

To manually start the Metaproxy gateway, run:

```bash
cd vufind-metaproxy
metaproxy -c vufind.xml
```

#### Testing Z39.50 connection:

```
yaz-client localhost:2100/vufind
Z> find @attr 1=4 test
Z> show 1+1
Z> format xml
Z> show 1+1
```

#### Test SRU connection:

```bash
curl "http://localhost:2100/vufind?operation=explain"
curl "http://localhost:2100/vufind?operation=searchRetrieve&query=title=test"
curl "http://localhost:2100/vufind?operation=searchRetrieve&query=title=test&maximumRecords=1"
```


## Install as a Systemd service

To install the Metaproxy gateway as a systemd service, run the following commands:
```bash
cd /path/to/vufind-metaproxy
sudo bash install_service.sh
```

The installation script will:
1. Copy the files into installation dir (default: `/usr/local/vufind-metaproxy`)
2. Update the service and logrotate files with the specified user and group.
3. Deploy the service and logrotate configuration files.
4. Start and enable the service.

After installation, `vufind-metaproxy` service will automatically start on system boot.

### Logs
Logs are stored in `/var/log/vufind-metaproxy.log`. Log rotation is configured to keep it for 7 days.


## Uninstall the service

To uninstall the service run this:
```bash
cd /path/to/vufind-metaproxy
sudo bash uninstall_service.sh
```


## Important links

- [VUFIND-1530](https://openlibraryfoundation.atlassian.net/browse/VUFIND-1530) for example by Michael Lackhoff.
- [https://github.com/subugoe/metaproxy-SUB](https://github.com/subugoe/metaproxy-SUB)

## Contributing

Pull requests are welcome.
