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
    if  [ "${request["path"]}" == "/exec" ]
    then
	if [ -z "${request["command"]}" ]
	then
	    request["command"]="ls"
	fi
	write_to_next "${request["command"]}"
    fi
}
function application_state_logic () {
    log "application_state_logic" "doing nothing"
    :
}
function response_forward_logic () {
    local result
    local nb_lines
    local response_line output=""
    local filename
    if [ "${request["path"]}" == "/exec" ]
    then
	log "response_forward_logic" "reading command output"
	read_line_from_next
	result="${line_from_next}"
	log "response_forward_logic" "command output is \"${result}\""
	ContentType="application/json"
	ReturnCode="200"
	log "response_forward_logic" "file content: ${result}"
    else
	if  [ "${request["path"]}" == "/" ]
	then
	    filename="./index.html"
	else
	    filename=".${request["path"]}"
	fi
	if [ -e "${filename}" ]
	then
	    ReturnCode="200"
	    FileExtension=${filename##*.}
	    case ${FileExtension} in
		html )
		    ContentType="text/html; charset=utf-8"
		    result=$(< "${filename}" )
		    ;;
		ico | png )
		    ContentType="img/png;base64"
		    result=$(base64 "${filename}" )
		    ;;
		* )
		    ContentType="text/plain; charset=utf-8"
		    ;;
	    esac
	else
	    ReturnCode="404"
	    result=""
	    ContentType="text/plain"
	fi
    fi
	log "response_forward_logic" "file is ${filename}"
	log "response_forward_logic" "code is ${ReturnCode}"
	echo "${ReturnCode}"
	log "response_forward_logic" "response length is ${#result}"
	echo "${#result}"
	log "response_forward_logic" "document type is ${ContentType}"
	echo "${ContentType}"
	log "response_forward_logic" "file content: ${result::40}...${result:(-40)}"
	printf "%s" "${result}"
}

function cleanup () {
    :
}
do_stage $@
