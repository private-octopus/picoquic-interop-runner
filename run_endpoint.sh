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
        "http3") RET=0 ;;
        *) echo "Unsupported test case: $TESTCASE"; exit 127 ;;
esac

if [ "$ROLE" == "client" ]; then
    # Wait for the simulator to start up.
    echo "Waiting for  the simulator to start"
    /wait-for-it.sh sim:57832 -s -t 30
    echo "Starting picoquic client for test: $TESTCASE"
    LOGFILE="test_log.txt"
    TEST_PARAMS="$CLIENT_PARAMS -l $LOGFILE"
    if [ "$TESTCASE" == "http3" ]; then
        TEST_PARAMS="$TEST_PARAMS -a h3-24";
    else
        TEST_PARAMS="$TEST_PARAMS -a hq-24";
    fi
    if [ "$TESTCASE" == "versionnegotiation" ]; then
        TEST_PARAMS="$TEST_PARAMS -v 5a6a7a8a";
    else
        TEST_PARAMS="$TEST_PARAMS -v ff000018";
    fi
    echo "Starting picoquic client ..."
    if [ ! -z "$REQUESTS" ]; then
        # pull requests out of param
        echo "Requests: " $REQUESTS
        for REQ in $REQUESTS; do
            FILE=`echo $REQ | cut -f4 -d'/'`
            echo "parsing <$REQ> as <$FILE>"
            FILELIST=${FILELIST}"/"${FILE}";"
        done

        if [ "$TESTCASE" == "resumption" ]; then
            FILE1=`echo $FILELIST | cut -f1 -d";"`
            FILE2=`echo $FILELIST | cut -f2- -d";"`
            L1="first_$LOGFILE"
            L2="second_$LOGFILE"
            echo "File1: $FILE1"
            echo "File2: $FILE2"
            rm *.bin
            /picoquic/picoquicdemo $TEST_PARAMS server 443 $FILE1
            if [ $? != 0 ]; then
                RET=1
                echo "First call to picoquicdemo failed"
            else
                mv $LOGFILE $L1
                /picoquic/picoquicdemo $TEST_PARAMS server 443 $FILE2
                if [ $? != 0 ]; then
                    RET=1
                    echo "Second call to picoquicdemo failed"
                fi
                mv $LOGFILE $L2
                cat $L1 $L2 > $LOGFILE
                rm $L1
                rm $L2
            fi
        else
            if [ "$TESTCASE" == "retry" ]; then
                rm *.bin
            fi
            /picoquic/picoquicdemo $TEST_PARAMS server 443 $FILELIST
            if [ $? != 0 ]; then
                RET=1
                echo "Call to picoquicdemo failed"
            fi
        fi
        DOWNLOADS=`ls _*`
        if [ ! -z "$DOWNLOADS" ]; then
            for FILE in $DOWNLOADS; do
                TARGET=`echo $FILE | cut -b2-`
                cp $FILE /downloads/$TARGET
            done
        fi
        echo "Picoquic LOG: "
        cat $LOGFILE
        # cleanup
    fi

### Server side ###
elif [ "$ROLE" == "server" ]; then
    echo "Starting picoquic server for test:" $TESTCASE
    TEST_PARAMS="$SERVER_PARAMS -l server_log.txt -w /www"
    TEST_PARAMS="$TEST_PARAMS -k picoquic/certs/key.pem"
    TEST_PARAMS="$TEST_PARAMS -c picoquic/certs/cert.pem"
    TEST_PARAMS="$TEST_PARAMS -p 443"
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
else
    echo "Unexpected role: $ROLE"
    RET=1
fi
exit $RET
