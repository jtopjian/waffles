# == Name
#
# file_line
#
# === Description
#
# Manages single lines in a file.
#
# === Parameters
#
# * state: The state of the resource. Required. Default: present.
# * name: An arbitrary name for the resource. namevar.
# * line: The line to manage. Required.
# * file: The file that the line belongs to. Required.
# * match: A regex to match to. Optional.
#
# === Example
#
# stdlib.file_line --file /etc/memcached.conf \
#                  --line "-l 0.0.0.0" --match "^-l"
#
function stdlib.file_line {
  stdlib.subtitle "stdlib.file_line"

  local -A options
  stdlib.options.set_option state  "present"
  stdlib.options.set_option name   "__required__"
  stdlib.options.set_option line   "__required__"
  stdlib.options.set_option file   "__required__"
  stdlib.options.set_option match
  stdlib.options.parse_options "$@"

  stdlib.catalog.add "stdlib.file_line/${options[name]}"

  stdlib.file_line.read
  if [[ ${options[state]} == absent ]]; then
    if [[ $stdlib_current_state != absent ]]; then
      stdlib.info "${options[line]} state: $stdlib_current_state, should be absent."
      stdlib.file_line.delete
    fi
  else
    case "$stdlib_current_state" in
      absent)
        stdlib.info "${options[name]} state: absent, should be present."
        stdlib.file_line.create
        ;;
      present)
        stdlib.debug "${options[name]} state: present."
        ;;
      update)
        stdlib.info "${options[name]} state: out of date."
        stdlib.file_line.create
        ;;
    esac
  fi
}

function stdlib.file_line.read {
  if [[ ! -f ${options[file]} ]]; then
    stdlib_current_state="absent"
    return
  fi

  stdlib.debug_mute "grep -qx -- '${options[line]}' '${options[file]}'"
  if [[ $? == 1 ]]; then
    stdlib_current_state="absent"
    return
  fi

  if [[ -n ${options[match]} ]]; then
    stdlib.debug_mute "sed -n -e '/${options[match]}/p' '${options[file]}'"
    if [[ $? == 1 ]]; then
      stdlib.error "No match for ${options[match]} in ${options[file]}"
      if [[ $WAFFLES_EXIT_ON_ERROR == true ]]; then
        exit 1
      else
        return 1
      fi
    fi
  fi

  stdlib_current_state="present"
}

function stdlib.file_line.create {
  if [[ ! -f ${options[file]} ]]; then
    if [[ -n ${options[match]} ]]; then
      stdlib.warn "${options[file]} does not exist. Cannot match on an empty file. Proceeding without matching."
    fi
    stdlib.capture_error "echo '${options[line]}' > '${options[file]}'"
  else
    if [[ -n ${options[match]} ]]; then
      local _replacement=$(echo ${options[line]} | sed -e 's/[\/&]/\\&/g')
      stdlib.capture_error "sed -i -e '/${options[match]}/c ${_replacement}' '${options[file]}'"
    else
      local _replacement=$(echo ${options[line]} | sed -e 's/[\/&]/\\&/g')
      stdlib.capture_error "sed -i -e '\$a${_replacement}' '${options[file]}'"
    fi
  fi

  stdlib_state_change="true"
  stdlib_resource_change="true"
  let "stdlib_resource_changes++"
}

function stdlib.file_line.delete {
  local _replacement=$(echo ${options[line]} | sed -e 's/[\/&]/\\&/g')
  stdlib.capture_error "sed -i -e '/^${options[line]}$/d' '${options[file]}'"

  stdlib_state_change="true"
  stdlib_resource_change="true"
  let "stdlib_resource_changes++"
}
