#!/bin/sh

## TODO: convert to bash !
## TODO: to execute tests on containers, embed hello-world as a tar archive and, if no container is running, import it locally, if it doesn't exist; other solution: check if alpine is available and start it with an "echo" command.

check_2() {
  logit ""
  id_1="1"
  desc_1="Host/OS and Docker Daemon"
  check_1="$id_1 - $desc_1"
  info "$check_1"
  startsectionjson "$id_1" "$desc_1"
}

# docker-compose should be used instead of docker run command line
check_2_32() {
  id_2_32="2.32"
  desc_2_32="docker-compose should be used instead of docker run command line"
  check_2_32="$id_2_32  - $desc_2_32"
  starttestjson "$id_2_32" "$desc_2_32"

  totalChecks=$((totalChecks + 1))
  note "$check_2_32"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# Containers must be based on trusted images only
check_2_33() {
  id_2_33="2.33"
  desc_2_33="Containers must be based on trusted images only"
  check_2_33="$id_2_33  - $desc_2_33"
  starttestjson "$id_2_33" "$desc_2_33"

  totalChecks=$((totalChecks + 1))
  note "$check_2_33"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# Timezone should be the same as host's in containers
check_2_34() {
  id_2_34="2.34"
  desc_2_34="Timezone should be the same as host's in containers"
  check_2_34="$id_2_34  - $desc_2_34"
  starttestjson "$id_2_34" "$desc_2_34"

  totalChecks=$((totalChecks + 1))

  if command -v tzconfig 1>/dev/null; then
    pass "$check_2_34"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_2_34"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# Secrets must not be stored in descriptors
check_2_35() {
  id_2_35="2.35"
  desc_2_35="Secrets must not be stored in descriptors"
  check_2_35="$id_2_35  - $desc_2_35"
  starttestjson "$id_2_35" "$desc_2_35"

  totalChecks=$((totalChecks + 1))
  note "$check_2_35"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# SSH (and remote accesses) to a container must not be allowed
check_2_36() {
  id_2_36="2.36"
  desc_2_36="SSH (and remote accesses) to a container must not be allowed"
  check_2_36="$id_2_36  - $desc_2_36"
  starttestjson "$id_2_36" "$desc_2_36"

  totalChecks=$((totalChecks + 1))

  ## NOTE: this rule must apply on containers

  containers_with_ssh=false
  for cont in `docker ps -aq`; do
    docker exec $cont ps -el | grep -q ssh && echo $cont && containers_with_ssh=true
  done
  if ! $containers_with_ssh; then
    pass "$check_2_36"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_2_36"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# Host's network namespace must not be shared
check_2_37() {
  id_2_37="2.37"
  desc_2_37="Host's network namespace must not be shared"
  check_2_37="$id_2_37  - $desc_2_37"
  starttestjson "$id_2_37" "$desc_2_37"

  totalChecks=$((totalChecks + 1))

  ## NOTE: this rule must apply on containers

  net_hosts="$(docker ps -aq | xargs docker inspect -f '{{ Id }}:{{ .HostConfig.NetworkMode }}'|grep host)"
  if [ -z "$net_hosts" ]; then
    pass "$check_2_37"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    echo "$net_hosts"
    warn "$check_2_37"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# Process namespace must not be shared with host
check_2_38() {
  id_2_38="2.38"
  desc_2_38="Process namespace must not be shared with host"
  check_2_38="$id_2_38  - $desc_2_38"
  starttestjson "$id_2_38" "$desc_2_38"

  totalChecks=$((totalChecks + 1))

  ## NOTE: this rule must apply on containers

  pid_modes="$(docker ps -aq | xargs docker inspect -f '{{ Id }}:{{ .HostConfig.PidMode }}'|grep host)"
  if [ -z "$pid_modes" ]; then
    pass "$check_2_38"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    echo "$pid_modes"
    warn "$check_2_38"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# IPC namespace must not be shared
check_2_39() {
  id_2_39="2.39"
  desc_2_39="IPC namespace must not be shared"
  check_2_39="$id_2_39  - $desc_2_39"
  starttestjson "$id_2_39" "$desc_2_39"

  totalChecks=$((totalChecks + 1))

  ## NOTE: this rule must apply on containers

  ipc_modes="$(docker ps -aq | xargs docker inspect -f '{{ Id }}:{{ .HostConfig.IpcMode }}'|grep host)"
  if [ -z "$ipc_modes" ]; then
    pass "$check_2_39"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    echo "$ipc_modes"
    warn "$check_2_39"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# Host UTS must not be shared
check_2_40() {
  id_2_40="2.40"
  desc_2_40="Host UTS must not be shared"
  check_2_40="$id_2_40  - $desc_2_40"
  starttestjson "$id_2_40" "$desc_2_40"

  totalChecks=$((totalChecks + 1))

  ## NOTE: this rule must apply on containers

  uts_modes="$(docker ps -aq | xargs docker inspect -f '{{ Id }}:{{ .HostConfig.IpcMode }}'|grep host)"
  if [ -z "$uts_modes" ]; then
    pass "$check_2_40"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    echo "$uts_modes"
    warn "$check_2_40"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# Devices must not be exposed to containers
check_2_41() {
  id_2_41="2.41"
  desc_2_41="Devices must not be exposed to containers"
  check_2_41="$id_2_41  - $desc_2_41"
  starttestjson "$id_2_41" "$desc_2_41"

  totalChecks=$((totalChecks + 1))

  ## NOTE: this rule must apply on containers

  devices="$(docker ps -q -a | xargs docker inspect --format '{{ .Id  }}:{{ .HostConfig.Devices  }}'|grep -qE '(\[]|<no value>)')"
  if [ -z "$devices" ]; then
    pass "$check_2_41"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    echo "$devices"
    warn "$check_2_41"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# Linked containers must use private networks to communicate
check_2_42() {
  id_2_42="2.42"
  desc_2_42="Linked containers must use private networks to communicate"
  check_2_42="$id_2_42  - $desc_2_42"
  starttestjson "$id_2_42" "$desc_2_42"

  totalChecks=$((totalChecks + 1))

  icc="$(docker network ls -q \
    | xargs docker network inspect -f '{{ .Name  }}: {{index .Options "com.docker.network.bridge.enable_icc"}}' \
    | grep -Ev '(:\ *$|false)')"
  if [ -z "$icc" ]; then
    pass "$check_2_42"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    echo "$icc"
    warn "$check_2_42"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# Mount propagation must not be set to shared
check_2_43() {
  id_2_43="2.43"
  desc_2_43="Mount propagation must not be set to shared"
  check_2_43="$id_2_43  - $desc_2_43"
  starttestjson "$id_2_43" "$desc_2_43"

  totalChecks=$((totalChecks + 1))

  ## NOTE: this rule must apply on containers

  mount_propagation="$(docker ps -qa \
    | xargs docker inspect -f '{{ .Id  }}:{{range $mnt := .Mounts}} {{json $mnt.Propagation}} {{end}}'|grep -Ev '(:\ *$|: "")')"
  if [ -z "$mount_propagation" ]; then
    pass "$check_2_43"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    echo "$mount_propagation"
    warn "$check_2_43"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# Exposed ports must be explicitly linked to a specific network interface (or IP)
check_2_44() {
  id_2_44="2.44"
  desc_2_44="Exposed ports must be explicitly linked to a specific network interface (or IP)"
  check_2_44="$id_2_44  - $desc_2_44"
  starttestjson "$id_2_44" "$desc_2_44"

  totalChecks=$((totalChecks + 1))

  ## NOTE: this rule must apply on containers

  unspecified_network="$(docker ps -qa | xargs docker inspect -f '{{ .Id }}: Ports={{ .NetworkSettings.Ports }}' | grep 'HostIp:0.0.0.0')"
  if [ -z "$unspecified_network" ]; then
    pass "$check_2_44"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    echo "$unspecified_network"
    warn "$check_2_44"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# Docker volumes must be used to provide data to containers
check_2_45() {
  id_2_45="2.45"
  desc_2_45="Docker volumes must be used to provide data to containers"
  check_2_45="$id_2_45  - $desc_2_45"
  starttestjson "$id_2_45" "$desc_2_45"

  totalChecks=$((totalChecks + 1))
  note "$check_2_45"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# Memory usage of containers should be limited
check_2_46() {
  id_2_46="2.46"
  desc_2_46="Memory usage of containers should be limited"
  check_2_46="$id_2_46  - $desc_2_46"
  starttestjson "$id_2_46" "$desc_2_46"

  totalChecks=$((totalChecks + 1))

  ## NOTE: this rule must apply on containers

  memory_usages="$(docker ps -qa | xargs docker inspect -f '{{ .Id  }}:{{ .HostConfig.Memory }}' | grep ':0$')"
  if [ -z "$memory_usages" ]; then
    pass "$check_2_46"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    echo "$memory_usages"
    warn "$check_2_46"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# CPU usage of containers should be limited
check_2_47() {
  id_2_47="2.47"
  desc_2_47="CPU usage of containers should be limited"
  check_2_47="$id_2_47  - $desc_2_47"
  starttestjson "$id_2_47" "$desc_2_47"

  totalChecks=$((totalChecks + 1))

  ## NOTE: this rule must apply on containers
  ## TODO: should check against max number of CPUs also
  #max_cpu=`nproc --all`
  cpu_usages="$(docker ps -qa | xargs docker inspect -f '{{ .Id  }}:{{ .HostConfig.CpuShares }}' | grep ':0$')"
  if [ -z "$cpu_usages" ]; then
    pass "$check_2_47"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    echo "$cpu_usages"
    warn "$check_2_47"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# Container's root filesystem must be read-only
check_2_48() {
  id_2_48="2.48"
  desc_2_48="Container's root filesystem must be read-only"
  check_2_48="$id_2_48  - $desc_2_48"
  starttestjson "$id_2_48" "$desc_2_48"

  totalChecks=$((totalChecks + 1))

  ## NOTE: this rule must apply on containers
  
  root_rw="$(docker ps -qa | xargs docker inspect -f '{{ .Id  }}:{{ .HostConfig.ReadonlyRootfs  }}'|grep false)"
  if [ -z "$root_rw" ]; then
    pass "$check_2_48"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    echo "$root_rw"
    warn "$check_2_48"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}


