#! /bin/bash

if [ "$1" = "reset" ]; then
    CURR_MEASURE_INDEX=0
fi
CURR_MEASURE_INDEX=${CURR_MEASURE_INDEX:-0}
CURR_MEASURE_INDEX=$((CURR_MEASURE_INDEX + 1))

ROM_PHASE=$(grep -a -i "ROM phase" boot_full.log | sed -E 's/.* \(([0-9]+\.[0-9]+) ms\).*/\1/')
FSBL_START=$(grep -a -i "SCS/" boot_full.log | sed -E 's/^\[([0-9]+\.[0-9]+).*/\1/')
OPENSBI_START=$(grep -a -i "OpenSBI v0.9" boot_full.log | sed -E 's/^\[([0-9]+\.[0-9]+).*/\1/')
UBOOT_START=$(grep -a -i "U-Boot 2021.10" boot_full.log | sed -E 's/^\[([0-9]+\.[0-9]+).*/\1/')
KERNEL_START=$(grep -a -i "Starting kernel ..." boot_full.log | sed -E 's/^\[([0-9]+\.[0-9]+).*/\1/')
USERSPACE_START=$(grep -a -i "Run /sbin/init" boot_full.log | sed -E 's/^\[([0-9]+\.[0-9]+).*/\1/')
APP_START=$(grep -a -i "Temperature sent" boot_full.log | sed -E 's/^\[([0-9]+\.[0-9]+).*/\1/')

FSBL_PHASE=$(printf "%.3f" "$(echo "($OPENSBI_START - $FSBL_START) * 1000" | bc)")
OPENSBI_PHASE=$(printf "%.3f" "$(echo "($UBOOT_START - $OPENSBI_START) * 1000" | bc)")
UBOOT_PHASE=$(printf "%.3f" "$(echo "($KERNEL_START - $UBOOT_START) * 1000" | bc)")
KERNEL_PHASE=$(printf "%.3f" "$(echo "($USERSPACE_START - $KERNEL_START) * 1000" | bc)")
USERSPACE_PHASE=$(printf "%.3f" "$(echo "($APP_START - $USERSPACE_START) * 1000" | bc)")
TOTAL_TIME=$(printf "%.3f" "$(echo "($APP_START - $FSBL_START) * 1000" | bc)")

echo "
	Measurment number $CURR_MEASURE_INDEX:
		1)ROM Time: $ROM_PHASE ms
		2)FSBL Time: $FSBL_PHASE ms
		3)OpenSBI Time: $OPENSBI_PHASE ms
		4)U-Boot Time: $UBOOT_PHASE ms
		5)Kernel Time: $KERNEL_PHASE ms
		6)Userspace Time: $USERSPACE_PHASE ms
		7)Total Time: $TOTAL_TIME ms + $ROM_PHASE ms
"  >> all_measurments.log
