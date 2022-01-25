#!/usr/bin/env bash

JOB_NAME="ingress"

nomad job stop --purge ${JOB_NAME}
