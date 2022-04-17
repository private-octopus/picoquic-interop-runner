#!/bin/bash

# Set up the routing needed for the simulation
echo "Setting up the simulation with setup.sh"
/setup.sh
echo "Setup.sh completed"

# The following variables are available for use:
# - ROLE contains the role of this execution context, client or server
# - SERVER_PARAMS contains user-supplied command line parameters
# - CLIENT_PARAMS contains user-supplied command line parameters

RET=0
# Verify that the test case is supported 
case "$TESTCASE" in
        "versionnegotiation") RET=0 ;;
        "handshake") RET=0 ;;
        "transfer") RET=0 ;;
        "retry") RET=0 ;;
        "resumption") RET=0 ;;
        "zerortt") RET=0 ;;
        "http3") RET=0 ;;
        "multiconnect") RET=0 ;;
        "chacha20") RET=0 ;;
        "ecn") RET=0;;
        "keyupdate") RET=0;;
        "v2") RET=0;;
        *) echo "Unsupported test case: $TESTCASE"; exit 127 ;;
esac

if [ "$ROLE" == "client" ]; then
    # Wait for the simulator to start up.
    echo "Waiting for  the simulator to start"
    /wait-for-it.sh sim:57832 -s -t 30
    echo "Starting picoquic client for test: $TESTCASE"
    # setup default parameters
    LOGFILE="/logs/test_log.txt"
    TEST_PARAMS="$CLIENT_PARAMS -L -l $LOGFILE -q /logs/qlog -o /downloads -V -0"
    if [ "$TESTCASE" == "http3" ]; then
        TEST_PARAMS="$TEST_PARAMS -a h3";
    else
        TEST_PARAMS="$TEST_PARAMS -a hq-interop";
    fi
    if [ "$TESTCASE" == "versionnegotiation" ]; then
        TEST_PARAMS="$TEST_PARAMS -v 5a6a7a8a";
    else
        TEST_PARAMS="$TEST_PARAMS -v 00000001";
    fi
    if [ "$TESTCASE" == "chacha20" ]; then
        TEST_PARAMS="$TEST_PARAMS -C 20";
    fi
    if [ "$TESTCASE" == "keyupdate" ]; then
        TEST_PARAMS="$TEST_PARAMS -u 32";
    fi
    if [ "$TESTCASE" == "v2" ]; then
        TEST_PARAMS="$TEST_PARAMS -U 709a50c4";
    fi
    echo "Starting picoquic client ..."
    SERVER="server"
    if [ ! -z "$REQUESTS" ]; then
        # Get the server ID out of the first request
        REQS=($REQUESTS)
        REQ1=${REQS[0]}
        echo "Parsing server name from first request: $REQ1"
        SERVER=$(echo $REQ1 | cut -d/ -f3 | cut -d: -f1)
        echo "Server set to: $SERVER"
        # pull requests out of param
        echo "Requests: " $REQUESTS
        for REQ in $REQUESTS; do
            FILE=`echo $REQ | cut -f4 -d'/'`
            echo "parsing <$REQ> as <$FILE>"
            FILELIST=${FILELIST}"-:/"${FILE}";"
        done

        if [ "$TESTCASE" == "resumption" ] ||
           [ "$TESTCASE" == "zerortt" ] ; then
            FILE1=`echo $FILELIST | cut -f1 -d";"`
            FILE2=`echo $FILELIST | cut -f2- -d";"`
            L1="/logs/first_log.txt"
            L2="/logs/second_log.txt"
            echo "File1: $FILE1"
            echo "File2: $FILE2"
            rm *.bin
            echo "/picoquic/picoquicdemo $TEST_PARAMS $SERVER 443 $FILE1"
            /picoquic/picoquicdemo $TEST_PARAMS $SERVER 443 $FILE1
            if [ $? != 0 ]; then
                RET=1
                echo "First call to picoquicdemo failed"
            else
                mv $LOGFILE $L1
                echo "/picoquic/picoquicdemo $TEST_PARAMS $SERVER 443 $FILE2"
                /picoquic/picoquicdemo $TEST_PARAMS $SERVER 443 $FILE2
                if [ $? != 0 ]; then
                    RET=1
                    echo "Second call to picoquicdemo failed"
                fi
                mv $LOGFILE $L2
            fi
        elif [ "$TESTCASE" == "multiconnect" ]; then
            for CREQ in $REQUESTS; do
                CFILE=`echo $CREQ | cut -f4 -d'/'`
                CFILEX="/$CFILE"
                echo "/picoquic/picoquicdemo $TEST_PARAMS $SERVER 443 $CFILEX"
                /picoquic/picoquicdemo $TEST_PARAMS $SERVER 443 $CFILEX
                if [ $? != 0 ]; then
                    RET=1
                    echo "Call to picoquicdemo failed"
                fi
                MCLOG="/logs/mc-$CFILE.txt"
                echo "mv $LOGFILE  $MCLOG"
                mv $LOGFILE $MCLOG
            done
        else
            if [ "$TESTCASE" == "retry" ]; then
                rm *.bin
            fi
            /picoquic/picoquicdemo $TEST_PARAMS $SERVER 443 $FILELIST
            if [ $? != 0 ]; then
                RET=1
                echo "Call to picoquicdemo failed"
            fi
        fi
    fi

### Server side ###
elif [ "$ROLE" == "server" ]; then
    echo "Starting picoquic server for test:" $TESTCASE
    TEST_PARAMS="$SERVER_PARAMS -w ./www -L -l /logs/server_log.txt"
    TEST_PARAMS="$TEST_PARAMS -q /logs/qlog" 
    TEST_PARAMS="$TEST_PARAMS -k /certs/priv.key"
    TEST_PARAMS="$TEST_PARAMS -c /certs/cert.pem"
    TEST_PARAMS="$TEST_PARAMS -p 443 -V -0"
    ls /www
    case "$TESTCASE" in
        "retry") TEST_PARAMS="$TEST_PARAMS -r" ;;
        *) ;;
    esac
    echo "Starting picoquic server ..."
    echo "TEST_PARAMS: $TEST_PARAMS"
    picoquic/picoquicdemo $TEST_PARAMS
    if [ $? != 0 ]; then
        RET=1
        echo "Could not start picoquicdemo"
    fi
    cp /var/crash/* /logs
else
    echo "Unexpected role: $ROLE"
    RET=1
fi
exit $RET
