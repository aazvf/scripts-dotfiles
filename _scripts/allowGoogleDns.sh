#!/bin/bash

sudo ufw delete deny out from any to 8.8.8.8
sudo ufw allow out on wlp1s0 from any to 8.8.8.8

