for i in ../examples/*.beer; do
	echo $i;
	bn=`basename $i .beer`;
	./bin/cli $i > "out/$bn.out"
done;

for i in *.nit; do
	nitc $i
	bn=`basename $i .nit`
	if [ -e $bn ]; then
		./$bn > "out/$bn.out";
	fi;
	rm $bn
done
