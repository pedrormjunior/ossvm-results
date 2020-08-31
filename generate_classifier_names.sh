#!/usr/bin/env bash

fontsize=10

~/Downloads/tex2im/tex2im -z -a 1 -o ${PWD}/figs/evm.png -s ${fontsize} "\mathrm{EVM}"
~/Downloads/tex2im/tex2im -z -a 1 -o ${PWD}/figs/svm.png -s ${fontsize} "\mathrm{SVM}"
~/Downloads/tex2im/tex2im -z -a 1 -o ${PWD}/figs/dbc.png -s ${fontsize} "\mathrm{DBC}"
~/Downloads/tex2im/tex2im -z -a 1 -o ${PWD}/figs/onevset.png -s ${fontsize} "\mathrm{1VS}"
~/Downloads/tex2im/tex2im -z -a 1 -o ${PWD}/figs/ocsvm.png -s ${fontsize} "\mathrm{SVM}^{\mbox{\scriptsize OC}}"
~/Downloads/tex2im/tex2im -z -a 1 -o ${PWD}/figs/svdd.png -s ${fontsize} "\mathrm{SVDD}^{\mbox{\scriptsize OC}}"
~/Downloads/tex2im/tex2im -z -a 1 -o ${PWD}/figs/wsvm.png -s ${fontsize} "\mathrm{WSVM}"
~/Downloads/tex2im/tex2im -z -a 1 -o ${PWD}/figs/pisvm.png -s ${fontsize} "\mathrm{PISVM}"
~/Downloads/tex2im/tex2im -z -a 1 -o ${PWD}/figs/ssvm.png -s ${fontsize} "\mathrm{OSSVM}"

~/Downloads/tex2im/tex2im -z -a 1 -o ${PWD}/figs/NA.png -s ${fontsize} "\mathrm{NA}"
~/Downloads/tex2im/tex2im -z -a 1 -o ${PWD}/figs/HNA.png -s ${fontsize} "\mathrm{HNA}"
~/Downloads/tex2im/tex2im -z -a 1 -o ${PWD}/figs/OSFMmacro.png -s ${fontsize} "\mathrm{OSFM}_{\mbox{\scriptsize M}}"
~/Downloads/tex2im/tex2im -z -a 1 -o ${PWD}/figs/OSFMmicro.png -s ${fontsize} "\mathrm{OSFM}_{\mu}"
~/Downloads/tex2im/tex2im -z -a 1 -o ${PWD}/figs/FMmacro.png -s ${fontsize} "\mathrm{FM}_{\mbox{\scriptsize M}}"
~/Downloads/tex2im/tex2im -z -a 1 -o ${PWD}/figs/FMmicro.png -s ${fontsize} "\mathrm{FM}_{\mu}"
~/Downloads/tex2im/tex2im -z -a 1 -o ${PWD}/figs/AKS.png -s ${fontsize} "\mathrm{AKS}"
~/Downloads/tex2im/tex2im -z -a 1 -o ${PWD}/figs/AUS.png -s ${fontsize} "\mathrm{AUS}"
