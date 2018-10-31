library(dplyr)
library(tidyr)

options(width=180)
options(scipen=100)

digits <- 10
nsmall <- 10

args <- commandArgs(trailingOnly=TRUE)
stat_method = args[1]

verbose2 <- function(expr) print(expr)
verbose2 <- function(expr) NULL #comment this line for verbose output;
verbose <- function(expr) print(expr)
verbose <- function(expr) NULL #comment this line for EVEN MORE
                               #verbose output; if you comment this
                               #line, comment the verbose2 NULL line
                               #as well;

proposed_method_open <- "ssvmO"
proposed_method_closed <- "ssvmC"
proposed_method <- "statssvm"

## Classifiers that perform open-set grid search.
classifiers_open <- c("svmO", "ocsvmO", "svddO", "svmdbcO", "onevsetO", "wsvmO", "pisvmO", "evmO", proposed_method_open)
## Classifiers that perform closed-set grid search.
classifiers_closed <- c("svmC", "ocsvmC", "svddC", "svmdbcC", "onevsetC", "wsvmC", "pisvmC", "evmC", proposed_method_closed)

## Classifiers names independent to the grid search approach.  Those
## names, with prefix "stat" are useful for straightforward inclusion
## in the paper.
classifiers <- c("statsvm", "statocsvm", "statsvdd", "statsvmdbc", "statonevset", "statwsvm", "statpisvm", "statevm", proposed_method)

stopifnot(length(classifiers_open) == length(classifiers_closed))

printLaTeXTable <- function(fOpenVsClosed) {
    cat("\\begin{document}\n")
    cat(paste0("\\begin{tabular}{",
               paste(rep("l", length(classifiers)+1), collapse=""),
               "}\n"))
    cat("\\tabletopline\n")
    cat("Measure")
    for(i in 1:length(classifiers)) {
        cat(sprintf(" & \\glstext{%s}", classifiers[i]))
    }
    cat("\\\\\n")
    cat("\\tablemiddleline\n")
    for(measure in measures) {
        fOpenVsClosed(measure, classifiers_open, classifiers_closed)
    }
    cat("\\tablebottomline\n")
    cat("\\end{tabular}\n")
    cat("\\end{document}\n")
}

printLaTeXPValues <- function(metric, booleans, pvalues) {
    ## booleans: if TRUE, it will indicate the expected result
    ## happened; command \pvalue{pvalue}{boolean} should be properly
    ## programmed in manuscript; it assumes \usepackage{glossaries} is
    ## used in manuscript;
    stopifnot(all(names(booleans) == names(pvalues)))
    latexoutput <- data.frame(booleans, pvalues)
    cat(sprintf("\\glstext{%s}", metric))
    for(i in 1:nrow(latexoutput)) {
        cat(sprintf(" & \\pvalue{%s1}{%d}", #The missing 1 has a
                                            #purpose: make LaTeX
                                            #properly print <.0001
                                            #when resulting p-value is
                                            #0.0000000000.
                    format(latexoutput[i, 2], nsmall=nsmall, digits=digits),
                    latexoutput[i, 1]))
    }
    cat(" \\\\\n")
}

read.stat.file <- function(metric) {
    read.csv(paste0("CSV_files/normal_", metric, ".csv"))
}

runBinomialOpenVsClosed <- function(metric, classifiers_open, classifiers_closed, datasetname, acs) {
    verbose2(paste0(">>>>>>>>>>>>>>>> ", toupper(metric), " <<<<<<<<<<<<<<<<"))
    stopifnot(missing(datasetname) || missing(acs))

    nacc <- read.stat.file(metric)
    if(! missing(datasetname)) {
        nacc <- nacc[nacc$dataset == datasetname,]
        levels(nacc$dataset) <- factor(nacc$dataset)
    }
    if(! missing(acs)) {
        nacc <- nacc[nacc$lenacs == acs,]
    }
    y <- spread(nacc, classifier, result)

    {                               # Sign test
        verbose("Sign test --- open vs closed comparison --- winning cases")
        acc_comparison <- t(mapply(function (o, c) {
            c(sum(mapply(function(vo, vc) vo > vc, y[[o]], y[[c]])),
              sum(mapply(function(vo, vc) vo < vc, y[[o]], y[[c]]))) },
            classifiers_open, classifiers_closed))

        colnames(acc_comparison) <- c("open", "closed")
        classifiers <- mapply(function(classifier) {strsplit(classifier, "_")[[1]][1]}, classifiers_open)
        rownames(acc_comparison) <- classifiers
        verbose(acc_comparison)

        openset_wins <- acc_comparison[, "open"] >= acc_comparison[, "closed"]
        verbose2(paste('(sign openvsclosed) Methods for which its closed-set grid search version performs better:', paste(names(openset_wins[! openset_wins]), collapse=', ')))

        verbose("Sign test --- open vs close comparison --- p-values")
        oxc <- data.frame(alg=classifiers_open, p.value=rep(NA, length(classifiers_open)))
        for (i in 1:length(classifiers_open))
            oxc[i, 2] <- round(binom.test(sum(y[[classifiers_open[i]]] > y[[classifiers_closed[i]]]),
                                          length(y[[classifiers_open[i]]]))$p.value,
                               10)
        oxc$alg <- classifiers
        verbose(oxc)
        printLaTeXPValues(metric, openset_wins, oxc$p.value)
    }
}

runWilcoxonOpenVsClosed <- function(metric, classifiers_open, classifiers_closed, datasetname, acs) {
    verbose2(paste0(">>>>>>>>>>>>>>>> ", toupper(metric), " <<<<<<<<<<<<<<<<"))
    stopifnot(missing(datasetname) || missing(acs))

    nacc <- read.stat.file(metric)
    if(! missing(datasetname)) {
        nacc <- nacc[nacc$dataset == datasetname,]
        levels(nacc$dataset) <- factor(nacc$dataset)
    }
    if(! missing(acs)) {
        nacc <- nacc[nacc$lenacs == acs,]
    }
    y <- spread(nacc, classifier, result)

    {                               # Wilcoxon test
        verbose("Wilcoxon test --- open vs closed comparison --- accuracy")
        acc_comparison <- t(mapply(function (o, c) {
            c(mean(y[[o]]), mean(y[[c]])) },
            classifiers_open, classifiers_closed))

        colnames(acc_comparison) <- c("open", "closed")
        classifiers <- mapply(function(classifier) {strsplit(classifier, "_")[[1]][1]}, classifiers_open)
        rownames(acc_comparison) <- classifiers
        verbose(acc_comparison)

        openset_wins <- acc_comparison[, "open"] >= acc_comparison[, "closed"]
        verbose2(paste('(wilcoxon openvsclosed) Methods for which its closed-set grid search version performs better:', paste(names(openset_wins[! openset_wins]), collapse=', ')))

        verbose("Wilcoxon test --- open vs close comparison --- p-values")
        oxc <- data.frame(alg=classifiers_open, p.value=rep(NA, length(classifiers_open)))
        for (i in 1:length(classifiers_open))
            oxc[i, 2] <- round(wilcox.test(y[[classifiers_open[i]]],
                                           y[[classifiers_closed[i]]],
                                           paired=T)$p.value,
                               10)
        oxc$alg <- classifiers
        verbose(oxc)
        printLaTeXPValues(metric, openset_wins, oxc$p.value)
    }
}

measures <- c(
    "NA",                          #normalized accuracy
    "HNA",                         #harmonic normalized accuracy
    "OSFMM",                       #macro-averaging open-set f-measure
    "OSFMm",                       #micro-averaging open-set f-measure
    "FMM",                         #macro-averaging f-measure
    "FMm"                          #micro-averaging f-measure
)

if(stat_method == "binomial") {
    printLaTeXTable(runBinomialOpenVsClosed)
} else if(stat_method == "wilcoxon") {
    printLaTeXTable(runWilcoxonOpenVsClosed)
} else {
    simpleError("Given argument should be one of the following: binomial, wilcoxon")
}
