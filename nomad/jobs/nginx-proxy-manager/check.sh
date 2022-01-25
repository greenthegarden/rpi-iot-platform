#!/usr/bin/env bash

JOB_FILE="nginx-proxy-manager.nomad"

nomad job validate ${JOB_FILE}
nomad job plan ${JOB_FILE}
