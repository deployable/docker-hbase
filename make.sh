#!/bin/sh

set -ue

IMG_NAMESPACE=deployable
IMG_NAME=hbase
IMG_TAG=$IMG_NAMESPACE/$IMG_NAME
CONTAINER_NAME=hbase

rundir=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)")
canonical="$rundir/$(basename -- "$0")"

if [ -n "${1:-}" ]; then
  cmd=$1
  shift
else
  cmd=build
fi

cd "$rundir"

###

run_run(){
  docker run -p 9090:9090 -p 9095:9095 -p 2181:2181 -p 60000:60000 $IMG_TAG hbase
}


run_build(){
  build_args=${DOCKER_BUILD_ARGS:-}
  run_template hbase 8 1.3.1
  run_build_version hbase 8 1.4.1
  cp Dockerfile.8-1.4.1 Dockerfile
  docker build $build_args -f Dockerfile -t $IMG_TAG:latest .
}

run_build_version(){
  build_args=${DOCKER_BUILD_ARGS:-}
  build_apache_project_label=$1
  build_openjdk_version=$2
  build_hbase_version=$3
  build_version=$build_openjdk_version-$build_hbase_version
  run_template $build_apache_project_label $build_openjdk_version $build_hbase_version
  docker build $build_args -f Dockerfile.$build_version -t $IMG_TAG:$build_version .
}  

run_template(){
  template_apache_project_label=$1
  template_openjdk_version=$2
  template_apache_project_version=$3
  perl -pe 'BEGIN {
      $apache_project_label=shift @ARGV;
      $openjdk_version=shift @ARGV;
      $apache_project_version=shift @ARGV
    }
    s/{{\s*apache_project_label\s*}}/$apache_project_label/;
    s/{{\s*openjdk_version\s*}}/$openjdk_version/;
    s/{{\s*apache_project_version\s*}}/$apache_project_version/;
  ' $template_apache_project_label $template_openjdk_version $template_apache_project_version Dockerfile.template > Dockerfile.$template_openjdk_version-$template_apache_project_version
}

###

run_help(){
  echo "Commands:"
  awk '/  ".*"/{ print "  "substr($1,2,length($1)-3) }' make.sh
}

set -x

case $cmd in
  "build")     run_build "$@";;
  "template")  run_template "$@";;
  "run")       run_run "$@";;
  '-h'|'--help'|'h'|'help') run_help;;
esac

