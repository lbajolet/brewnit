#!/bin/bash -e

for i in ../examples/*.beer; do
	echo $i;
	bn=`basename $i .beer`;
	./bin/cli $i > "out/$bn.out" 2>&1
done;

for i in *.nit; do
	bn=`basename $i .nit`
	nitc $i > out/$bn.compile_log 2>&1
	if test -f $bn; then
		./$bn > "out/$bn.out" 2>&1;
	fi;
	if test -f "out/$bn.out" -a -f "sav/$bn.out"; then
		`diff out/$bn.out sav/$bn.out` > "out/$bn.diff"
	fi;
	if test -f "out/$bn.diff" -a ! -s "out/$bn.diff"; then
		echo -e "\e[1;32m[SUCCESS]\e[0m $bn"
	else
		echo -e "\e[1;31m[FAIL]\e[0m $bn"
	fi;
	rm $bn > /dev/null 2>&1
done
