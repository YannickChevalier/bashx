#! /bin/bash
# @ Yannick Chevalier, January 2020
# Only for use during lab sessions

PORT=20080
IP="127.0.0.1"

# works, execution of one-line commands
# stages=(./http_parser.sh ./controleur.sh ./shell_backend.sh)

# works, communication with one terminal
stages=(./http_parser.sh ./controleur.sh ./shell_session.sh)

# TO DO: docker, communication with one terminal inside a docker
# container. One needs a docker Hub account.
# stages=(http_parser.sh controleur.sh docker_session.sh)



function read_from_previous () {
    read line_from_previous
    while [ -z "${line_from_previous}" ]
    do
	sleep 0.1
	read line_from_previous
    done
}
export -f read_from_previous


function read_text_from_next () {
    read -r -n $1  -u ${next_stage_out} text_from_next
}
export -f read_text_from_next

function read_line_from_next () {
    read -u ${next_stage_out} line_from_next
    while [ -z "${line_from_next}" ]
    do
	sleep 0.1
	read -u ${next_stage_out} line_from_next
    done
}
export -f read_line_from_next

function write_to_next () {
    1>&${next_stage_in} printf "%s\n" "${1}"
}
export -f write_to_next

function write_to_previous () {
    printf "${1}"
}
export -f write_to_previous

function log () {
    1>&2 echo "$0 [$1]: $2"
}
export -f log
function do_stage () { 
    trap cleanup EXIT
    declare -g next_stage_in next_stage_out fifo_in fifo_out
    if [[ $# -eq 2 ]]
    then
	exec {next_stage_in}>$1
	exec {next_stage_out}<$2
	fifo_out=$1
	fifo_in=$2
    else
	fifo_out=""
	fifo_in=""
    fi
    log "do_stage" "initialisation"
    initialisation
    log "do_stage" "entering loop"
    while true
    do
	log "do_stage" "request_forward_logic"
	request_forward_logic
	log "do_stage" "application_state_logic"
	application_state_logic
	log "do_stage" "response_forward_logic"
	response_forward_logic
	log "do_stage" "end query processing"
    done
    log "do_stage" "end of loop"
    cleanup
}
export -f do_stage
function make_fifo () {
    local name
    name=$(mktemp -u)
    mkfifo ${name}
    echo ${name}
}

declare -g all_fifos=""
declare -g -a pids
declare -g nb_pids=0

function stages_cleanup () {
    for pid in ${pids[@]}
    do
	kill ${pid}
	wait ${pid}
    done
    \rm -f ${all_fifos}
    if [ ! -z "${server_fifo}" ]
    then
	\rm -f ${server_fifo}
    fi
    exit 0 
}

for stage in $(seq $((${#stages[@]})) -1 1 )
do
    current_stage_in=$(make_fifo)
    current_stage_out=$(make_fifo)
    all_fifos="${all_fifos} ${current_stage_in} ${current_stage_out}"
    ${stages[${stage}]} ${next_stage_in} ${next_stage_out} <${current_stage_in} >${current_stage_out} &
    pids[${nb_pid}]=$!
    nb_pid=$(( ${nb_pid} + 1 ))
    next_stage_in="${current_stage_in}"
    next_stage_out="${current_stage_out}"
done


trap stages_cleanup EXIT


optstring=":hlp:i:"
utilise_port="oui"

while getopts ${optstring} arg; do
  case ${arg} in
    h)
	echo "$0 [-l] [-h]"
	echo "    -h  montre l'aide"
	echo "    -l  le serveur attend les requêtes sur son entrée standard"
	echo "    -p port sur lequel le serveur écoute, par défaut 80"
	echo "    -i adresse IP sur laquelle le serveur écoute, par défaut ${HOSTNAME}"
	exit 0
      ;;
    l)
	utilise_port=""
        ;;
    p)
	PORT="${OPTARG}"
	;;
    i)
	IP="${OPTARG}"
	;;
    ?)
      echo "mauvaise option: -${OPTARG}."
      exit 2
      ;;
  esac
done
 
if [ -z "${utilise_port}" ]
then
    ${stages[0]} ${next_stage_in} ${next_stage_out}
else
    declare -g server_fifo
    server_fifo=$(mktemp -u )
    mkfifo ${server_fifo}
    cat ${server_fifo} | \
	${stages[0]} ${next_stage_in} ${next_stage_out} | \
	nc  -k -l "${IP}" "${PORT}" > \
           ${server_fifo}
    \rm ${server_fifo}
fi
exit 0
