#!/usr/bin/env bash

JOB_FILE="nginx.nomad"

nomad job run ${JOB_FILE}
