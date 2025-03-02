function mamlas ()
{
    local cmd="$1"
    local currentpath=$(pwd)
    
    export DISPLAY=:0

    case "$cmd" in
        "open")
            echo "Opens the Processing sketch located at $mamlaspath/processing/processing.pde"
            $processing $mamlaspath/processing/processing.pde
            ;;
        "dev")
            echo "Runs the Processing sketch in development mode using Java."
            $processingJava --sketch=$mamlaspath/processing --run
            ;;
        "run")
            echo "Runs the Processing build located at $mamlaspath/build/processing"
            "$mamlaspath/build/processing"
            ;;
        "build")
            echo "Builds the Processing sketch for the Linux AArch64 platform."
            $processingJava --sketch=$mamlaspath/processing --output=$mamlaspath/build \
                --variant=linux-aarch64 --force --export
            ;;
        "pull")
            echo "Pulls the latest changes from the Git repository in $mamlaspath."
            cd $mamlaspath && git pull
            cd $currentpath
            ;;
        "help")
            echo "Available commands and their explanations:"
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

