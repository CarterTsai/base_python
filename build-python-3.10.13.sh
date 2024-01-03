#!/bin/bash

docker-compose build && trivy image --scanners vuln  base-python:3.10.13 > vuln.txt