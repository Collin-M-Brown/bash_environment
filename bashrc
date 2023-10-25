

bind "set completion-ignore-case on"
alias python='python3'
HOME_DIR=/home/cbrown01
SCRIPT_PATH=/$HOME_DIR/BasicScripts/
REPOS=$HOME_DIR/repos

###############COMMON################
#BRANCH_LOG=
#BOOKMARKS=
#VSCODE_BOOKMARKS=
#USING_BOOKMARKS=
#STATIC_BRANCH_ORDER=
#set_common() {
#echo "\
#BRANCH_LOG = \"$BRANCH_LOG\"
#BOOKMARKS = \"$BOOKMARKS\"
#VSCODE_BOOKMARKS = \"$VSCODE_BOOKMARKS\"
#USING_BOOKMARKS = $USING_BOOKMARKS 
#STATIC_BRANCH_ORDER = $STATIC_BRANCH_ORDER" > $SCRIPT_PATH/Common.py
#}
#set_common
#####################################

function realias() {
    alias home="cd $HOME_DIR"
    alias bsh="source /home/cbrown01/repos/bash_environment/bashrc"
    alias cbsh="code /home/cbrown01/repos/bash_environment/bashrc"
    alias fsp="cd $REPOS/full_stack_project"
    alias sc="cd $SCRIPT_PATH"
    alias repos="cd $REPOS"
    alias vp="fsp ; cd vid-proc/"
    alias bmp="repos ; cd bookmarks_plus"
    alias bmpp="repos ; cd bookmarks-"

    ###SCRIPT STUFF####
    #alias br="python $SCRIPT_PATH/GitBranch.py b"
    alias br="git branch"
    alias brlog="code $SETTINGS_DIR/branch.log"
    alias gl="python $SCRIPT_PATH/GitBranch.py l"
    alias gco="python $SCRIPT_PATH/GitBranch.py co"
    alias hb="python $SCRIPT_PATH/GitBranch.py h"
    alias hbr="python $SCRIPT_PATH/GitBranch.py hb"
    alias uh="python $SCRIPT_PATH/GitBranch.py uh"
    alias cbranch="code $SETTINGS_DIR/branch.log"
    alias load="py GitBranch load_bookmarks"
    alias save="py GitBranch save_bookmarks"
    ######################

    echo "aliases set"
}

function lstr() { IFS='' ; if [ -z "$1" ]; then echo $(ls -ltr | sed -E -e 's/[^0-9]+ [0-9]+\s+[a-zA-Z0-9]+\s+[a-zA-Z0-9]+\s+[0-9]+\s+//g') ; else echo $(ls -ltr | grep -i $1 | sed -E -e 's/[^0-9]+ [0-9]+\s+[a-zA-Z0-9]+\s+[a-zA-Z0-9]+\s+[0-9]+\s+//g') ; fi ;}
function fnd() { find . -iname "*$1*" ;}
function wr() { sudo chmod -R a+rwx $1 ;}

################

declare -a dir_array
declare -A dir_map
function cd() {
    builtin cd "$@" && {
        # If directory is in the map, remove it from array
        if [[ -n "${dir_map[$PWD]}" ]]
        then
            unset dir_array[${dir_map[$PWD]}]
        fi
        # Re-index the array and map
        dir_array=("$PWD" "${dir_array[@]}")
        for i in "${!dir_array[@]}"; do
            dir_map[${dir_array[$i]}]=$i
        done
        # If the array is full, remove the last entry
        if (( ${#dir_array[@]} > 10 ))
        then
            unset dir_array[10]
            unset dir_map[${dir_array[10]}]
        fi
    }
}

function cdf() {
    if [ -z "$1" ]
    then
        # Print all directories in the array
        for ((i=${#dir_array[@]}-1; i>=0; i--)); do
            printf "%s\t%s\n" "$i" "${dir_array[$i]}"
        done
    else
        # cd to path at given index
        if [[ $1 =~ ^[0-9]+$ ]]
        then
            if (( $1 >= 0 && $1 < ${#dir_array[@]} ))
            then
                cd "${dir_array[$1]}"
            else
                echo "Index out of range"
            fi
        else
            echo "Invalid argument. Please provide an index number."
        fi
    fi
}

function back() {
    if (( ${#dir_array[@]} > 1 ))
    then
        cd "${dir_array[1]}"
    else
        echo "No previous directory"
    fi
}

###############COMMAND PROMPT################
UNDERLINE='\[\033[4m\]'
NORMAL='\[\033[0m\]'
TIME_COLOR='\[\033[38;5;228m\]'
HOST_COLOR='\[\033[38;5;158m\]'
BRANCH_COLOR='\[\033[\e[0;38;5;85m\]'
DIR_COLOR='\[\033[0;0;38;5;189m\]'
PROMPT_COLOR='\[\033[38;5;83m\]'

function directory() {
    output=$(pwd)
    IFS='/' read -r -a array <<< "$output"
    len=${#array[@]}
    if [ $len -gt 4 ]
    then
        echo -e ".../${array[$len-3]}/${array[$len-2]}/${array[len-1]}"
    else
        echo "~$output"
    fi
}

function git_branch() {
   echo -e ${VIEW_COLOR}$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')${BRANCH_COLOR} || echo $(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/') 
}

function git_repo() {
    rep=$(pwd | grep -o 'repo[0-9]' | head -1)
    if [ ! -z $rep ]; then echo $rep ; fi
}

function update_ps1() {
export PS1="\
${TIME_COLOR}\
[\@] \
${DIR_COLOR}\
[$(directory)] \
${BRANCH_COLOR}\
->[$(git_branch)]\
${PROMPT_COLOR}\

$ \
${NORMAL}"
}
PROMPT_COMMAND="update_ps1"
##################################################################

realias
export PATH=$PATH:/home/cbrown01/.local/bin
