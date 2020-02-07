#! /bin/bash
# @ Yannick Chevalier, January 2020
# Only for use during lab sessions

function initialisation () {
    declare -g fifo_file_in=$(mktemp -u)
    declare -g fifo_file_out=$(mktemp -u)
    declare -g fifo_fd_in
    declare -g fifo_fd_out
    declare -g fifo_out
    declare -g my_pid=$$
    declare -g waiting=""
    log "my pid" "${BASHPID} or $$"
    log "initialisation" "${fifo_file_in} -> ${fifo_file_out}"
    mkfifo ${fifo_file_in}
    mkfifo ${fifo_file_out}
    # ensure that fifos stay open 
    exec {fifo_fd_in}<>${fifo_file_in}
    exec {fifo_fd_out}<>${fifo_file_out}
    # launch the bash session
    log "initialisation" "starting bash session"
    1>${fifo_file_out} 2>&1 <${fifo_file_in} /bin/bash &
    log "initialisation" "done"
}


function request_forward_logic () {
    :
}
function application_state_logic () {
    read command_line
    local result_line
    declare -a -g result
    unset result
    local nb_lines=0
    log "a_s_l" "command line: |${command_line}|"
    log "sending command:" "${command_line} ; echo 'S3cur1t3 is C00|_'" 
    1>&${fifo_fd_in} echo "${command_line} ; echo 'S3cur1t3 is C00|_'" 
    while read -u ${fifo_fd_out} result_line
    do
	log "response processing" "received line |${result_line}|"
	if [[ "${result_line}" =~ "S3cur1t3 is C00|_" ]]
	then
	    break
	fi
	log "response processing" "line ${nb_lines} received"
	result["${nb_lines}"]="${result_line}"
	nb_lines=$((${nb_lines}+1))
    done
    log "response processing" "end of response reached"
    echo ${nb_lines}
    for result_line in ${result[@]}
    do
	echo ${result_line}
    done
}
function response_forward_logic () {
    :
}

function cleanup () {
    \rm  ${fifo_file_in}  ${fifo_file_out}
}
do_stage $@
