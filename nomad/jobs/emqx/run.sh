#!/usr/bin/env bash

JOB_FILE="emqx-edge-docker.hcl"

nomad job run ${JOB_FILE}
