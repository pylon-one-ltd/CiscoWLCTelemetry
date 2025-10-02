# Cisco 9800 WLC Telemetry
[![Docker Deployment](https://github.com/pylon-one-ltd/CiscoWLCTelemetry/actions/workflows/docker-deployment.yaml/badge.svg)](https://github.com/pylon-one-ltd/CiscoWLCTelemetry/actions/workflows/docker-deployment.yaml)

Run a gRPC server and receive telemetry from a Cisco 9800 series WLC. Interpret this data into per client stats and load this into Influx or Zabbix.

### Metrics Gathered

 - clients_by_phy_type
 - clients_by_access_point
 - clients_by_access_point_by_slot
 - clients_by_ssid
 - clients_by_site
 - clients_by_policy_tag
 - clients_by_wpa_version
 - clients_by_key_mgmt_type

### WLC Configuration

Timers used at your own risk. Please review the documentation for the version being run

```
telemetry ietf subscription 101
 encoding encode-kvgpb
 filter xpath /wireless-client-oper:client-oper-data/dot11-oper-data
 stream yang-push
 update-policy periodic 6000
 receiver ip address YOUR_IP_HERE 57001 protocol grpc-tcp

telemetry ietf subscription 102
 encoding encode-kvgpb
 filter xpath /wireless-access-point-oper:access-point-oper-data/capwap-data
 stream yang-push
 update-policy periodic 12000
 receiver ip address YOUR_IP_HERE 57001 protocol grpc-tcp

telemetry ietf subscription 103
 encoding encode-kvgpb
 filter xpath /wireless-wlan-cfg:wlan-cfg-data/policy-list-entries
 stream yang-push
 update-policy periodic 12000
 receiver ip address YOUR_IP_HERE 57001 protocol grpc-tcp
```

### Docker container for Influx

```
docker pull ghcr.io/pylon-one-ltd/cisco-telemetry:latest
docker run --detach \
	-p 57001:57001 \
	--env TELEM_DATABASE_TYPE=influx2 \
	--env INFLUX_URL=http://localhost:8086 \
	--env INFLUX_BUCKET=bucketname \
	--env INFLUX_ORG=orgnamehere \
	--env INFLUX_TOKEN=tokenhere \
	--restart=unless-stopped --name=telemetry-grpc \
	ghcr.io/pylon-one-ltd/cisco-telemetry:latest
```