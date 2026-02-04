set -o nounset

export EDITOR="$VISUAL"
export VISUAL=vim

if [ -e $HOME/.bash_alias ]; then
    source $HOME/.bash_alias
fi

if [ -e $HOME/.bash_prompt ]; then
    source $HOME/.bash_prompt
fi

test -s ~/.alias && . ~/.alias || true

# Color codes
white=$(tput setaf 231) 
blue=$(tput setaf 27)

HISTTIMEFORMAT="$blue%Y-%m-%d $blue%H:%M:%S $white"


ec2list() {
    local profile=""
    local pattern=""
    local grep_color="--color=auto"

    # Parse command-line options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p)
                profile="$2"
                shift 2
                ;;
            -g)
                pattern="$2"
                shift 2
                ;;
            *)
                echo "Invalid option: $1" 1>&2
                return 1
                ;;
        esac
    done

    # Validate profile is provided
    if [[ -z "$profile" ]]; then
        echo "Usage: ec2list -p <profile> [-g <grep_pattern>]"
        return 1
    fi

    # Command to describe instances
    local aws_command="aws ec2 describe-instances --profile \"$profile\" --query \"Reservations[*].Instances[*].[InstanceId, InstanceType, State.Name, Tags[?Key=='Name'].Value | [0]]\" --output table"

    # Execute command and filter by pattern if provided
    if [[ -n "$pattern" ]]; then
        # Use command substitution instead of eval
        local result
        result=$(bash -c "$aws_command")
        echo "$result" | grep $grep_color "$pattern"
    else
        bash -c "$aws_command"
    fi
}


ssm() {
    local profile=""
    local instance_id=""

    # Parse command-line options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p)
                profile="$2"
                shift 2
                ;;
            -t)
                instance_id="$2"
                shift 2
                ;;
            *)
                echo "Invalid option: $1" 1>&2
                return 1
                ;;
        esac
    done

    # Validate both profile and instance_id are provided
    if [[ -z "$profile" || -z "$instance_id" ]]; then
        echo "Usage: ssm -p <profile> -t <instance_id>"
        return 1
    fi

    # Start the SSM session
    aws ssm start-session --profile "$profile" --target "$instance_id"
}
# List largest files in working directory
lf() {
    du -h -x -s -- * | sort -r -h | head -20;
}

# Search through your history for previous run commands
hg() {
    history | grep "$1";
}

export HISTSIZE=1000000
export HISTFILESIZE=1000000000

source ~/.bash_alias

# This function can be used to unset the proxy variables (when using the terminal outside the corporate network)
noproxy () {
    envVars=( http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY )

    for var in "${envVars[@]}"
    do
        unset $var
    done
}

# This function is used to set the proxy settings (called below)
chproxy () {
    proxy="http://websenseproxy.internal.ch:8080"
    export http_proxy=http://websenseproxy.internal.ch:8080
    export http_proxy=$proxy
    export https_proxy=$proxy
    export HTTP_PROXY=$proxy
    export HTTPS_PROXY=$proxy
    export no_proxy="localhost,127.0.0.1,*.orctel.internal,*.ch.dev,chs-dev,chs-mongo,chs-kafka,chs-dev.internal,*.chs-dev.internal"
    export NO_PROXY=$no_proxy
}

chproxy

export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/python@3.14/libexec/bin:$PATH"


# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/lmarshallafzal/.lmstudio/bin"
