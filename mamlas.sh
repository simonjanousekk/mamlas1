processing="$HOME/Downloads/processing-4.3.2/processing-java"
mamlaspath="$HOME/Documents/mamlas1"

function mamlas ()
{
    local cmd="$1"

    case "$cmd" in
        "dev")
            "$processing" --sketch="$mamlaspath/processing" --run
            ;;
	"run")
	    "$mamlaspath/build/processing"
	    ;;
        "build")
            "$processing" --sketch="$mamlaspath/processing" --output="$mamlaspath/build" --variant=linux-aarch64 --force
            ;;
        "")
            cd "$mamlaspath"
            ;;
        *)
            echo "Unknown command: $cmd"
            return 1
            ;;
    esac
}
