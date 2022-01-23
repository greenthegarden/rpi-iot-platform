#!/usr/bin/env bash

JOB_FILE="pihole.nomad"

nomad job run ${JOB_FILE}
