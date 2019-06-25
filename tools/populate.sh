#!/usr/bin/env bash

#out="tests/1_AB_host_os_and_docker_daemon.sh"
out=dbg_test.sh

section="`head -n1 notes`"

cat <<'EON'>"$out"
#!/bin/sh

check_1() {
  logit ""
  id_1="1"
EON
echo "  desc_1=\"$section\"" >> "$out"
cat <<'EON'>>"$out"
  check_1="$id_1 - $desc_1"
  info "$check_1"
  startsectionjson "$id_1" "$desc_1"
}
EON

old_IFS=$IFS
IFS=$'\n'
cnt=0
for l in `tail -n+2 notes`; do
    ((++cnt))
cat <<EON>>"$out"

# $l
check_1_$cnt() {
  id_1_$cnt="1.$cnt"
  desc_1_$cnt="$l"
  check_1_$cnt="\$id_1_$cnt  - \$desc_1_$cnt"
  starttestjson "\$id_1_$cnt" "\$desc_1_$cnt"

  totalChecks=\$((totalChecks + 1))

  resulttestjson "INFO"
  currentScore=\$((currentScore + 0))
}
EON

done

cat <<'EON'>>"$out"

check_1_end() {
  endsectionjson
}
EON
