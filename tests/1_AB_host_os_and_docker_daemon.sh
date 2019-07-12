#!/bin/sh

## TODO: convert to bash !
## TODO: to execute tests on containers, embed hello-world as a tar archive and, if no container is running, import it locally, if it doesn't exist; other solution: check if alpine is available and start it with an "echo" command.

check_1() {
  logit ""
  id_1="1"
  desc_1="Host/OS and Docker Daemon"
  check_1="$id_1 - $desc_1"
  info "$check_1"
  startsectionjson "$id_1" "$desc_1"
}

# SELinux security policy for Docker must be enabled
check_1_1() {
  id_1_1="1.1"
  desc_1_1="SELinux security policy for Docker must be enabled"
  check_1_1="$id_1_1  - $desc_1_1"
  starttestjson "$id_1_1" "$desc_1_1"

  totalChecks=$((totalChecks + 1))

  if ps -eZ | grep -q container_runtime_t; then
    pass "$check_1_1"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_1"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi

  ## TODO: --selinux-enabled could be checked in running daemon... This is the default since CentOS 7.4.1708
  ## docker info | grep 'Security Options' should return 'selinux', along with other possible options
  ## @see: http://jaormx.github.io/2018/selinux-and-docker-notes/
}

# Docker resources should be hosted on a dedicated partition or disk
check_1_2() {
  id_1_2="1.2"
  desc_1_2="Docker resources should be hosted on a dedicated partition or disk"
  check_1_2="$id_1_2  - $desc_1_2"
  starttestjson "$id_1_2" "$desc_1_2"

  totalChecks=$((totalChecks + 1))

  if mountpoint -q -- "$(docker info -f '{{ .DockerRootDir }}')" >/dev/null 2>&1; then
    pass "$check_1_2"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_2"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# Docker data volume should be encrypted
check_1_3() {
  id_1_3="1.3"
  desc_1_3="Docker data volume should be encrypted"
  check_1_3="$id_1_3  - $desc_1_3"
  starttestjson "$id_1_3" "$desc_1_3"

  totalChecks=$((totalChecks + 1))
  ## get docker partition
  docker_root_dir=`docker info -f '{{ .DockerRootDir  }}'`
  docker_dev=`df $docker_root_dir | awk '/^\/dev/ {print $1}'`
  if blkid -p -n crypto_LUKS $docker_dev | grep -q TYPE="crypto_LUKS"; then
    pass "$check_1_3"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_3"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# Firewall rules must limit access to public services
check_1_4() {
  id_1_4="1.4"
  desc_1_4="Firewall rules must limit access to public services"
  check_1_4="$id_1_4  - $desc_1_4"
  starttestjson "$id_1_4" "$desc_1_4"

  totalChecks=$((totalChecks + 1))
  note "$check_1_4"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# Trusted users to manage Docker images and containers must be used
check_1_5() {
  id_1_5="1.5"
  desc_1_5="Trusted users to manage Docker images and containers must be used"
  check_1_5="$id_1_5  - $desc_1_5"
  starttestjson "$id_1_5" "$desc_1_5"

  totalChecks=$((totalChecks + 1))
  docker_users=$(getent group docker)
  info "$check_1_5"
  for u in $docker_users; do
    info "     * $u"
  done
  resulttestjson "INFO" "users" "$docker_users"
  currentScore=$((currentScore + 0))
}

# Insecure registries must not be allowed in production
check_1_6() {
  id_1_6="1.6"
  desc_1_6="Insecure registries must not be allowed in production"
  check_1_6="$id_1_6  - $desc_1_6"
  starttestjson "$id_1_6" "$desc_1_6"

  totalChecks=$((totalChecks + 1))
  insecure=$(docker info --format '{{ .RegistryConfig.InsecureRegistryCIDRs  }}' | grep -v '[127.0.0.0/8]')
  if [ -z "$insecure" ]; then
    pass "$check_1_6"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_6"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# Only trusted images should be used
check_1_7() {
  id_1_7="1.7"
  desc_1_7="Only trusted images should be used"
  check_1_7="$id_1_7  - $desc_1_7"
  starttestjson "$id_1_7" "$desc_1_7"

  totalChecks=$((totalChecks + 1))
  if grep -q 'content-trust' /etc/docker/daemon.conf && grep -Eq '"mode"\ *:\*(enforced|permissive)'; then
    pass "$check_1_7"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_7"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# Docker logs must be centralised
check_1_8() {
  id_1_8="1.8"
  desc_1_8="Docker logs must be centralised"
  check_1_8="$id_1_8  - $desc_1_8"
  starttestjson "$id_1_8" "$desc_1_8"

  totalChecks=$((totalChecks + 1))
  log_driver=$(docker info -f '{{ .LoggingDriver }}')
  if [ "$log_driver" -eq syslog ]; then
    pass "$check_1_8"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_8"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# Debug logs must not be used in production
check_1_9() {
  id_1_9="1.9"
  desc_1_9="Debug logs must not be used in production"
  check_1_9="$id_1_9  - $desc_1_9"
  starttestjson "$id_1_9" "$desc_1_9"

  totalChecks=$((totalChecks + 1))
  debug_mode=$(docker info -f '{{ .Debug }}'|grep -q 'false')
  log_mode=$(grep '"log-level"' /etc/docker/daemon.json | grep 'debug')
  log_opt=$(\ps -ef | grep dockerd | grep -E '(-l|--log-level)' | grep 'debug')
  log_client_opt=$(docker info | grep 'Debug Mode (client)'|grep 'debug')
  if [ -z "$debug_mode" ] && [ -z "$log_mode" ] && [ -z "$log_opt" ] && [ -z "$log_client_opt" ]; then
    pass "$check_1_9"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_9"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# Docker live-restore should be enabled
check_1_10() {
  id_1_10="1.10"
  desc_1_10="Docker live-restore should be enabled"
  check_1_10="$id_1_10  - $desc_1_10"
  starttestjson "$id_1_10" "$desc_1_10"

  totalChecks=$((totalChecks + 1))
  if docker info --format '{{ .LiveRestoreEnabled  }}'|grep -q 'true'; then
    pass "$check_1_10"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_10"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# ulimit must be set with a default value for Docker
check_1_11() {
  id_1_11="1.11"
  desc_1_11="ulimit must be set with a default value for Docker"
  check_1_11="$id_1_11  - $desc_1_11"
  starttestjson "$id_1_11" "$desc_1_11"

  totalChecks=$((totalChecks + 1))
  if grep -q '"Name"\ *:\ *"nofile"' /etc/docker/daemon.json; then
    pass "$check_1_11"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_11"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# aufs storage driver must not be used for Docker
check_1_12() {
  id_1_12="1.12"
  desc_1_12="aufs storage driver must not be used for Docker"
  check_1_12="$id_1_12  - $desc_1_12"
  starttestjson "$id_1_12" "$desc_1_12"

  totalChecks=$((totalChecks + 1))

  if ! docker info -f '{{ .Driver }}' | grep -eq '^aufs$'; then
    pass "$check_1_12"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_12"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# root in container should be mapped to a non uid-0 user on host
check_1_13() {
  id_1_13="1.13"
  desc_1_13="root in container should be mapped to a non uid-0 user on host"
  check_1_13="$id_1_13  - $desc_1_13"
  starttestjson "$id_1_13" "$desc_1_13"

  totalChecks=$((totalChecks + 1))

  if docker info -f '{{ .SecurityOptions }}' | grep -q userns; then
    pass "$check_1_13"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_13"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# Privileged containers must be avoided
check_1_14() {
  id_1_14="1.14"
  desc_1_14="Privileged containers must be avoided"
  check_1_14="$id_1_14  - $desc_1_14"
  starttestjson "$id_1_14" "$desc_1_14"

  totalChecks=$((totalChecks + 1))

  ## NOTE: this rule must apply on containers

  privileged="$(docker ps -aq | xargs docker inspect -f '{{ Id }}:{{ .HostConfig.Privileged }}'|xargs)"
  if [ -z "$privileged" ]; then
    pass "$check_1_14"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_14"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# New privileges should not be allowed for containers
check_1_15() {
  id_1_15="1.15"
  desc_1_15="New privileges should not be allowed for containers"
  check_1_15="$id_1_15  - $desc_1_15"
  starttestjson "$id_1_15" "$desc_1_15"

  totalChecks=$((totalChecks + 1))

  if grep -q '"no-new-privileges"\ *:\ *true' /etc/docker/daemon.json; then
    pass "$check_1_15"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_15"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}


# /var/lib/docker should be audited
check_1_16() {
  id_1_16="1.6"
  desc_1_16="/var/lib/docker should be audited"
  check_1_16="$id_1_16  - $desc_1_16"
  starttestjson "$id_1_16" "$desc_1_16"

  totalChecks=$((totalChecks + 1))

  #directory="/var/lib/docker"
  directory=`docker info -f '{{ .DockerRootDir  }}'`
  if [ -d "$directory" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $directory >/dev/null 2>&1; then
        pass "$check_1_16"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_16"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$directory" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_16"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_16"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_16"
    info "     * Directory not found"
    resulttestjson "INFO" "Directory not found"
    currentScore=$((currentScore + 0))
  fi

}

# /usr/bin/docker should be audited
check_1_17() {
  id_1_17="1.17"
  desc_1_17="/usr/bin/docker should be audited"
  check_1_17="$id_1_17  - $desc_1_17"
  starttestjson "$id_1_17" "$desc_1_17"

  totalChecks=$((totalChecks + 1))
  file="/usr/bin/docker "
  if command -v auditctl >/dev/null 2>&1; then
    if auditctl -l | grep "$file" >/dev/null 2>&1; then
      pass "$check_1_17"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_17"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
    pass "$check_1_17"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_17"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# /etc/docker should be audited
check_1_18() {
  id_1_18="1.18"
  desc_1_18="/etc/docker should be audited"
  check_1_18="$id_1_18  - $desc_1_18"
  starttestjson "$id_1_18" "$desc_1_18"

  totalChecks=$((totalChecks + 1))
  if [ -d "$directory" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $directory >/dev/null 2>&1; then
        pass "$check_1_18"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_18"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$directory" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_18"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_7"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_18"
    info "     * Directory not found"
    resulttestjson "INFO" "Directory not found"
    currentScore=$((currentScore + 0))
  fi
}

# /etc/default/docker should be audited
check_1_19() {
  id_1_19="1.19"
  desc_1_19="/etc/default/docker should be audited"
  check_1_19="$id_1_19  - $desc_1_19"
  starttestjson "$id_1_19" "$desc_1_19"

  totalChecks=$((totalChecks + 1))
  file="/etc/default/docker"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check_1_19"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_19"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_19"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_19"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_19"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# /etc/docker/daemon.json should be audited
check_1_20() {
  id_1_20="1.20"
  desc_1_20="/etc/docker/daemon.json should be audited"
  check_1_20="$id_1_20  - $desc_1_20"
  starttestjson "$id_1_20" "$desc_1_20"

  totalChecks=$((totalChecks + 1))
  file="/etc/docker/daemon.json"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check_1_20"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_20"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_20"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_20"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_20"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# /usr/bin/docker-containerd should be audited
check_1_21() {
  id_1_21="1.21"
  desc_1_21="/usr/bin/docker-containerd should be audited"
  check_1_21="$id_1_21  - $desc_1_21"
  starttestjson "$id_1_21" "$desc_1_21"

  totalChecks=$((totalChecks + 1))
  file="/usr/bin/docker-containerd"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check_1_21"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_21"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_21"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_21"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_21"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# /usr/bin/docker-runc should be audited
check_1_22() {
  id_1_22="1.22"
  desc_1_22="/usr/bin/docker-runc should be audited"
  check_1_22="$id_1_22  - $desc_1_22"
  starttestjson "$id_1_22" "$desc_1_22"

  totalChecks=$((totalChecks + 1))
  file="/usr/bin/docker-runc"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check_1_22"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_22"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_22"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_22"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_22"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# docker.service should be audited
check_1_23() {
  id_1_23="1.23"
  desc_1_23="docker.service should be audited"
  check_1_23="$id_1_23  - $desc_1_23"
  starttestjson "$id_1_23" "$desc_1_23"

  totalChecks=$((totalChecks + 1))
  file="$(get_systemd_service_file docker.service)"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep "$file" >/dev/null 2>&1; then
        pass "$check_1_23"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_23"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_23"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_23"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_23"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# docker.socket should be audited
check_1_24() {
  id_1_24="1.24"
  desc_1_24="docker.socket should be audited"
  check_1_24="$id_1_24  - $desc_1_24"
  starttestjson "$id_1_24" "$desc_1_24"

  totalChecks=$((totalChecks + 1))
  file="$(get_systemd_service_file docker.socket)"
  if [ -e "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep "$file" >/dev/null 2>&1; then
        pass "$check_1_24"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_24"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_24"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_24"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_24"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# Access to Docker service must be restricted
check_1_25() {
  id_1_25="1.25"
  desc_1_25="Access to Docker service must be restricted"
  check_1_25="$id_1_25  - $desc_1_25"
  starttestjson "$id_1_25" "$desc_1_25"

  totalChecks=$((totalChecks + 1))

  file="$(get_systemd_service_file docker.service)"
  if [ -f "$file" ]; then
    if stat -c %U:%G "$file" | grep -q 'root:root' && stat -c %s "$file" | grep -q 640; then
      pass "$check_1_25"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_25"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_25"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# Access to Docker socket must be restricted
check_1_26() {
  id_1_26="1.26"
  desc_1_26="Access to Docker socket must be restricted"
  check_1_26="$id_1_26  - $desc_1_26"
  starttestjson "$id_1_26" "$desc_1_26"

  totalChecks=$((totalChecks + 1))

  file="$(get_systemd_service_file docker.service)"
  if [ -f "$file" ]; then
    if stat -c %U:%G "$file" | grep -q 'root:root' && stat -c %s "$file" | grep -q 640; then
      pass "$check_1_26"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_26"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_26"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# Access to /etc/docker socket must be restricted
check_1_27() {
  id_1_27="1.27"
  desc_1_27="Access to /etc/docker socket must be restricted"
  check_1_27="$id_1_27  - $desc_1_27"
  starttestjson "$id_1_27" "$desc_1_27"

  totalChecks=$((totalChecks + 1))

  dir="/etc/docker"
  if [ -d "$dir" ]; then
    if stat -c %U:%G "$dir" | grep -q 'root:root' && stat -c %s "$dir" | grep -q 640; then
      pass "$check_1_27"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_27"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_27"
    info "     * Directory not found"
    resulttestjson "INFO" "Directory not found"
    currentScore=$((currentScore + 0))
  fi
}

# Access to /etc/docker/daemon.json socket must be restricted
check_1_28() {
  id_1_28="1.28"
  desc_1_28="Access to /etc/docker/daemon.json socket must be restricted"
  check_1_28="$id_1_28  - $desc_1_28"
  starttestjson "$id_1_28" "$desc_1_28"

  file="/etc/docker/daemon.json"
  if [ -f "$file" ]; then
    if stat -c %U:%G "$file" | grep -q 'root:root' && stat -c %s "$file" | grep -q 640; then
      pass "$check_1_28"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_28"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_28"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# Access to /etc/default/docker socket must be restricted
check_1_29() {
  id_1_29="1.29"
  desc_1_29="Access to /etc/default/docker socket must be restricted"
  check_1_29="$id_1_29  - $desc_1_29"
  starttestjson "$id_1_29" "$desc_1_29"

  file="/etc/default/docker"
  if [ -f "$file" ]; then
    if stat -c %U:%G "$file" | grep -q 'root:root' && stat -c %s "$file" | grep -q 640; then
      pass "$check_1_29"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_29"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_29"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# Access to /etc/docker/certs.d/*/* socket must be restricted
check_1_30() {
  id_1_30="1.30"
  desc_1_30="Access to /etc/docker/certs.d/*/* socket must be restricted"
  check_1_30="$id_1_30  - $desc_1_30"
  starttestjson "$id_1_30" "$desc_1_30"

  dir="/etc/docker/certs.d"
  if [ -d "$dir" ]; then
    if ! stat -c %U:%G $dir/*/* | grep -v 'root:root' | grep -q ':' && stat -Lc %s $dir/*/* | grep -q 640; then
      pass "$check_1_30"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_30"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_30"
    info "     * Directory not found"
    resulttestjson "INFO" "Directory not found"
    currentScore=$((currentScore + 0))
  fi
}

# Access to /var/run/docker.sock must be restricted
check_1_31() {
  id_1_31="1.31"
  desc_1_31="Access to /var/run/docker.sock must be restricted"
  check_1_31="$id_1_31  - $desc_1_31"
  starttestjson "$id_1_31" "$desc_1_31"

  file="/var/run/docker.sock"
  if [ -f "$file" ]; then
    if stat -c %U:%G "$file" | grep -q 'root:root' && stat -c %s "$file" | grep -q 640; then
      pass "$check_1_31"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_31"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_31"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

check_1_end() {
  endsectionjson
}
