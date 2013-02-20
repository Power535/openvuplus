#!/bin/sh

machine_list="vusolo bm750 vuuno vuultimo vusolo2"
for m in $machine_list
do
	echo "build $m.."
	make MACHINE=$m image
done
