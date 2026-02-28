#!/usr/bin/env bash

# Warns if a device is already connected
if [[ -n "$(bluetoothctl devices Connected)" ]]; then
	echo 	"device '$(bluetoothctl devices Connected | cut '-d ' -f 3-)'"\
		"is already connected, 5 seconds to exit (Ctrl+C) before"\
		"disconnecting"

	sleep 5s
	bluetoothctl 	disconnect "$(bluetoothctl devices Connected |\
			awk '-F ' '{print $2}')" >/dev/null
fi

# Prints all available devices
devices="$(bluetoothctl devices Trusted | cut '-d ' -f 2-)"
maxchoice="$(echo "$devices" | wc -l)"
for i in $(seq 1 "$maxchoice"); do
	printf "[%d]: "	"$i"
	printf "%s> "	"$(echo "$devices" | head -n$i | tail -n1 |\
			cut '-d ' -f 2-)"
	printf "%s\n"	"$(echo "$devices" | head -n$i | tail -n1 |\
			awk '-F ' '{print $1}')"
done

# Asks which device to connect to
while true; do
	printf "Choose an option (number): "
	read choice
	if [[ "$choice" -ge 1 && "$choice" -le "$maxchoice" ]]; then
		DEVICE="$(echo "$devices" | head -n$choice |\
			tail -n1 | awk '-F ' '{print $1}')"
		break;
	fi

	echo Invalid option, please enter another one
done

# Connects to the device
bluetoothctl connect $DEVICE >/dev/null
