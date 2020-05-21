#!/bin/sh
export INFLUX_API_PORT=8086
export INFLUX_GRAPHITE_PORT=2003
export GRAFANA_PORT=3000
# JMeter server
# export HOST=127.0.0.1
# export PORT=1099

docker rm -f jmeter-influxdb jmeter-grafana
docker-compose -f stack.yml up -d

sleep 5
docker exec jmeter-influxdb influx -execute 'create database "jmeter"'
curl -X POST -H "Content-Type: application/json" -d "{\"name\":\"JMeter\",\"type\":\"influxdb\",\"access\":\"proxy\",\"url\":\"http://jmeter-influxdb:8086\",\"password\":\"\",\"user\":\"\",\"database\":\"jmeter\",\"basicAuth\":false}" http://admin:admin@localhost:${GRAFANA_PORT}/api/datasources
curl -X POST -H "Content-Type: application/json" --data-binary @./dashboard.json http://admin:admin@localhost:${GRAFANA_PORT}/api/dashboards/db
curl -X PUT -H "Content-Type: application/json" -d '{"homeDashboardId":1}' http://admin:admin@localhost:${GRAFANA_PORT}/api/user/preferences
