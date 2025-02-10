processing="~/Downloads/processing-4.3.2/processing-java"
alias processing="~/Downloads/processing-4.3.2/processing-java"
alias updatebash="source ~/.bashrc"

mamlaspath="/home/ddt/Documents/mamlas1"


function mamlas() {
    case "$1" in
        "run")
            processing --sketch="$mamlaspath/processing" --run
            ;;
        "dev")
            processing --sketch="$mamlaspath/processing" --run
            ;;
        "build")
            processing --sketch="$mamlaspath/processing" --output="$mamlaspath/build" --variant=linux-aarch64 --force
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

