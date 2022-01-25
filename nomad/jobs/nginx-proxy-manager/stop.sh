#!/usr/bin/env bash

JOB_NAME="nginx-proxy-manager"

nomad job stop --purge ${JOB_NAME}
