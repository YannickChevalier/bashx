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
    declare -g users=""
    declare -g user=""
    log "initialisation" "trying to find normal user"
    users=($(ls /home/))
    if [[ ${#users[*]} -eq 1 ]]
    then
	user=${users[0]}
    fi
    log "my pid" "${BASHPID} or $$"
    log "initialisation" "${fifo_file_in} -> ${fifo_file_out}"
    mkfifo ${fifo_file_in}
    mkfifo ${fifo_file_out}
    # ensure that fifos stay open 
    exec {fifo_fd_in}<>${fifo_file_in}
    exec {fifo_fd_out}<>${fifo_file_out}
    # launch the bash session
    log "initialisation" "starting bash session"
    if [ -z "${user}" ]
    then
	log "initialisation" "starting subshell as root"
	1>${fifo_file_out} 2>&1 <${fifo_file_in} /bin/bash &
    else
	if [ ! -x "/usr/bin/sudo" ] ; then
	    apt install sudo
	fi
	log "initialisation" "starting subshell as ${user}"
	1>${fifo_file_out} 2>&1 <${fifo_file_in} sudo -u titi /bin/bash &
    fi
    log "initialisation" "done"
}


function request_forward_logic () {
    :
}
function application_state_logic () {
    local line
    declare -a -g result
    local command
    local result
    local nb_lines=0
    
    read command
    log "application_state_logic" "command line: |${command}|"
    result="{ \"lines\": [ \"$ ${command}\" "
    log "application_state_logic" "sending command: \"${command_line} ; echo 'S3cur1t3 is C00|_'\"" 
    1>&${fifo_fd_in} echo "${command} ; echo 'S3cur1t3 is C00|_'" 
    while read -u ${fifo_fd_out} line
    do
	log "application_state_logic" "read line |${line}|"
	if [[ "${line}" =~ "S3cur1t3 is C00|_" ]]
	then
	    log "application_state_logic" "detected end of output"
	    break
	fi
	result="${result} , \"${line}\" "
    done
    log "application_state_logic" "sending JSON output ${result}"
    printf "%s ] }\n" "${result}"
    log "application_state_logic" "response transfered"
}
function response_forward_logic () {
    :
}

function cleanup () {
    \rm  ${fifo_file_in}  ${fifo_file_out}
}
do_stage $@
