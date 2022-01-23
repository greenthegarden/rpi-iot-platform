#!/usr/bin/env bash

JOB_FILE="traefik.hcl"

nomad job run ${JOB_FILE}
