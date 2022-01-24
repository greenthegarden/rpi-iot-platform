#!/usr/bin/env bash

JOB_FILE="pushgateway.hcl"

nomad job run ${JOB_FILE}
