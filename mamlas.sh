script_path=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

. $script_path/config-default.sh

# source local config only if exists
if [ -f "$script_path/config-local.sh" ]; then
    echo "Sourcing local config."
    . "$script_path/config-local.sh"
fi

function mamlas ()
{
    local cmd="$1"
    local currentpath=$(pwd)
    
    export DISPLAY=:0

    case "$cmd" in
        "open")
            echo "Opening mamlas in processing..."
            $processing $mamlaspath/processing/processing.pde
            ;;
        "dev")
            echo "Running mamlas from .pde files..."
            $processingJava --sketch=$mamlaspath/processing --run
            ;;
        "run")
            echo "Running mamlas from build files..."
            "$mamlaspath/build/processing"
            ;;
        "build")
            echo "Building mamlas run files.."
            $processingJava --sketch=$mamlaspath/processing --output=$mamlaspath/build \
                --variant=linux-aarch64 --force --export
            ;;
        "pull")
            cd $mamlaspath && git pull
            cd $currentpath
            ;;
        "arduino build")
            echo "Building Arduino sketch..."
            arduino-cli compile --fqbn $arduino_board $mamlaspath/arduino
            ;;
        "arduino upload")
            echo "Uploading to Arduino..."
            arduino-cli upload -p $arduino_port --fqbn $arduino_board $mamlaspath/arduino
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
            cd $mamlaspath
            ;;
        *)
            echo "Unknown command: $cmd"
            return 1
            ;;
    esac
}

