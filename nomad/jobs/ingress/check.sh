#!/usr/bin/env bash

JOB_FILE="nginx.nomad"

nomad job validate ${JOB_FILE}
nomad job plan ${JOB_FILE}
