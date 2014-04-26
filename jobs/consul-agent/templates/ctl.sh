#!/bin/bash -e

LOG_DIR=/var/vcap/sys/log/consul-agent
RUN_DIR=/var/vcap/sys/run/consul-agent
DATA_DIR=/var/vcap/data/consul-agent
CONF_DIR=/var/vcap/jobs/consul-agent/config

PKG=/var/vcap/packages/consul-agent

case $1 in
  start)
    mkdir -p $LOG_DIR
    chown -R vcap:vcap $LOG_DIR

    mkdir -p $RUN_DIR
    chown -R vcap:vcap $RUN_DIR

    mkdir -p $DATA_DIR
    chown -R vcap:vcap $DATA_DIR

    setcap cap_net_bind_service=+ep $PKG/bin/consul

    if ! grep -q 127.0.0.1 /etc/resolv.conf; then
      sed -i -e '1i nameserver 127.0.0.1' /etc/resolv.conf
    fi

    echo $$ > ${RUN_DIR}/consul-agent.pid

    exec chpst -u vcap:vcap $PKG/bin/consul agent \
      -config-file=$CONF_DIR/config.json \
      1>>$LOG_DIR/consul-agent.stdout.log \
      2>>$LOG_DIR/consul-agent.stderr.log
    ;;

  stop)
    $PKG/bin/consul leave
    ;;

  *)
    echo "Usage: ctl {start|stop}"
    ;;
esac
