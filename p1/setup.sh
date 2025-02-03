#!/bin/bash

if [ -f ./node-token ]; then
	rm -rf ./node-token
	echo "node-token removed"
fi

vagrant up

# if [ -f ./node-token ]; then
# 	rm -rf ./node-token
# 	echo "node-token removed"
# fi