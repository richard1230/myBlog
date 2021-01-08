#!/bin/bash
echo $1 |awk '{print length($1)}'
