_felix_last_venv=''
_felix_current_venv=''

GIT_DIR="$HOME/git"
PYENV_DIR="$HOME/python-venv"

# Detects the current virtual environement based on the git root. If the git
# root is in $GIT_DIR and that it has a corresponding virtualenv in
# ${PYENV_DIR} then we consider that it's the virtualenv that we want
# to use.
function felix_detect_venv() {
    git_dir=$(git rev-parse --show-toplevel) 2> /dev/null

    if [[ ! "$git_dir" == $GIT_DIR/* ]];
    then
        return
    fi

    venv=$(basename "$git_dir")

    if [[ ! -f "${PYENV_DIR}/$venv/bin/activate" ]];
    then
        return
    fi

    echo $venv
}

# Switches the old/new virtualenvironment for state detection (we only want to
# activate/deactivate the virtualenv when required, not after every command)
function felix_check_venv() {
    _felix_last_venv="$(basename "$VIRTUAL_ENV")"
    _felix_current_venv="$(felix_detect_venv)"
}

# Generates the code that has to be executed in order to switch the virtual
# environment (if needed)
function felix_venv_action() {
    if [[ $_felix_last_venv == $_felix_current_venv ]];
    then
        return
    fi

    if [[ $_felix_current_venv == '' ]];
    then
        if [[ $VIRTUAL_ENV == ${PYENV_DIR}/* ]];
        then
            echo "deactivate"
        fi
    else
        echo "source ${PYENV_DIR}/$_felix_current_venv/bin/activate"
    fi
}


# Does the dance to actually activate/deactivate the virtual environment
function felix_switch_venv() {
    felix_check_venv
    action=`felix_venv_action`

    if [[ $action == "" ]];
    then
        return
    fi

    if [[ $action == deactivate ]];
    then
        echo "\nDeactivating $(tput bold)$_felix_last_venv$(tput sgr0)"
    elif [[ $action == source* ]];
    then
        echo "\nActivating $(tput bold)$_felix_current_venv$(tput sgr0)"
    fi

    eval "$action"
}

autoload -U +X bashcompinit && bashcompinit

add-zsh-hook precmd felix_switch_venv
