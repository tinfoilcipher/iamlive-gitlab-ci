#!/usr/bin/env bash
OUTPUT_PATH=${IAMLIVE_OUTPUT_PATH}
ADDITIONAL_ARGS=${IAMLIVE_ADDITIONAL_ARGS}
FORCE_WILDCARDS=${IAMLIVE_FORCE_RESOURCE_WILDCARDS}
FAILS_ONLY=${IAMLIVE_FAILS_ONLY}
CA_DIR=${IAMLIVE_CA_DIR}

#--CA Bootstrapping. This is technically duplicating in-app functionality
#--which has no interface or easy way to move files around.
if [ ! -d "${CA_DIR}" ]; then
  mkdir -p "${CA_DIR}";
fi

openssl genrsa -out "$CA_DIR/ca.key" 2048
openssl req -new -x509 \
    -days "1" \
    -key "${CA_DIR}/ca.key" \
    -out "${CA_DIR}/ca.pem" \
    -subj "/C=GB/O=iamlive"

echo "Bootstrapped CA!"
echo "Resultant policy document will be saved to ${OUTPUT_PATH}"

#--Main process
if [ "${FORCE_WILDCARDS}" ]
then
    ADDITIONAL_ARGS="${ADDITIONAL_ARGS} -force-wildcard-resource"
fi

if [ "${FAILS_ONLY}" ]
then
    ADDITIONAL_ARGS="${ADDITIONAL_ARGS} -fails-only"
fi

echo "Starting iamlive. Listening for API Calls..."

#--Run iamlive as a background process and assign PID to a variable.
PID="$(iamlive \
    -output-file $OUTPUT_PATH \
    -mode proxy \
    -background \
    -bind-addr 0.0.0.0:10080 \
    -ca-bundle $CA_DIR/ca.pem \
    -ca-key $CA_DIR/ca.key \
    $ADDITIONAL_ARGS)"

#--This scary looking chain of commands starts a netcat server and issues
#--a SIGHUP to iamlive on receipt of an HTTP 200 (I.E. a curl or a GET).
#--The sleep has been added to allow time for the policy file to write to disk.
nc -lv -p 10081 <<< 'HTTP/1.1 200 OK' && kill -HUP "$PID" && sleep 5
echo "Hanging Up..."
