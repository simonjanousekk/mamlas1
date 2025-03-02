. config.sh
function mamlas ()
{
    local cmd="$1"
    local currentpath=$(pwd)
    
    export DISPLAY=:0

    case "$cmd" in
        "open")
            $processing $mamlaspath/processing/processing.pde
            ;;
        "dev")
            $processingJava --sketch=$mamlaspath/processing --run
            ;;
        "run")
            "$mamlaspath/build/processing"
            ;;
        "build")
            $processingJava --sketch=$mamlaspath/processing --output=$mamlaspath/build \
                --variant=linux-aarch64 --force --export
            ;;
        "pull")
            cd $mamlaspath && git pull
            cd $currentpath
            ;;
        "help")
            echo "Mamlas-1"
            echo "  open    - Opens the Processing sketch located at $mamlaspath/processing/processing.pde"
            echo "  dev     - Runs the Processing sketch in development mode using Java."
            echo "  run     - Runs the Processing build located at $mamlaspath/build/processing"
            echo "  build   - Builds the Processing sketch for the Linux AArch64 platform."
            echo "  pull    - Pulls the latest changes from the Git repository in $mamlaspath."
            echo "  (no command) - Changes the working directory to $mamlaspath."
            ;;
        "")
            echo "No command provided. Changing directory to $mamlaspath."
            cd $mamlaspath
            ;;
        *)
            echo "Unknown command: $cmd"
            return 1
            ;;
    esac
}

