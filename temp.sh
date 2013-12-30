bashfoo_require text

#set -x
bashfoo.mktemp.prepare()
{
    if [ -z "$bashfoo_mktemp_template_base" ] ; then
        if [ -n "$SCRIPT_NAME" ] ; then
            bashfoo_mktemp_template_base="$SCRIPT_NAME"
        else
            local idx="${#BASH_SOURCE[*]}"
            bashfoo_mktemp_template_base="$(basename ${BASH_SOURCE[$idx-1]]})"
        fi
        
        if [ -n "$USER" ] ; then
            bashfoo_mktemp_template_base="$USER-$bashfoo_mktemp_template_base"
        fi
        
        local bashfoo_mktemp_temp="${TMP-/tmp}"
        bashfoo_mktemp_template_base="${bashfoo_mktemp_temp}/${bashfoo_mktemp_template_base}"
    fi
    # also first time, generate a name 
    # for temp-file list
    if [ -z "$bashfoo_mktemp_file_list" ] ; then
        bashfoo_mktemp_file_list="$(mktemp "${bashfoo_mktemp_template_base}-filelist-$$-XXXXXXX")"
    fi
}

bashfoo.mktemp.prepare

bashfoo.mktemp() {
    # first time, prepare templace variables
    local localname="${1-file}"
    local result="$(mktemp "${bashfoo_mktemp_template_base}-${localname}-$$-XXXXXXX")"
    echo "$result" >> "$bashfoo_mktemp_file_list"
    
    echo "$result"
}

bashfoo.mktemp.cleanup()
{
    if [ -z "${bashfoo_mktemp_file_list}" ] ; then
        return
    fi
    if [ ! -f "${bashfoo_mktemp_file_list}" ] ; then
        return
    fi
    (
        #IFS="\n"
        for file in $(bashfoo.tac "${bashfoo_mktemp_file_list}") ; do
            rm "$file"
        done
    )
    rm "${bashfoo_mktemp_file_list}"
}

trap bashfoo.mktemp.cleanup EXIT 
