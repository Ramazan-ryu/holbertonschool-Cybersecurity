#!/bin/bash
openssl s_client -connect 10.42.173.79:4650 -servername mail.berent.example -crlf -quiet
