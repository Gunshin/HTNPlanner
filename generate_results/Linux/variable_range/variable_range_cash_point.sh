
domain_location="../../../pddlexamples/test/cash_withdraw/domain.pddl"
problem_location="../../../pddlexamples/test/cash_withdraw/pfile0"

domain_sizes=("20" "50" "100" "250" "500" "1000" "2500" "5000" "10000")
atm1=("50" "125" "250" "625" "1250" "2500" "6250" "12500" "25000")
atm2=("100" "250" "500" "1250" "2500" "5000" "12500" "25000" "50000")
ratios=("0.001" "0.01" "0.1" "0.2" "0.3" "0.4" "0.5" "0.6" "0.7" "0.8" "0.9" "1")
increment_amount=("20" "10" "5" "1")

pushd "../../../builds/"
haxe "./JavaBuild.hxml"
popd

for ratio in ${ratios[*]}
do
echo ${ratio}
    for inc in ${increment_amount[*]}
    do
	    for index in 0 1 2 3 4 5 6 7 8
	    do
		    echo ${domain_sizes[index]}
		    timeout 2h java -jar ../../../bin/java/Main.jar "cashpoint" $domain_location $problem_location ${domain_sizes[index]} ${atm1[index]} ${atm2[index]} $inc $ratio
	    done
	done
done
