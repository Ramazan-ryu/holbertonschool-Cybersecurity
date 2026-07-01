#!/bin/bash
dig +short NS astralis-cloud.example | head -n 1 | sed 's/\.$//'
