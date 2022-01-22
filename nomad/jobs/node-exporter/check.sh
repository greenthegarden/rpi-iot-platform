#!/usr/bin/env bash

JOB_FILE="node-exporter-docker.hcl"

nomad job validate ${JOB_FILE}
nomad job plan ${JOB_FILE}
