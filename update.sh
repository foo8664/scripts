#!/usr/bin/bash

for id in $(grep -h '^flatpak run' scripts/* | awk '-F ' '{print $3}'); do
	echo $id
	flatpak update "$id"
done
