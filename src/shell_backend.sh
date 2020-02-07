#! /bin/bash
# @ Yannick Chevalier, January 2020
# Only for use during lab sessions

function initialisation () {
    :
}

function request_forward_logic () {
    :
}
function application_state_logic () {
    local line result response_line
    log "application_state_logic" "prepared to read command"
    read  line
    log "application_state_logic" "command |${line}| read"
    IFS=$'\r\n' GLOBIGNORE='*' command eval 'result=( $( '${line}' ) )'
    log "application_state_logic" "command |${line}| evaluated"
    echo ${#result[@]}
    log "application_state_logic" "${#result[@]} lines in the response"
    for response_line in ${result[@]}
    do
	echo "${response_line}"
    done
    log "application_state_logic" "response transfered"
    :
}
function response_forward_logic () {
    :
}

function cleanup () {
    :
}
do_stage $@
