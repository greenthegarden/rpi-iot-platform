#!/usr/bin/env bash

JOB_FILE="portainer-docker.hcl"

nomad job run ${JOB_FILE}
