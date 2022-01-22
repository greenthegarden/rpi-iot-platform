#!/usr/bin/env bash

JOB_FILE="emqx-edge-docker.hcl"

nomad job validate ${JOB_FILE}
nomad job plan ${JOB_FILE}
