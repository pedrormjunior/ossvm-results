SHELL = bash
NICE = nice -n 19

all:
	@echo 'Explicitly type one of the following options:'
	@echo '   - make plot_CD: for generating the Critical Difference diagrams'
	@echo '   - make GS_comparison: for performing statistical comparison of'
	@echo '     closed- and open-set grid search approaches'

plot_CD:
	@${NICE} ./$@.py

TABLESDIR=tables_openvsclosed
define openvsclosed-table   # open versus closed statistical table of comparison
	mkdir -p ${TABLESDIR}
	cat table-preamble.tex > ${TABLESDIR}/table-${1}.tex
	Rscript --vanilla openvsclosed.R ${1} >> ${TABLESDIR}/table-${1}.tex
	if which pdflatex &> /dev/null; then \
		cd ${TABLESDIR}; \
		pdflatex table-${1}.tex; \
		if which convert &> /dev/null; then \
			convert -density 300 table-${1}.pdf table-${1}.png; \
		fi; \
	fi;
endef

GS_comparison:
	$(call openvsclosed-table,binomial)
	$(call openvsclosed-table,wilcoxon)

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
