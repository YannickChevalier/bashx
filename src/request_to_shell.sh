#! /bin/bash

function initialisation () {
    declare -A -g request
    declare -a -g response
    :
}

function request_forward_logic () {
    local line="a"
    local query=""
    unset request[@]
    declare -A -g request
    log "request_forward_logic" "start"
    while [[ ! -z "${line}" ]]
    do
	read line
	log "request_forward_logic" "|${line}|"
	query="${query}${line}
"
    done
    log "application_state_logic" "evaluation of the query |${query}|"
    eval ${query}
    write_to_next "${request["command"]}"
}
function application_state_logic () {
    log "application_state_logic" "doing nothing"
    :
}
function response_forward_logic () {
    local result=()
    local nb_lines
    local response_line output=""
    #   request["command"]="ls"
    read_from_next
    nb_lines=${line_from_next}
    result=( $(head -n ${nb_lines} - <&${next_stage_out}) ) 
    for response_line in ${result[@]}
    do
	output="${output}<br>${response_line}"
    done
    result="<html><body>&dollar; ${request["command"]}<br>"
    result="${result}${output}</body></html>"
    log "response_forward_logic" "200"
    echo "200"
    log "response_forward_logic" "${#result}"
    echo "${#result}"
    log "response_forward_logic" "text/html"
    echo "text/html"
    log "response_forward_logic" "${result}"
    echo "${result}"
}

function cleanup () {
    :
}
do_stage $@
