_ticket_to_ride__keys=(' --by ' ' for ')
_ticket_to_ride__args=(1 )
_ticket_to_ride__acts=('' '')
_ticket_to_ride__cmds=('' '')
_ticket_to_ride__lens=(2 1)
_ticket_to_ride__nexts=('' '')
_ticket_to_ride__occurs=(1 1)
_ticket_to_ride__tags=(' opt ' ' arg ')
_ticket_to_ride__words=(' train plane taxi ' ' kyoto kanazawa kamakura ')

function _ticket_to_ride__act() {
  setopt localoptions ksharrays
  
  local -a a jids
  case $1 in
    alias)
      a=( "${(k)aliases[@]}" ) ;;
    arrayvar)
      a=( "${(k@)parameters[(R)array*]}" )
      ;;
    binding)
      a=( "${(k)widgets[@]}" )
      ;;
    builtin)
      a=( "${(k)builtins[@]}" "${(k)dis_builtins[@]}" )
      ;;
    command)
      a=( "${(k)commands[@]}" "${(k)aliases[@]}" "${(k)builtins[@]}" "${(k)functions[@]}" "${(k)reswords[@]}")
      ;;
    directory)
      a=( ${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N-/) )
      ;;
    disabled)
      a=( "${(k)dis_builtins[@]}" )
      ;;
    enabled)
      a=( "${(k)builtins[@]}" )
      ;;
    export)
      a=( "${(k)parameters[(R)*export*]}" )
      ;;
    file)
      a=( ${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N) )
      ;;
    function)
      a=( "${(k)functions[@]}" )
      ;;
    group)
      _groups -U -O a
      ;;
    hostname)
      _hosts -U -O a
      ;;
    job)
      a=( "${savejobtexts[@]%% *}" )
      ;;
    keyword)
      a=( "${(k)reswords[@]}" )
      ;;
    running)
      a=()
      jids=( "${(@k)savejobstates[(R)running*]}" )
      for job in "${jids[@]}"; do
        a+=( ${savejobtexts[$job]%% *} )
      done
      ;;
    stopped)
      a=()
      jids=( "${(@k)savejobstates[(R)suspended*]}" )
      for job in "${jids[@]}"; do
        a+=( ${savejobtexts[$job]%% *} )
      done
      ;;
    setopt|shopt)
      a=( "${(k)options[@]}" )
      ;;
    signal)
      a=( "SIG${^signals[@]}" )
      ;;
    user)
      a=( "${(k)userdirs[@]}" )
      ;;
    variable)
      a=( "${(k)parameters[@]}" )
      ;;
    *)
      a=( ${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N) )
      ;;
  esac
  compadd -- "${a[@]}"
  return 0
}

function _ticket_to_ride__add() {
  setopt localoptions ksharrays
  
  compadd -- "${@:1}"
  return 0
}

function _ticket_to_ride__any() {
  setopt localoptions ksharrays
  
  _ticket_to_ride__act file
  return $?
}

function _ticket_to_ride__cur() {
  setopt localoptions ksharrays
  
  _ticket_to_ride__c="${COMP_WORDS[COMP_CWORD]}"
  return 0
}

function _ticket_to_ride__end() {
  setopt localoptions ksharrays
  
  if [ $_ticket_to_ride__i -lt $COMP_CWORD ]; then
    return 1
  fi
  return 0
}

function _ticket_to_ride__found() {
  setopt localoptions ksharrays
  
  if _ticket_to_ride__keyerr; then return 1; fi
  local n
  n=${_ticket_to_ride__f[$_ticket_to_ride__k]}
  if [[ "$n" == "" ]]; then
    n=1
  else
    let n+=1
  fi
  _ticket_to_ride__f[$_ticket_to_ride__k]=$n
  return 0
}

function _ticket_to_ride__inc() {
  setopt localoptions ksharrays
  
  let _ticket_to_ride__i+=1
  return 0
}

function _ticket_to_ride__keyerr() {
  setopt localoptions ksharrays
  
  if [[ "$_ticket_to_ride__k" == "" ]] || [ $_ticket_to_ride__k -lt 0 ]; then
    return 0
  fi
  return 1
}

function _ticket_to_ride__word() {
  setopt localoptions ksharrays
  
  _ticket_to_ride__w="${COMP_WORDS[$_ticket_to_ride__i]}"
  return 0
}

function _ticket_to_ride() {
  setopt localoptions ksharrays
  
  (( COMP_CWORD = CURRENT - 1 ))
  COMP_WORDS=($(echo ${words[@]}))
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
        _ticket_to_ride__found
        _ticket_to_ride__inc
        continue
      fi
      if _ticket_to_ride__end; then
        _ticket_to_ride__lskey
        return $?
      fi
      _ticket_to_ride__found
      _ticket_to_ride__inc
    else
      if _ticket_to_ride__arg; then
        if _ticket_to_ride__end; then
          _ticket_to_ride__lskey
          return $?
        fi
      fi
      _ticket_to_ride__inc
    fi
  done
  if [[ "${_ticket_to_ride__nexts[$_ticket_to_ride__k]}" != "" ]]; then
    _ticket_to_ride__next
  else
    _ticket_to_ride__any
  fi
  return $?
}

function _ticket_to_ride__arg() {
  setopt localoptions ksharrays
  
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
  setopt localoptions ksharrays
  
  local i
  i=0
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
  setopt localoptions ksharrays
  
  if _ticket_to_ride__keyerr; then return 1; fi
  _ticket_to_ride__l=${_ticket_to_ride__lens[$_ticket_to_ride__k]}
  return 0
}

function _ticket_to_ride__ls() {
  setopt localoptions ksharrays
  
  local a i max found arg act cmd
  a=()
  if ! [[ "$_ticket_to_ride__w" =~ ^- ]]; then
    if [ $_ticket_to_ride__ai -lt ${#_ticket_to_ride__args[@]} ]; then
      arg=${_ticket_to_ride__args[$_ticket_to_ride__ai]}
      act=${_ticket_to_ride__acts[$arg]}
      cmd=${_ticket_to_ride__cmds[$arg]}
      if [[ "$act" != "" ]]; then
        :
      elif [[ "$cmd" != "" ]]; then
        a+=($($cmd))
      else
        a+=($(echo "${_ticket_to_ride__words[$arg]}"))
      fi
    fi
  fi
  if [[ "$_ticket_to_ride__w" =~ ^- ]] || [[ "$_ticket_to_ride__w" == "" ]] && [[ "$act" == "" ]] && [[ "$cmd" == "" ]]; then
    i=0
    while [ $i -lt ${#_ticket_to_ride__keys[@]} ]; do
      if _ticket_to_ride__tag arg $i; then
        let i+=1
        continue
      fi
      found=${_ticket_to_ride__f[$i]}
      if [[ "$found" == "" ]]; then
        found=0
      fi
      max=${_ticket_to_ride__occurs[$i]}
      if [ $max -lt 0 ] || [ $found -lt $max ]; then
        a+=($(echo "${_ticket_to_ride__keys[$i]}"))
      fi
      let i+=1
    done
  fi
  if [[ "$act" != "" ]]; then
    _ticket_to_ride__act $act
    return 0
  elif [ ${#a[@]} -gt 0 ]; then
    _ticket_to_ride__add "${a[@]}"
    return 0
  fi
  _ticket_to_ride__any
  return $?
}

function _ticket_to_ride__lskey() {
  setopt localoptions ksharrays
  
  if ! _ticket_to_ride__keyerr; then
    local act
    local cmd
    local a
    act=${_ticket_to_ride__acts[$_ticket_to_ride__k]}
    cmd=${_ticket_to_ride__cmds[$_ticket_to_ride__k]}
    if [[ "$act" != "" ]]; then
      :
    elif [[ "$cmd" != "" ]]; then
      a=($($cmd))
    else
      a=($(echo "${_ticket_to_ride__words[$_ticket_to_ride__k]}"))
    fi
    if [[ "$act" != "" ]]; then
      _ticket_to_ride__act $act
      return 0
    elif [ ${#a[@]} -gt 0 ]; then
      _ticket_to_ride__add "${a[@]}"
      return 0
    fi
  fi
  _ticket_to_ride__any
  return $?
}

function _ticket_to_ride__tag() {
  setopt localoptions ksharrays
  
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

compdef _ticket_to_ride ticket-to-ride
