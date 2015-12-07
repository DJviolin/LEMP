#!/bin/bash

fleetctl submit /home/core/work/lemp/lemp.service && fleetctl start lemp.service; fleetctl journal -follow=true -lines=50 LEMP
