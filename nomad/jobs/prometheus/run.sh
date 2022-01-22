#!/usr/bin/env bash

JOB_FILE="prometheus-docker.hcl"

nomad job run ${JOB_FILE}
