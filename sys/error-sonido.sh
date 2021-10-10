#! /bin/bash
for (( i=0; i<1; i++ ))
do
	for (( j=0; j<4; j++ ))
		do
			sudo timeout .3 speaker-test --frequency 800 --test sine > /dev/null 2>&1
			/bin/bash -c "sleep 0.2"
	done
done
