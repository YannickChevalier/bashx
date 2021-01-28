#! /bin/bash
# Yannick Chevalier, January 2020
# For use in lab sessions only



# Receives requests on stdin
# Writes responses on stdout

function trim () {
    echo -n $(tr -d '\r\n' <<<$1)
}

function initialisation () {
    declare -g -A request
    declare -g -A response
    shopt -s extglob
    shopt -s nocasematch
}


function add_request_content() {
    local key="$1"
    local value="$2"
   if [ -z "${request[${key}]}" ]
    then
	request["${key}"]="${value}"
    else
	request["${key}"]="${request[${key}]};${value}"
    fi
    log "http_parser" "after: request[${key}] -> ${request[${key}]}" 
}

function request_to_string () {
    local key
    local res=""
    for key in "${!request[@]}"
    do
	res="${res}request[\"${key}\"]=\"${request[${key}]}\";"
    done
    # write_to_next with a blank line to finish
    log "request_to_string" "${res}"
    write_to_next "${res}"
    write_to_next ""
}

function read_http_request_line () {
    local line verb path
    local pattern='([^ ]+)[ ]+([^ ]+)[ ]+HTTP/1.1'
    read line 
    log "http_parser" "http_parser.sh [received]: ${line}"
   if [[ "${line}" =~ ${pattern} ]]
    then
	verb="${BASH_REMATCH[1]}"
	path="${BASH_REMATCH[2]}"
 	log "http_parser" "http_parser.sh [parsed]: ${verb} to  ${path}"
	add_request_content "verb" "${verb}"
	add_request_content "path" "${path}"
    fi
}

function cleanup () {
    :
}

function read_http_header_line () {
    # this function should be expanded to read multilines
    # header fields, i.e. if the next line begins with two spaces,
    # it belongs to the current line
    read $1
}

function read_header_field () {
    local line=$1
    local key
    local value
    key=${line%":"*}
    value=${line#*":"}
    add_request_content "${key}" "${value}"
}
function read_http_header () {
    local line
    while read_http_header_line line
    do
	log "read_http_header" "|${line}|"
	line=$(trim "${line}")
	if [[ "${line}" == "" ]] 
	then
	    log "read_http_header" "line was empty"
	    break
	else
	    read_header_field "${line}"
	fi
    done
    log "read_http_header" "header part finished after an empty line"
    if ( [[ "${request['verb']}" == "POST" ]] || \
	     [[ "${request['verb']}" == "PUT" ]] ) \
	   && [[ -z "${request['Content-Length']}" ]]
    then
	printf "HTTP/1.1 411 Content-Length Required\r\n\r\n" 
	printf "Date: $(date -R)\r\n" 
	printf "Content-Type: ${ContentType}\r\n"
	# find a way to abort the response
    else
	# It's the length given by $(wc -c ...) minus 2 (\r\n ?)
	if [[ ! -z "${request['Content-Length']}" ]]
	then
	    request['body']=$(head -c "${request['Content-Length']}" - )
	fi
    fi
    log "read_http_header" "query finished"
}


function request_forward_logic () {
    unset request[@]
    declare -A request
    read_http_request_line
    read_http_header
    request_to_string 
}

function application_state_logic () {
    :
}
function response_forward_logic () {
    local Code ContentType ContentLength Content
    log "response_forward_logic" "reading Code"
    read_line_from_next
    Code=${line_from_next}
    log "response_forward_logic" "Code is ${Code}"
    log "response_forward_logic" "reading length"
    read_line_from_next
    ContentLength=${line_from_next} 
    log "response_forward_logic" "Content-Length is ${ContentLength}"
    log "response_forward_logic" "reading type"
    read_line_from_next
    ContentType=${line_from_next}
    log "response_forward_logic" "Type is ${ContentType}"
    log "response_forward_logic" "reading content"
    log "response_forward_logic"  "IFS='' read -r -n ${ContentLength}  -u ${next_stage_out} Content"
     read -d '' -r -n ${ContentLength}  -u ${next_stage_out} Content
#    read_text_from_next ${ContentLength}
#    Content="${text_from_next}"
     log "response_forward_logic" "Content is ${Content::40}...${Content: -40}"
     Content=$(printf "%s" "${Content}")
     log "response_forward_logic" "real content length is ${#Content}"
    case ${Code} in
	# Only a few dozens of other codes to implement
	*)
	    printf "HTTP/1.1 ${Code} OK\r\n"  
	    log "response_forward_logic" "response: HTTP/1.1 ${Code} OK"  
	    printf "Content-Type: ${ContentType}\r\n" 
	    log "response_forward_logic" "response: Content-Type: ${ContentType}" 
	     printf "Date: $(date -R)\r\n" 
	    log "response_forward_logic" "response: Date: $(date -R)" 
	     printf "Content-Length: ${ContentLength}\r\n" 
	    log "response_forward_logic" "response: Content-Length: $((${ContentLength}))"
	     printf "\r\n" 
	    log "response_forward_logic" "response:   "  
	    printf "%s" "${Content}"
	    log "response_forward_logic" "response: ${Content::40}...${Content: -40}"  
	    log "response_forward_logic" "response sent"
	     ;;
    esac
}


do_stage $@
