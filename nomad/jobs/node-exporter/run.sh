#!/usr/bin/env bash

JOB_FILE="node-exporter-docker.hcl"

nomad job run ${JOB_FILE}
