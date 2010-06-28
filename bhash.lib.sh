__bhash_get_pos ()
{
    [ "$#" = "2" ] || return 1
    local i=0
    local c
    eval "echo -e \${${1}[0]} | tr '\\000' '\\012'" | \
    while read c; do
        [ "${c}" = "${2}" ] && echo "$i" && return 1
        let i+=1
    done
    return 0
}

__bhash_get_value ()
{
    [ "$#" = "2" ] || return 1
    local i=0
    local c
    eval "echo -e \${${1}[1]} | tr '\\000' '\\012'" | \
    while read c; do
        [ "${i}" = "${2}" ] && echo "${c}" && return 1
        let i+=1
    done
    return 0
}

hget ()
{
    [ "$#" = "2" ] || return 1
    local POS=$(__bhash_get_pos "${1}" "${2}")
    [ -z "${POS}" ] && return 1
    echo "$(__bhash_get_value "${1}" ${POS})"
    return 0
}

___bhash_replace ()
{
    [ "$#" = "3" ] || return 1
    local POS=$(__bhash_get_pos ${1} ${2})
    local i=0
    local c
    eval "echo -e \${${1}[0]} | tr '\\000' '\\012'" | \
    while read c; do
        if [ "${c}" = "${2}" ]; then
            echo -n "\000${3}"
        else
            echo -n "\000$(hget "${1}" "${c}")"
        fi
    done
    return 0
}

__bhash_replace ()
{
    [ "$#" = "3" ] || return 1
    ___bhash_replace "$@" | cut -c 5-
    return 0
}

hput ()
{
    [ "$#" = "3" ] || return 1
    if [ -z $(__bhash_get_pos ${1} ${2}) ]; then
        if [ -z "$(eval "echo \"\${${1}[0]}\"")" ]; then
            eval "${1}[0]+='${2}'"
            eval "${1}[1]+='${3}'"
        else
            eval "${1}[0]+='\000${2}'"
            eval "${1}[1]+='\000${3}'"
        fi
    else
        eval "${1}[1]=\"$(__bhash_replace "$@")\""
    fi
    return 0
}

__bhash_keys ()
{
    [ "$#" = "1" ] || return 1
    echo -n "("
    eval "echo -e \${${1}[0]} | tr '\\000' '\\012'" | \
    while read c; do
        echo -n " \"${c}\""
    done
    echo -n " )"
    return 0
}

hkeys ()
{
    [ "$#" = "2" ] || return 1
    eval "${2}=$(__bhash_keys "${1}")"
    return 0
}

__bhash_values ()
{
    [ "$#" = "1" ] || return 1
    echo -n "("
    eval "echo -e \${${1}[1]} | tr '\\000' '\\012'" | \
    while read c; do
        echo -n " \"${c}\""
    done
    echo -n " )"
    return 0
}

hvalues ()
{
    [ "$#" = "2" ] || return 1
    eval "${2}=$(__bhash_values "${1}")"
    return 0
}

___bhash_jumpkey ()
{
    [ "$#" = "2" ] || return 1
    local c
    eval "echo -e \${${1}[0]} | tr '\\000' '\\012'" | \
    while read c; do
        [ "${c}" = "${2}" ] || echo -n "\000${c}"
    done
    return 0
}

__bhash_jumpkey ()
{
    [ "$#" = "2" ] || return 1
    ___bhash_jumpkey "$@" | cut -c 5-
    return 0
}

___bhash_jumpvalue ()
{
    [ "$#" = "2" ] || return 1
    local i=0
    local c
    eval "echo -e \${${1}[1]} | tr '\\000' '\\012'" | \
    while read c; do
        [ "${i}" = "${2}" ] || echo -n "\000${c}"
        let i+=1
    done
    return 0
}

__bhash_jumpvalue ()
{
    [ "$#" = "2" ] || return 1
    ___bhash_jumpvalue "$@" | cut -c 5-
    return 0
}

hdel ()
{
    [ "$#" = "2" ] || return 1
    local POS="$(__bhash_get_pos "${1}" "${2}")"
    eval "${1}[0]=\"$(__bhash_jumpkey "$@")\""
    eval "${1}[1]=\"$(__bhash_jumpvalue "${1}" "${POS}")\""
    return 0
}
