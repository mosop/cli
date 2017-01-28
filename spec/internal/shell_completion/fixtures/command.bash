_command___keys=(' subcommand ')
_command___args=(0)
_command___acts=('')
_command___cmds=('')
_command___lens=(1)
_command___nexts=(' subcommand1 subcommand2 ')
_command___occurs=(1)
_command___tags=(' arg stop ')
_command___words=(' subcommand1 subcommand2 ')

function _command___act() {
  _command___cur
  COMPREPLY=( $(compgen -A $1 -- "${_command___c}") )
  return 0
}

function _command___add() {
  _command___cur
  COMPREPLY=( $(compgen -W "$(echo ${@:1})" -- "${_command___c}") )
  return 0
}

function _command___any() {
  _command___act file
  return $?
}

function _command___cur() {
  _command___c="${COMP_WORDS[COMP_CWORD]}"
  return 0
}

function _command___end() {
  if [ $_command___i -lt $COMP_CWORD ]; then
    return 1
  fi
  return 0
}

function _command___found() {
  if _command___keyerr; then return 1; fi
  local n
  n=${_command___f[$_command___k]}
  if [[ "$n" == "" ]]; then
    n=1
  else
    let n+=1
  fi
  _command___f[$_command___k]=$n
  return 0
}

function _command___inc() {
  let _command___i+=1
  return 0
}

function _command___keyerr() {
  if [[ "$_command___k" == "" ]] || [ $_command___k -lt 0 ]; then
    return 0
  fi
  return 1
}

function _command___word() {
  _command___w="${COMP_WORDS[$_command___i]}"
  return 0
}

function _command() {
  _command___i=1
  _command___k=-1
  _command___ai=0
  _command___f=()
  while ! _command___tag stop; do
    _command___word
    _command___key
    if _command___tag term; then
      _command___inc
      break
    fi
    if _command___end; then
      _command___ls
      return $?
    fi
    if [[ $_command___w =~ ^- ]]; then
      if [ $_command___k -eq -1 ]; then
        _command___any
        return $?
      fi
      _command___found
      _command___inc
      _command___len
      if [ $_command___l -eq 1 ]; then
        continue
      fi
      if _command___end; then
        _command___lskey
        return $?
      fi
      _command___inc
    else
      if _command___arg; then
        if _command___end; then
          _command___lskey
          return $?
        fi
      fi
      _command___inc
    fi
  done
  if [[ "${_command___nexts[$_command___k]}" != "" ]]; then
    _command___next
  else
    _command___any
  fi
  return $?
}

function _command___arg() {
  if [ $_command___ai -lt ${#_command___args[@]} ]; then
    _command___k=${_command___args[$_command___ai]}
    if ! _command___tag varg; then
      let _command___ai+=1
    fi
    return 0
  fi
  return 1
}

function _command___key() {
  local i
  i=0
  while [ $i -lt ${#_command___keys[@]} ]; do
    if [[ ${_command___keys[$i]} == *' '$_command___w' '* ]]; then
      _command___k=$i
      return 0
    fi
    let i+=1
  done
  _command___k=-1
  return 1
}

function _command___len() {
  if _command___keyerr; then return 1; fi
  _command___l=${_command___lens[$_command___k]}
  return 0
}

function _command___ls() {
  local a i max found arg act cmd
  a=()
  if [[ "$_command___w" =~ ^- ]]; then
    i=0
    while [ $i -lt ${#_command___keys[@]} ]; do
      if _command___tag arg $i; then
        let i+=1
        continue
      fi
      found=${_command___f[$i]}
      if [[ "$found" == "" ]]; then
        found=0
      fi
      max=${_command___occurs[$i]}
      if [ $max -lt 0 ] || [ $found -lt $max ]; then
        a+=($(echo "${_command___keys[$i]}"))
      fi
      let i+=1
    done
  else
    if [ $_command___ai -lt ${#_command___args[@]} ]; then
      arg=${_command___args[$_command___ai]}
      act=${_command___acts[$arg]}
      cmd=${_command___cmds[$arg]}
      if [[ "$act" != "" ]]; then
        _command___act $act
        return 0
      elif [[ "$cmd" != "" ]]; then
        a=($(eval $cmd))
      else
        a=($(echo "${_command___words[$arg]}"))
      fi
    fi
  fi
  if [ ${#a[@]} -gt 0 ]; then
    _command___add "${a[@]}"
    return 0
  fi
  _command___any
  return $?
}

function _command___lskey() {
  if ! _command___keyerr; then
    local act cmd a
    act=${_command___acts[$_command___k]}
    cmd=${_command___cmds[$_command___k]}
    if [[ "$act" != "" ]]; then
      :
    elif [[ "$cmd" != "" ]]; then
      a=($(eval $cmd))
    else
      a=($(echo "${_command___words[$_command___k]}"))
    fi
    if [[ "$act" != "" ]]; then
      _command___act $act
      return 0
    elif [ ${#a[@]} -gt 0 ]; then
      _command___add "${a[@]}"
      return 0
    fi
  fi
  _command___any
  return $?
}

function _command___tag() {
  local k
  if [[ "$2" == "" ]]; then
    if _command___keyerr; then return 1; fi
    k=$_command___k
  else
    k=$2
  fi
  if [[ ${_command___tags[$k]} == *' '$1' '* ]]; then
    return 0
  fi
  return 1
}

function _command___next() {
  case $_command___w in
    'subcommand1')
      _command__subcommand1
      ;;
    'subcommand2')
      _command__subcommand2
      ;;
    *)
      _command___any
      ;;
  esac
  return $?
}

_command__subcommand1___keys=(' -s ')
_command__subcommand1___args=()
_command__subcommand1___acts=('')
_command__subcommand1___cmds=('')
_command__subcommand1___lens=(2)
_command__subcommand1___nexts=('')
_command__subcommand1___occurs=(1)
_command__subcommand1___tags=(' opt ')
_command__subcommand1___words=('')

function _command__subcommand1() {
  _command___k=-1
  _command___ai=0
  _command___f=()
  while ! _command__subcommand1___tag stop; do
    _command___word
    _command__subcommand1___key
    if _command__subcommand1___tag term; then
      _command___inc
      break
    fi
    if _command___end; then
      _command__subcommand1___ls
      return $?
    fi
    if [[ $_command___w =~ ^- ]]; then
      if [ $_command___k -eq -1 ]; then
        _command___any
        return $?
      fi
      _command___found
      _command___inc
      _command__subcommand1___len
      if [ $_command___l -eq 1 ]; then
        continue
      fi
      if _command___end; then
        _command__subcommand1___lskey
        return $?
      fi
      _command___inc
    else
      if _command__subcommand1___arg; then
        if _command___end; then
          _command__subcommand1___lskey
          return $?
        fi
      fi
      _command___inc
    fi
  done
  if [[ "${_command__subcommand1___nexts[$_command___k]}" != "" ]]; then
    _command__subcommand1___next
  else
    _command___any
  fi
  return $?
}

function _command__subcommand1___arg() {
  if [ $_command___ai -lt ${#_command__subcommand1___args[@]} ]; then
    _command___k=${_command__subcommand1___args[$_command___ai]}
    if ! _command__subcommand1___tag varg; then
      let _command___ai+=1
    fi
    return 0
  fi
  return 1
}

function _command__subcommand1___key() {
  local i
  i=0
  while [ $i -lt ${#_command__subcommand1___keys[@]} ]; do
    if [[ ${_command__subcommand1___keys[$i]} == *' '$_command___w' '* ]]; then
      _command___k=$i
      return 0
    fi
    let i+=1
  done
  _command___k=-1
  return 1
}

function _command__subcommand1___len() {
  if _command___keyerr; then return 1; fi
  _command___l=${_command__subcommand1___lens[$_command___k]}
  return 0
}

function _command__subcommand1___ls() {
  local a i max found arg act cmd
  a=()
  if [[ "$_command___w" =~ ^- ]]; then
    i=0
    while [ $i -lt ${#_command__subcommand1___keys[@]} ]; do
      if _command__subcommand1___tag arg $i; then
        let i+=1
        continue
      fi
      found=${_command___f[$i]}
      if [[ "$found" == "" ]]; then
        found=0
      fi
      max=${_command__subcommand1___occurs[$i]}
      if [ $max -lt 0 ] || [ $found -lt $max ]; then
        a+=($(echo "${_command__subcommand1___keys[$i]}"))
      fi
      let i+=1
    done
  else
    if [ $_command___ai -lt ${#_command__subcommand1___args[@]} ]; then
      arg=${_command__subcommand1___args[$_command___ai]}
      act=${_command__subcommand1___acts[$arg]}
      cmd=${_command__subcommand1___cmds[$arg]}
      if [[ "$act" != "" ]]; then
        _command___act $act
        return 0
      elif [[ "$cmd" != "" ]]; then
        a=($(eval $cmd))
      else
        a=($(echo "${_command__subcommand1___words[$arg]}"))
      fi
    fi
  fi
  if [ ${#a[@]} -gt 0 ]; then
    _command___add "${a[@]}"
    return 0
  fi
  _command___any
  return $?
}

function _command__subcommand1___lskey() {
  if ! _command___keyerr; then
    local act cmd a
    act=${_command__subcommand1___acts[$_command___k]}
    cmd=${_command__subcommand1___cmds[$_command___k]}
    if [[ "$act" != "" ]]; then
      :
    elif [[ "$cmd" != "" ]]; then
      a=($(eval $cmd))
    else
      a=($(echo "${_command__subcommand1___words[$_command___k]}"))
    fi
    if [[ "$act" != "" ]]; then
      _command___act $act
      return 0
    elif [ ${#a[@]} -gt 0 ]; then
      _command___add "${a[@]}"
      return 0
    fi
  fi
  _command___any
  return $?
}

function _command__subcommand1___tag() {
  local k
  if [[ "$2" == "" ]]; then
    if _command___keyerr; then return 1; fi
    k=$_command___k
  else
    k=$2
  fi
  if [[ ${_command__subcommand1___tags[$k]} == *' '$1' '* ]]; then
    return 0
  fi
  return 1
}

_command__subcommand2___keys=(' -s ')
_command__subcommand2___args=()
_command__subcommand2___acts=('')
_command__subcommand2___cmds=('')
_command__subcommand2___lens=(2)
_command__subcommand2___nexts=('')
_command__subcommand2___occurs=(1)
_command__subcommand2___tags=(' opt ')
_command__subcommand2___words=('')

function _command__subcommand2() {
  _command___k=-1
  _command___ai=0
  _command___f=()
  while ! _command__subcommand2___tag stop; do
    _command___word
    _command__subcommand2___key
    if _command__subcommand2___tag term; then
      _command___inc
      break
    fi
    if _command___end; then
      _command__subcommand2___ls
      return $?
    fi
    if [[ $_command___w =~ ^- ]]; then
      if [ $_command___k -eq -1 ]; then
        _command___any
        return $?
      fi
      _command___found
      _command___inc
      _command__subcommand2___len
      if [ $_command___l -eq 1 ]; then
        continue
      fi
      if _command___end; then
        _command__subcommand2___lskey
        return $?
      fi
      _command___inc
    else
      if _command__subcommand2___arg; then
        if _command___end; then
          _command__subcommand2___lskey
          return $?
        fi
      fi
      _command___inc
    fi
  done
  if [[ "${_command__subcommand2___nexts[$_command___k]}" != "" ]]; then
    _command__subcommand2___next
  else
    _command___any
  fi
  return $?
}

function _command__subcommand2___arg() {
  if [ $_command___ai -lt ${#_command__subcommand2___args[@]} ]; then
    _command___k=${_command__subcommand2___args[$_command___ai]}
    if ! _command__subcommand2___tag varg; then
      let _command___ai+=1
    fi
    return 0
  fi
  return 1
}

function _command__subcommand2___key() {
  local i
  i=0
  while [ $i -lt ${#_command__subcommand2___keys[@]} ]; do
    if [[ ${_command__subcommand2___keys[$i]} == *' '$_command___w' '* ]]; then
      _command___k=$i
      return 0
    fi
    let i+=1
  done
  _command___k=-1
  return 1
}

function _command__subcommand2___len() {
  if _command___keyerr; then return 1; fi
  _command___l=${_command__subcommand2___lens[$_command___k]}
  return 0
}

function _command__subcommand2___ls() {
  local a i max found arg act cmd
  a=()
  if [[ "$_command___w" =~ ^- ]]; then
    i=0
    while [ $i -lt ${#_command__subcommand2___keys[@]} ]; do
      if _command__subcommand2___tag arg $i; then
        let i+=1
        continue
      fi
      found=${_command___f[$i]}
      if [[ "$found" == "" ]]; then
        found=0
      fi
      max=${_command__subcommand2___occurs[$i]}
      if [ $max -lt 0 ] || [ $found -lt $max ]; then
        a+=($(echo "${_command__subcommand2___keys[$i]}"))
      fi
      let i+=1
    done
  else
    if [ $_command___ai -lt ${#_command__subcommand2___args[@]} ]; then
      arg=${_command__subcommand2___args[$_command___ai]}
      act=${_command__subcommand2___acts[$arg]}
      cmd=${_command__subcommand2___cmds[$arg]}
      if [[ "$act" != "" ]]; then
        _command___act $act
        return 0
      elif [[ "$cmd" != "" ]]; then
        a=($(eval $cmd))
      else
        a=($(echo "${_command__subcommand2___words[$arg]}"))
      fi
    fi
  fi
  if [ ${#a[@]} -gt 0 ]; then
    _command___add "${a[@]}"
    return 0
  fi
  _command___any
  return $?
}

function _command__subcommand2___lskey() {
  if ! _command___keyerr; then
    local act cmd a
    act=${_command__subcommand2___acts[$_command___k]}
    cmd=${_command__subcommand2___cmds[$_command___k]}
    if [[ "$act" != "" ]]; then
      :
    elif [[ "$cmd" != "" ]]; then
      a=($(eval $cmd))
    else
      a=($(echo "${_command__subcommand2___words[$_command___k]}"))
    fi
    if [[ "$act" != "" ]]; then
      _command___act $act
      return 0
    elif [ ${#a[@]} -gt 0 ]; then
      _command___add "${a[@]}"
      return 0
    fi
  fi
  _command___any
  return $?
}

function _command__subcommand2___tag() {
  local k
  if [[ "$2" == "" ]]; then
    if _command___keyerr; then return 1; fi
    k=$_command___k
  else
    k=$2
  fi
  if [[ ${_command__subcommand2___tags[$k]} == *' '$1' '* ]]; then
    return 0
  fi
  return 1
}

complete -F _command command
