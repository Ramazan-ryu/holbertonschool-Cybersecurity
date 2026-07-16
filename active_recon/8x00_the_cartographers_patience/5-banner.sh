#!/bin/bash
openssl s_client -connect mail.berent.example:4650 -servername mail.berent.example -crlf -quiet
