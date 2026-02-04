#!/bin/bash

tmpfile=$(mktemp /tmp/scratch.XXXXXX.txt)
nvim "$tmpfile"
rm "$tmpfile"
