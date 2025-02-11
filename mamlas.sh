processingJava="/home/ddt/Downloads/processing-4.3.2/processing-java"
processing="/home/ddt/Downloads/processing-4.3.2/processing"
mamlaspath="/home/ddt/Documents/mamlas1"

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
            $processingJava --sketch=$mamlaspath/processing --output=$mamlaspath/build --variant=linux-aarch64 --force --export
            ;;
	"pull")
	    cd $mamlaspath && git pull
	    cd $currentpath
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
