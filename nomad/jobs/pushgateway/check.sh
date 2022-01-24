#!/usr/bin/env bash

JOB_FILE="pushgateway.hcl"

nomad job validate ${JOB_FILE}
nomad job plan ${JOB_FILE}
