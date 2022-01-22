#!/usr/bin/env bash

JOB_FILE="alertmanager.hcl"

nomad job validate ${JOB_FILE}
nomad job plan ${JOB_FILE}
