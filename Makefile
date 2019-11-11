SHELL = bash
NICE = nice -n 19

all:
	@echo 'Explicitly type the following:'
	@echo '   - make plot_CD: for generating the Critical Difference diagrams'

plot_CD:
	@${NICE} ./$@.py

###############################################################
### Auxiliary targets locally employed, please ignore them. ###
###############################################################

generate_classifier_names:
	./$@.sh

version = R3v5
get_raw_data:
	rsync -avu pmendes@ssh.recod.ic.unicamp.br:/home/pmendes/Downloads/statcsv_ossvm_${version}_normal .
	rsync -avu pmendes@ssh.recod.ic.unicamp.br:/home/pmendes/Downloads/statcsv_ossvm_${version}_normal_max6 .
	rsync -avu pmendes@ssh.recod.ic.unicamp.br:/home/pmendes/Downloads/statcsv_ossvm_${version}_normal_max9 .
	rsync -avu pmendes@ssh.recod.ic.unicamp.br:/home/pmendes/Downloads/statcsv_ossvm_${version}_onlyImageNet .
	rsync -avu pmendes@ssh.recod.ic.unicamp.br:/home/pmendes/Downloads/statcsv_ossvm_${version}_onlyCIFAR10 .
	rsync -avu pmendes@ssh.recod.ic.unicamp.br:/home/pmendes/Downloads/statcsv_ossvm_${version}_onlyMNIST .

prepare_merged_csv:
	${NICE} ./$@.py
