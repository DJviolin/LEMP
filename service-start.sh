#!/bin/bash

fleetctl submit ./lemp.service && fleetctl start lemp.service; fleetctl journal -follow=true -lines=50 lemp
