#!/usr/bin/env bash

JOB_FILE="alertmanager.hcl"

nomad job run ${JOB_FILE}
