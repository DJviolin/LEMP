#!/bin/bash

fleetctl stop lemp.service; echo "Now sleeping for 60 seconds..."; sleep 60; fleetctl unload lemp.service; fleetctl destroy lemp.service
