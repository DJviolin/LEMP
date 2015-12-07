#!/bin/bash

fleetctl stop lemp.service; fleetctl unload lemp.service; fleetctl destroy lemp.service
