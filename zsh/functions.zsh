################################################################
#                                                              #
#                            FUNCTIONS                         #
#                                                              #
################################################################

function mcd (){
  mkdir $1
  cd $1
}

function server(){
  python2.7 -m SimpleHTTPServer
}

function temp(){
    while true 
        do istats cpu; istats fan
        sleep 30 
    done
}
