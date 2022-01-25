#!/usr/bin/env bash

JOB_FILE="nginx-proxy-manager.nomad"

nomad job run ${JOB_FILE}
