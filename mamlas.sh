script_path=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

. $script_path/config-default.sh

# source local config only if exists
if [ -f "$script_path/config-local.sh" ]; then
    echo "Sourcing local config."
    . "$script_path/config-local.sh"
fi


function mamlas() {
    local cmd="$1"
    shift  # Shift removes the first argument ($1) so the rest can be processed
    local subcmd="$1"
    
    local currentpath=$(pwd)
    
    export DISPLAY=:0

    case "$cmd" in
        "open")
            $processing "$mamlaspath/processing/processing.pde"
            ;;
        "dev")
            $processingJava --sketch="$mamlaspath/processing" --run
            ;;
        "run")
            "$mamlaspath/build/processing"
            ;;
        "build")
            $processingJava --sketch="$mamlaspath/processing" --output="$mamlaspath/build" \
                --variant=linux-aarch64 --force --export
            ;;
        "pull")
            cd "$mamlaspath" && git pull
            cd "$currentpath"
            ;;
        "arduino")
            case "$subcmd" in
                "build")
                    echo "Building Arduino sketch..."
                    arduino-cli compile --fqbn "$arduino_board" "$mamlaspath/arduino"
                    ;;
                "upload")
                    echo "Uploading to Arduino..."
                    arduino-cli upload -p "$arduino_port" --fqbn "$arduino_board" "$mamlaspath/arduino"
                    ;;
                *)
                    echo "Unknown Arduino command: $subcmd !!!"
                    return 1
                    ;;
            esac
            ;;
        "help")
            echo "Mamlas-1"
            echo "  open            - Opens the Processing sketch located at $mamlaspath/processing/processing.pde"
            echo "  dev             - Runs the Processing sketch in development mode using Java."
            echo "  run             - Runs the Processing build located at $mamlaspath/build/processing"
            echo "  build           - Builds the Processing sketch for the Linux AArch64 platform."
            echo "  pull            - Pulls the latest changes from the Git repository in $mamlaspath."
            echo "  arduino build   - Compiles the Arduino sketch at $mamlaspath/arduino."
            echo "  arduino upload  - Uploads the compiled sketch to the connected Arduino."
            echo "  (no command)    - Changes the working directory to $mamlaspath."
            ;;
        "")
            echo "Changing directory to $mamlaspath."
            cd "$mamlaspath"
            ;;
        *)
            echo "Unknown command: $cmd"
            return 1
            ;;
    esac
}

