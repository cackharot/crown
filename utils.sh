
remote_copy() {
    key=$1
    user='vagrant'
    host=$2
    src_file=$3
    dest_file=$4
    scp -q -i ${key} ${user}@${host}:${src_file} ${dest_file}
}

local_copy() {
    key=$1
    user='vagrant'
    host=$2
    src_file=$3
    dest_file=$4
    scp -q -i ${key} ${src_file} ${user}@${host}:${dest_file}
}

remote_exec() {
    key=$1
    user='vagrant'
    host=$2
    cmd=$3
    ssh -i ${key} ${user}@${host} "$cmd"
    #echo "======================================="
}

