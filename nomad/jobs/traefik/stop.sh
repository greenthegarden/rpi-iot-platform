#!/usr/bin/env bash

JOB_NAME="traefik"

nomad job stop --purge ${JOB_NAME}
