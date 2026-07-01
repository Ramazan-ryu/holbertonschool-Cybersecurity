#!/bin/bash
dig +short NS astralis-cloud.example | head -n 1 | sed 's/\.$//'
dig +short NS @10.42.82.57  | head -n 1 | sed 's/\.$//'
