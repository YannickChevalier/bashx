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
    local line result command 
    log "application_state_logic" "prepared to read command"
    read  command
    log "application_state_logic" "command |${line}| read"
    result="{ \"lines\": [ \"$ ${command}\" "
    while IFS= read line
    do
        result="${result} , \"${line}\" "
	log "application_state_logic" "read line \"${line}\""
    done < <(eval "${command}")
    log "application_state_logic" "command |${command}| evaluated"
    log "application_state_logic" "sending JSON output ${result}"
    printf "%s ] }\n" "${result}"
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
