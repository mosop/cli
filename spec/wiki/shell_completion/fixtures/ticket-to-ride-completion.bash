_ticket_to_ride___keys=(' --by ' ' for ')
_ticket_to_ride___args=(1 )
_ticket_to_ride___acts=('' '')
_ticket_to_ride___cmds=('' '')
_ticket_to_ride___lens=(2 1)
_ticket_to_ride___nexts=('' '')
_ticket_to_ride___occurs=(1 1)
_ticket_to_ride___tags=(' opt ' ' arg ')
_ticket_to_ride___words=(' train plane taxi ' ' kyoto kanazawa kamakura ')

function _ticket_to_ride___act() {
  _ticket_to_ride___cur
  COMPREPLY=( $(compgen -A $1 -- "${_ticket_to_ride___c}") )
  return 0
}

function _ticket_to_ride___add() {
  _ticket_to_ride___cur
  COMPREPLY=( $(compgen -W "$(echo ${@:1})" -- "${_ticket_to_ride___c}") )
  return 0
}

function _ticket_to_ride___any() {
  _ticket_to_ride___act file
  return $?
}

function _ticket_to_ride___cur() {
  _ticket_to_ride___c="${COMP_WORDS[COMP_CWORD]}"
  return 0
}

function _ticket_to_ride___end() {
  if [ $_ticket_to_ride___i -lt $COMP_CWORD ]; then
    return 1
  fi
  return 0
}

function _ticket_to_ride___found() {
  if _ticket_to_ride___keyerr; then return 1; fi
  local n
  n=${_ticket_to_ride___f[$_ticket_to_ride___k]}
  if [[ "$n" == "" ]]; then
    n=1
  else
    let n+=1
  fi
  _ticket_to_ride___f[$_ticket_to_ride___k]=$n
  return 0
}

function _ticket_to_ride___inc() {
  let _ticket_to_ride___i+=1
  return 0
}

function _ticket_to_ride___keyerr() {
  if [[ "$_ticket_to_ride___k" == "" ]] || [ $_ticket_to_ride___k -lt 0 ]; then
    return 0
  fi
  return 1
}

function _ticket_to_ride___word() {
  _ticket_to_ride___w="${COMP_WORDS[$_ticket_to_ride___i]}"
  return 0
}

function _ticket_to_ride() {
  _ticket_to_ride___i=1
  _ticket_to_ride___k=-1
  _ticket_to_ride___ai=0
  _ticket_to_ride___f=()
  while ! _ticket_to_ride___tag stop; do
    _ticket_to_ride___word
    _ticket_to_ride___key
    if _ticket_to_ride___tag term; then
      _ticket_to_ride___inc
      break
    fi
    if _ticket_to_ride___end; then
      _ticket_to_ride___ls
      return $?
    fi
    if [[ $_ticket_to_ride___w =~ ^- ]]; then
      if [ $_ticket_to_ride___k -eq -1 ]; then
        _ticket_to_ride___any
        return $?
      fi
      _ticket_to_ride___found
      _ticket_to_ride___inc
      _ticket_to_ride___len
      if [ $_ticket_to_ride___l -eq 1 ]; then
        continue
      fi
      if _ticket_to_ride___end; then
        _ticket_to_ride___lskey
        return $?
      fi
      _ticket_to_ride___inc
    else
      if _ticket_to_ride___arg; then
        if _ticket_to_ride___end; then
          _ticket_to_ride___lskey
          return $?
        fi
      fi
      _ticket_to_ride___inc
    fi
  done
  if [[ "${_ticket_to_ride___nexts[$_ticket_to_ride___k]}" != "" ]]; then
    _ticket_to_ride___next
  else
    _ticket_to_ride___any
  fi
  return $?
}

function _ticket_to_ride___arg() {
  if [ $_ticket_to_ride___ai -lt ${#_ticket_to_ride___args[@]} ]; then
    _ticket_to_ride___k=${_ticket_to_ride___args[$_ticket_to_ride___ai]}
    if ! _ticket_to_ride___tag varg; then
      let _ticket_to_ride___ai+=1
    fi
    return 0
  fi
  return 1
}

function _ticket_to_ride___key() {
  local i
  i=0
  while [ $i -lt ${#_ticket_to_ride___keys[@]} ]; do
    if [[ ${_ticket_to_ride___keys[$i]} == *' '$_ticket_to_ride___w' '* ]]; then
      _ticket_to_ride___k=$i
      return 0
    fi
    let i+=1
  done
  _ticket_to_ride___k=-1
  return 1
}

function _ticket_to_ride___len() {
  if _ticket_to_ride___keyerr; then return 1; fi
  _ticket_to_ride___l=${_ticket_to_ride___lens[$_ticket_to_ride___k]}
  return 0
}

function _ticket_to_ride___ls() {
  local a i max found arg act cmd
  a=()
  if [[ "$_ticket_to_ride___w" =~ ^- ]]; then
    i=0
    while [ $i -lt ${#_ticket_to_ride___keys[@]} ]; do
      if _ticket_to_ride___tag arg $i; then
        let i+=1
        continue
      fi
      found=${_ticket_to_ride___f[$i]}
      if [[ "$found" == "" ]]; then
        found=0
      fi
      max=${_ticket_to_ride___occurs[$i]}
      if [ $max -lt 0 ] || [ $found -lt $max ]; then
        a+=($(echo "${_ticket_to_ride___keys[$i]}"))
      fi
      let i+=1
    done
  else
    if [ $_ticket_to_ride___ai -lt ${#_ticket_to_ride___args[@]} ]; then
      arg=${_ticket_to_ride___args[$_ticket_to_ride___ai]}
      act=${_ticket_to_ride___acts[$arg]}
      cmd=${_ticket_to_ride___cmds[$arg]}
      if [[ "$act" != "" ]]; then
        _ticket_to_ride___act $act
        return 0
      elif [[ "$cmd" != "" ]]; then
        a=($(eval $cmd))
      else
        a=($(echo "${_ticket_to_ride___words[$arg]}"))
      fi
    fi
  fi
  if [ ${#a[@]} -gt 0 ]; then
    _ticket_to_ride___add "${a[@]}"
    return 0
  fi
  _ticket_to_ride___any
  return $?
}

function _ticket_to_ride___lskey() {
  if ! _ticket_to_ride___keyerr; then
    local act cmd a
    act=${_ticket_to_ride___acts[$_ticket_to_ride___k]}
    cmd=${_ticket_to_ride___cmds[$_ticket_to_ride___k]}
    if [[ "$act" != "" ]]; then
      :
    elif [[ "$cmd" != "" ]]; then
      a=($(eval $cmd))
    else
      a=($(echo "${_ticket_to_ride___words[$_ticket_to_ride___k]}"))
    fi
    if [[ "$act" != "" ]]; then
      _ticket_to_ride___act $act
      return 0
    elif [ ${#a[@]} -gt 0 ]; then
      _ticket_to_ride___add "${a[@]}"
      return 0
    fi
  fi
  _ticket_to_ride___any
  return $?
}

function _ticket_to_ride___tag() {
  local k
  if [[ "$2" == "" ]]; then
    if _ticket_to_ride___keyerr; then return 1; fi
    k=$_ticket_to_ride___k
  else
    k=$2
  fi
  if [[ ${_ticket_to_ride___tags[$k]} == *' '$1' '* ]]; then
    return 0
  fi
  return 1
}

complete -F _ticket_to_ride ticket-to-ride
