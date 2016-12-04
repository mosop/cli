declare -a _ticket_to_ride__keys
_ticket_to_ride__keys[0]=' --by '
_ticket_to_ride__keys[1]=' for '

declare -a _ticket_to_ride__lens
_ticket_to_ride__lens[0]=2
_ticket_to_ride__lens[1]=1

declare -ia _ticket_to_ride__occurs
_ticket_to_ride__occurs[0]=1
_ticket_to_ride__occurs[1]=1

declare -a _ticket_to_ride__words
_ticket_to_ride__words[0]=' train plane taxi '
_ticket_to_ride__words[1]=' kyoto kanazawa kamakura '

declare -a _ticket_to_ride__cmds
_ticket_to_ride__cmds[0]=''
_ticket_to_ride__cmds[1]=''

declare -a _ticket_to_ride__nexts

declare -ia _ticket_to_ride__args
_ticket_to_ride__args[0]=1

declare -a _ticket_to_ride__tags
_ticket_to_ride__tags[0]=' opt '
_ticket_to_ride__tags[1]=' arg '

function _ticket_to_ride__add() {
  if _ticket_to_ride__keyerr; then return 1; fi
  local n=${_ticket_to_ride__f[$_ticket_to_ride__k]}
  if [[ "$n" == "" ]]; then
    n=1
  else
    let n+=1
  fi
  _ticket_to_ride__f[$_ticket_to_ride__k]=$n
  return 0
}

function _ticket_to_ride__any() {
  _ticket_to_ride__cur
  COMPREPLY=( $(compgen -o default -- "${_ticket_to_ride__c}") )
  return 0
}

function _ticket_to_ride__cur() {
  _ticket_to_ride__c="${COMP_WORDS[COMP_CWORD]}"
  return 0
}

function _ticket_to_ride__end() {
  if [ $_ticket_to_ride__i -eq $COMP_CWORD ]; then
    return 0
  fi
  return 1
}

function _ticket_to_ride__inc() {
  let _ticket_to_ride__i+=1
  return 0
}

function _ticket_to_ride__keyerr() {
  if [[ "$_ticket_to_ride__k" == "" ]] || [ $_ticket_to_ride__k -lt 0 ]; then
    return 0
  fi
  return 1
}

function _ticket_to_ride__word() {
  _ticket_to_ride__w="${COMP_WORDS[$_ticket_to_ride__i]}"
  return 0
}

function _ticket_to_ride__arg() {
  if [ $_ticket_to_ride__ai -lt ${#_ticket_to_ride__args[@]} ]; then
    _ticket_to_ride__k=${_ticket_to_ride__args[$_ticket_to_ride__ai]}
    if ! _ticket_to_ride__tag varg; then
      let _ticket_to_ride__ai+=1
    fi
    return 0
  fi
  return 1
}

function _ticket_to_ride__key() {
  local i=0
  while [ $i -lt ${#_ticket_to_ride__keys[@]} ]; do
    if [[ ${_ticket_to_ride__keys[$i]} == *' '$_ticket_to_ride__w' '* ]]; then
      _ticket_to_ride__k=$i
      return 0
    fi
    let i+=1
  done
  _ticket_to_ride__k=-1
  return 1
}

function _ticket_to_ride__len() {
  if _ticket_to_ride__keyerr; then return 1; fi
  _ticket_to_ride__l=${_ticket_to_ride__lens[$_ticket_to_ride__k]}
  return 0
}

function _ticket_to_ride__ls() {
  _ticket_to_ride__cur
  local a=()
  local i=0
  local cmd
  local arg
  if [[ "$_ticket_to_ride__w" =~ ^- ]]; then
    while [ $i -lt ${#_ticket_to_ride__keys[@]} ]; do
      if _ticket_to_ride__tag arg $i; then
        let i+=1
        continue
      fi
      local found=${_ticket_to_ride__f[$i]}
      if [[ "$found" == "" ]]; then
        found=0
      fi
      local max=${_ticket_to_ride__occurs[$i]}
      if [ $max -lt 0 ] || [ $found -lt $max ]; then
        a+=(${_ticket_to_ride__keys[$i]})
      fi
      let i+=1
    done
  else
    if [ $_ticket_to_ride__ai -lt ${#_ticket_to_ride__args[@]} ]; then
      arg=${_ticket_to_ride__args[$_ticket_to_ride__ai]}
      cmd=${_ticket_to_ride__cmds[$arg]}
      if [[ "$cmd" == "" ]]; then
        a=(${_ticket_to_ride__words[$arg]})
      else
        a=($($cmd))
      fi
    fi
  fi
  if [ ${#a[@]} -gt 0 ]; then
    COMPREPLY=( $(compgen -W "$(echo ${a[@]})" -- "$_ticket_to_ride__c") )
  else
    COMPREPLY=( $(compgen -o default -- "$_ticket_to_ride__c") )
  fi
  return 0
}

function _ticket_to_ride__lskey() {
  if _ticket_to_ride__keyerr; then return 1; fi
  local a=(${_ticket_to_ride__words[$_ticket_to_ride__k]})
  if [ ${#a[@]} -gt 0 ]; then
    _ticket_to_ride__cur
    COMPREPLY=( $(compgen -W "$(echo ${a[@]})" -- "$_ticket_to_ride__c") )
    return 0
  fi
  _ticket_to_ride__any
  return $?
}

function _ticket_to_ride__reply() {
  _ticket_to_ride__i=1
  _ticket_to_ride__k=-1
  _ticket_to_ride__ai=0
  _ticket_to_ride__f=()
  while ! _ticket_to_ride__tag stop; do
    _ticket_to_ride__word
    _ticket_to_ride__key
    if _ticket_to_ride__tag term; then
      _ticket_to_ride__inc
      break
    fi
    if _ticket_to_ride__end; then
      _ticket_to_ride__ls
      return $?
    fi
    if [[ $_ticket_to_ride__w =~ ^- ]]; then
      if [ $_ticket_to_ride__k -eq -1 ]; then
        _ticket_to_ride__any
        return $?
      fi
      _ticket_to_ride__len
      if [ $_ticket_to_ride__l -eq 1 ]; then
        _ticket_to_ride__add
        _ticket_to_ride__inc
        continue
      fi
      _ticket_to_ride__inc
      if _ticket_to_ride__end; then
        _ticket_to_ride__lskey
        return $?
      fi
      _ticket_to_ride__add
    else
      if _ticket_to_ride__arg; then
        _ticket_to_ride__inc
        if [[ ${_ticket_to_ride__nexts[$_ticket_to_ride__k]} != "" ]]; then
          _ticket_to_ride__next
          return $?
        fi
      else
        _ticket_to_ride__inc
      fi
    fi
  done
  _ticket_to_ride__any
  return $?
}

function _ticket_to_ride__tag() {
  local k
  if [[ "$2" == "" ]]; then
    if _ticket_to_ride__keyerr; then return 1; fi
    k=$_ticket_to_ride__k
  else
    k=$2
  fi
  if [[ ${_ticket_to_ride__tags[$k]} == *' '$1' '* ]]; then
    return 0
  fi
  return 1
}

complete -F _ticket_to_ride__reply ticket-to-ride
