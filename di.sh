#!/bin/bash

# ------------------------------------------------------------------------------
dish_help() {
  cat <<EOF

  Usage:
    di.sh build|run DEF[:RELEASE]

  Where
    build   - build docker image with def/DEF definition file
    run     - run docker container for image $TAGPREFIX/$DEF[:RELEASE]

    DEF     - name of definition file (from def/ dir)
    RELEASE - image version id, default: latest

EOF
}

# ------------------------------------------------------------------------------

# Run image build script
# Called as:
#  run_build $tag

dish_build() {
  local tag=$1
  shift
  local def=${tag%:*} # remove rel
  local rel=${tag#*:} # remove def
  [[ "$def" == "$rel" ]] && rel=""

  [ -d $TMP_DIR ] || mkdir -p $TMP_DIR

  local prefix=$TMP_DIR/dish-$$
  local cid_file=$prefix.cid
  local port_file=$prefix.ports
  [ -f $cid_file ] && rm -f $cid_file
  [ -f $USER_PUB_KEYS ] && cp -L $USER_PUB_KEYS $prefix.keys

  sudo docker run -i \
    -v $PWD:$APP_ROOT \
    -w $APP_ROOT \
    -dns $DNS \
    -cidfile=$cid_file \
    $BASE_IMAGE:$BASE_TAG /bin/bash build.dish $def $prefix $CONT_CMD || { echo "Build failed. Exiting." ; exit 1 ; }

  [ -f $cid_file ] || {
    echo "No cidfile, aborting"
    exit 1
  }

  local cid=$(cat $cid_file)
  echo "Wait for docker stop"
  rv=$(sudo docker wait $cid)
  [[ "$rv" == "0" ]] || { echo "Build stop failed. Exiting." ; exit ; }

  # Get ports
  local ports=""
  [ -e $port_file ] && {
    while read line ; do
      [[ "$ports" == "" ]] || ports="$ports, "
      ports="$ports\"$line\""
    done < $port_file
  }
  [[ "$ports" ]] && {
    echo "Container ports: $ports"
    ports=', "PortSpecs" : ['$ports']'
  }

  [[ "$rel" ]] || rel=latest
  echo "commit of $cid with $def:$rel, cmd $@ "
  cid=$(sudo docker commit -author="$MAINTAINER" \
    -run="{\"Hostname\" : \"$def\", \"Entrypoint\" : [\"/di.sh\"], \"WorkingDir\" : \"$APP_ROOT\"$ports}" \
    $cid $TAGPREFIX/$def $rel)
  [[ "$rel" == "latest" ]] || sudo docker tag -f $cid $TAGPREFIX/$def

  rm -f $prefix.*
  [ -f "$TMP_DIR/*" ] || rmdir $TMP_DIR

}

# ------------------------------------------------------------------------------

dish_run() {
  local tag=$1
  shift

  local def=${tag%:*} # remove rel
  local rel=${tag#*:} # remove def
  [[ "$def" == "$rel" ]] && rel=""
  [[ "$rel" ]] && rel="-${rel/./_}"
  sudo docker run -i -t \
    -h "$def$rel" \
    -v $PWD:$APP_ROOT \
    -dns $DNS \
    $@ $TAGPREFIX/$tag
}

# ------------------------------------------------------------------------------

cmd=$1
shift

DISH_ROOT=$(dirname $(readlink -f $0))

# ------------------------------------------------------------------------------

# get config
if [ -f config.dish ] ; then
  . config.dish
elif [ -f $DISH_ROOT/config.dish ] ; then
  . $DISH_ROOT/config.dish
elif [ -f $DISH_ROOT/config.dish.default ] ; then
  . $DISH_ROOT/config.dish.default
else
  echo "Error: config file not found"
  exit 1
fi

# ------------------------------------------------------------------------------

case "$cmd" in
  build)
    dish_build $@
    ;;
  run)
    dish_run $@
    ;;
  *)
    dish_help
    ;;
esac
