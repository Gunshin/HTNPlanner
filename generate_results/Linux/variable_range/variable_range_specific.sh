
path_location="../../../src/test/result_generation/PartialRangeLargeDomain/"

domain_sizes=("10" "25" "50" "100" "250" "500" "1000" "2500" "5000" "10000")
ratios=("0.001" "0.01" "0.1" "0.2" "0.3" "0.4" "0.5" "0.6" "0.7" "0.8" "0.9" "1")

echo "10000 0.2"
timeout 12h java -jar ../../../bin/java/Main.jar $path_location "10000" "0.2"

echo "5000 0.5"
timeout 12h java -jar ../../../bin/java/Main.jar $path_location "5000" "0.5"

echo "10000 0.5"
timeout 12h java -jar ../../../bin/java/Main.jar $path_location "10000" "0.5"

echo "5000 0.7"
timeout 12h java -jar ../../../bin/java/Main.jar $path_location "5000" "0.7"
