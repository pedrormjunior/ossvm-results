library(dplyr)
library(tidyr)

options(width=180)
options(scipen=100)

digits <- 10
nsmall <- 10

verbose2 <- function(expr) print(expr)
## verbose2 <- function(expr) NULL #comment this line for verbose output;
verbose <- function(expr) print(expr)
## verbose <- function(expr) NULL #comment this line for EVEN MORE
                               #verbose output; if you comment this
                               #line, comment the verbose2 NULL line
                               #as well;

proposed_method_open <- "ssvmO"
proposed_method_closed <- "ssvmC"
proposed_method <- "ssvm"

## Classifiers that perform open-set grid search.
classifiers_open <- c("svmO", "ocsvmO", "svmdbcO", "onevsetO", "wsvmO", "pisvmO", "svddO", proposed_method_open)
## Classifiers that perform closed-set grid search.
classifiers_closed <- c("svmC", "ocsvmC", "svmdbcC", "onevsetC", "wsvmC", "pisvmC", "svddC", proposed_method_closed)
## Classifiers that perform both open- and closed-set grid search, with the proposed method with open-set grid search as the last entry (for comparison purpose).
classifiers_open_all <- c("svmO", "svmC", "ocsvmO", "ocsvmC", "svmdbcO", "svmdbcC", "onevsetO", "onevsetC", "wsvmO", "wsvmC", "pisvmO", "pisvmC", "svddO", "svddC", proposed_method_open)
## Classifiers that perform both open- and closed-set grid search, with the proposed method with closed-set grid search as the last entry (for comparison purpose).
classifiers_closed_all <- c("svmO", "svmC", "ocsvmO", "ocsvmC", "svmdbcO", "svmdbcC", "onevsetO", "onevsetC", "wsvmO", "wsvmC", "pisvmO", "pisvmC", "svddO", "svddC", proposed_method_closed)
## Classifiers that perform both open-set grid search, with the proposed method with closed-set grid search as the last entry (for comparison purpose).
classifiers_open_proposed_closed<- c("svmC", "ocsvmO", "svmdbcO", "onevsetO", "wsvmO", "pisvmO", "svddC", proposed_method_closed)

classifiers <- c("svm", "ocsvm", "svmdbc", "onevset", "wsvm", "pisvm", "svdd", proposed_method)

classifiers_open_unbalanced <- classifiers_open[classifiers_open != 'wsvmO']
classifiers_closed_unbalanced <- classifiers_closed[classifiers_closed != 'wsvmC']
classifiers_open_ocbb <- c("ocbbsvmC", "ocbbsvmO", "ocbbsvm_OVO", "svddbbC", "svddbbO", "svddbb_OVO", proposed_method_open)

stopifnot(length(classifiers_open) == length(classifiers_closed))
stopifnot(tail(classifiers_open, 1) == proposed_method_open)
stopifnot(tail(classifiers_closed, 1) == proposed_method_closed)

printLaTeXPValues <- function(metric, booleans, pvalues) {
    ## booleans: if TRUE, it will indicate the expected result
    ## happened; command \pvalue{pvalue}{boolean} should be properly
    ## programmed in manuscript; it assumes \usepackage{glossaries} is
    ## used in manuscript;
    stopifnot(all(names(booleans) == names(pvalues)))
    latexoutput <- data.frame(booleans, pvalues)
    cat(sprintf("\\glstext{%s}", metric))
    for(i in 1:nrow(latexoutput)) {
        cat(sprintf(" & \\pvalue{%s}{%d}",
                    format(latexoutput[i, 2], nsmall=nsmall, digits=digits),
                    latexoutput[i, 1]))
    }
    cat(" \\\\\n")
}

read.stat.file <- function(metric, stat.file.type) {
    stopifnot(stat.file.type == "normal" || stat.file.type == "ocbb" || stat.file.type == "unbalanced" || stat.file.type == "onlyImageNet" || stat.file.type == "onlyCIFAR10" || stat.file.type == "onlyMNIST")
    switch(stat.file.type,
           normal = read.csv(paste0("statcsv_ossvm_R3_normal/stat___", metric, ".csv")),
           ocbb = read.csv(paste0("statcsv_ossvm_R3_normal_ocbb/stat___", metric, ".csv")),
           unbalanced = read.csv(paste0("statcsv_ossvm_R3_unbalanced_open/stat___", metric, ".csv")),
           onlyImageNet = read.csv(paste0("statcsv_ossvm_R3_onlyImageNet/stat___", metric, ".csv")),
           onlyCIFAR10 = read.csv(paste0("statcsv_ossvm_R3_onlyCIFAR10/stat___", metric, ".csv")),
           onlyMNIST = read.csv(paste0("statcsv_ossvm_R3_onlyMNIST/stat___", metric, ".csv")))
}

runBinomial <- function(metric, classifiers, stat.file.type, datasetname, acs) {
    verbose2(paste0(">>>>>>>>>>>>>>>> ", toupper(metric), " <<<<<<<<<<<<<<<<"))
    stopifnot(classifiers[length(classifiers)] == proposed_method_open || classifiers[length(classifiers)] == proposed_method_closed)
    stopifnot(missing(datasetname) || missing(acs))

    proposed_method <- classifiers[length(classifiers)]
    baselines <- classifiers[classifiers != proposed_method]
    is.proposed.open <- proposed_method == proposed_method_open

    nacc <- read.stat.file(metric, stat.file.type)
    if(! missing(datasetname)) {
        nacc <- nacc[nacc$dataset == datasetname,]
        levels(nacc$dataset) <- factor(nacc$dataset)
    }
    if(! missing(acs)) {
        nacc <- nacc[nacc$lenacs == acs,]
    }
    y <- spread(nacc, classifier, result)
    yy <- y[, classifiers]

    {
        verbose(paste0("Sign test (", if(is.proposed.open) "open" else "closed", ") --- winning cases"))
        counter <- t(mapply(function(baseline) apply(apply(yy[, c(proposed_method, baseline)], 1, function(x) { x == max(x) }), 1, sum), baselines))
        colnames(counter) <- c(proposed_method, "other")
        verbose(counter)
        proposed_method_wins <- counter[, proposed_method] >= counter[, "other"]
        verbose2(paste(paste0('(sign ', if(is.proposed.open) "open" else "closed", ') Methods with more winning cases than proposed method:'), paste(names(proposed_method_wins[! proposed_method_wins]), collapse=', ')))
        ## stopifnot(all(proposed_method_wins))

        nn <- dim(yy)[1]
        p.values.raw <- yy %>% summarize_each_(funs(binom.test(sum((if(is.proposed.open) ssvmO else ssvmC) > .), nn)$p.value), baselines)

        verbose(paste0("Sign test (", if(is.proposed.open) "open" else "closed", ") --- p-values with holm correction"))
        zz <- round(p.adjust(as.numeric(p.values.raw[1, ]), method="holm"), 10)
        names(zz) <- baselines
        verbose(as.matrix(zz))
        printLaTeXPValues(metric, proposed_method_wins, zz)
    }
}

runWilcoxon <- function(metric, classifiers, stat.file.type, datasetname, acs) {
    verbose2(paste0(">>>>>>>>>>>>>>>> ", toupper(metric), " <<<<<<<<<<<<<<<<"))
    stopifnot(classifiers[length(classifiers)] == proposed_method_open || classifiers[length(classifiers)] == proposed_method_closed)
    stopifnot(missing(datasetname) || missing(acs))

    proposed_method <- classifiers[length(classifiers)]
    baselines <- classifiers[classifiers != proposed_method]
    is.proposed.open <- proposed_method == proposed_method_open

    nacc <- read.stat.file(metric, stat.file.type)
    if(! missing(datasetname)) {
        nacc <- nacc[nacc$dataset == datasetname,]
        levels(nacc$dataset) <- factor(nacc$dataset)
    }
    if(! missing(acs)) {
        nacc <- nacc[nacc$lenacs == acs,]
    }
    y <- spread(nacc, classifier, result)
    yy <- y[, classifiers]

    {
        verbose(paste0("Wilcoxon test (", if(is.proposed.open) "open" else "closed", ") --- mean of the accuracy"))
        aux <- as.matrix(colMeans(yy[, classifiers]))
        verbose(aux)
        proposed_method_wins <- aux[proposed_method, ] >= aux
        verbose2(paste(paste0('(wilcoxon ', if(is.proposed.open) "open" else "closed", ') Methods with better results than proposed method:'), paste(rownames(proposed_method_wins)[! proposed_method_wins], collapse=', ')))
        ## stopifnot(all(proposed_method_wins))

        if(length(table(nacc$dataset)) > 1 && length(table(nacc$lenacs)) > 1) {
            ## When performing statistical test among several datasets
            ## and several numbers of available classes, perform the
            ## mean of the 10 experiments performed for each number of
            ## available classes, for each dataset, and for each
            ## method.  It means that when performing statistical
            ## testes per dataset or per number of available classes,
            ## we do not take the mean of the 10 experiments.
            xnacc <- nacc %>% group_by(lenacs, dataset, classifier) %>% summarise(nacc=mean(result))
            y <- spread(xnacc, classifier, nacc)
            yy <- y[, classifiers]
        }

        p.values.raw <- yy %>% summarize_each_(funs(wilcox.test(., if(is.proposed.open) ssvmO else ssvmC, paired=T)$p.value), baselines)

        zz <- round(p.adjust(as.numeric(p.values.raw[1, ]), method="holm"), 10)
        names(zz) <- baselines
        verbose(paste0("Wilcoxon test (", if(is.proposed.open) "open" else "closed", ") --- p-values with holm correction"))
        verbose(as.matrix(zz))
        printLaTeXPValues(metric, proposed_method_wins[-length(proposed_method_wins)], zz)
    }
}

runBinomialOpenVsClosed <- function(metric, datasetname, acs) {
    verbose2(paste0(">>>>>>>>>>>>>>>> ", toupper(metric), " <<<<<<<<<<<<<<<<"))
    stopifnot(missing(datasetname) || missing(acs))

    nacc <- read.stat.file(metric, "normal")
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
            c(sum(mapply(function(vo, vc) vo > vc, y[[o]], y[[c]])), sum(mapply(function(vo, vc) vo < vc, y[[o]], y[[c]]))) }, classifiers_open, classifiers_closed))
        colnames(acc_comparison) <- c("open", "closed")
        rownames(acc_comparison) <- classifiers
        verbose(acc_comparison)
        openset_wins <- acc_comparison[, "open"] >= acc_comparison[, "closed"]
        verbose2(paste('(sign openvsclosed) Methods for which its closed-set grid search version performs better:', paste(names(openset_wins[! openset_wins]), collapse=', ')))
        ## stopifnot(all(openset_wins))

        verbose("Sign test --- open vs close comparison --- p-values")
        oxc <- data.frame(alg=classifiers_open, p.value=rep(NA, length(classifiers_open)))
        for (i in 1:length(classifiers_open))
            oxc[i, 2] <- round(binom.test(sum(y[[classifiers_open[i]]] > y[[classifiers_closed[i]]]), length(y[[classifiers_open[i]]]))$p.value, 10)
        oxc$alg <- classifiers
        verbose(oxc)
        printLaTeXPValues(metric, openset_wins, oxc$p.value)
    }
}

runWilcoxonOpenVsClosed <- function(metric, datasetname, acs) {
    verbose2(paste0(">>>>>>>>>>>>>>>> ", toupper(metric), " <<<<<<<<<<<<<<<<"))
    stopifnot(missing(datasetname) || missing(acs))

    nacc <- read.stat.file(metric, "normal")
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
        acc_comparison <- t(mapply(function (o, c) { c(mean(y[[o]]), mean(y[[c]])) }, classifiers_open, classifiers_closed))
        colnames(acc_comparison) <- c("open", "closed")
        rownames(acc_comparison) <- classifiers
        verbose(acc_comparison)
        openset_wins <- acc_comparison[, "open"] >= acc_comparison[, "closed"]
        verbose2(paste('(wilcoxon openvsclosed) Methods for which its closed-set grid search version performs better:', paste(names(openset_wins[! openset_wins]), collapse=', ')))
        ## stopifnot(all(openset_wins))

        verbose("Wilcoxon test --- open vs close comparison --- p-values")
        oxc <- data.frame(alg=classifiers_open, p.value=rep(NA, length(classifiers_open)))
        for (i in 1:length(classifiers_open))
            oxc[i, 2] <- round(wilcox.test(y[[classifiers_open[i]]], y[[classifiers_closed[i]]], paired=T)$p.value, 10)
        oxc$alg <- classifiers
        verbose(oxc)
        printLaTeXPValues(metric, openset_wins, oxc$p.value)
    }
}

measures <- c(
    "na",                         # normalized accuracy
    "harmonicNA",                 # harmonic normalized accuracy
    "mafm",                       # macro-averaging open-set f-measure
    "mifm",                       # micro-averaging open-set f-measure
    "bbmafm",                     # macro-averaging f-measure
    "bbmifm"                      # micro-averaging f-measure
)

datasets <- c(
    "15scenes_bow_soft_max_1000",
    "aloi_bic",
    "auslan",
    "caltech256_bow_dense_hard_average_1000",
    "letter",
    "krkopt_pmlb",
    "kddcup_limited"
)

acss <- c(
    3,
    6,
    9,
    12
)

## All experiments for the paper:

cat("\n")
print(">>> runBinomial (open normal)")
for(measure in measures) {
    runBinomial(measure, classifiers_open, "normal", acs=3)
}
cat("\n")
print(">>> runWilcoxon (open normal)")
for(measure in measures) {
    runWilcoxon(measure, classifiers_open, "normal")
}
cat("\n")
print(">>> runBinomial (closed normal)")
for(measure in measures) {
    runBinomial(measure, classifiers_closed, "normal")
}
cat("\n")
print(">>> runWilcoxon (closed normal)")
for(measure in measures) {
    runWilcoxon(measure, classifiers_closed, "normal")
}
cat("\n")
print(">>> runBinomialOpenVsClosed")
for(measure in measures) {
    runBinomialOpenVsClosed(measure)
}
cat("\n")
print(">>> runWilcoxonOpenVsClosed")
for(measure in measures) {
    runWilcoxonOpenVsClosed(measure)
}

for(datasetname in datasets) {
    cat("\n")
    print(datasetname)
    print(">>> runBinomial (open normal)")
    for(measure in measures) {
        runBinomial(measure, classifiers_open, "normal", datasetname)
    }
    cat("\n")
    print(">>> runWilcoxon (open normal)")
    for(measure in measures) {
        runWilcoxon(measure, classifiers_open, "normal", datasetname)
    }
    cat("\n")
    print(">>> runBinomial (closed normal)")
    for(measure in measures) {
        runBinomial(measure, classifiers_closed, "normal", datasetname)
    }
    cat("\n")
    print(">>> runWilcoxon (closed normal)")
    for(measure in measures) {
        runWilcoxon(measure, classifiers_closed, "normal", datasetname)
    }
    cat("\n")
    print(">>> runBinomialOpenVsClosed")
    for(measure in measures) {
        runBinomialOpenVsClosed(measure, datasetname)
    }
    cat("\n")
    print(">>> runWilcoxonOpenVsClosed")
    for(measure in measures) {
        runWilcoxonOpenVsClosed(measure, datasetname)
    }
}

for(acs in acss) {
    cat("\n")
    print(acs)
    print(">>> runBinomial (open normal)")
    for(measure in measures) {
        runBinomial(measure, classifiers_open, "normal", acs=acs)
    }
    cat("\n")
    print(">>> runWilcoxon (open normal)")
    for(measure in measures) {
        runWilcoxon(measure, classifiers_open, "normal", acs=acs)
    }
    cat("\n")
    print(">>> runBinomial (closed normal)")
    for(measure in measures) {
        runBinomial(measure, classifiers_closed, "normal", acs=acs)
    }
    cat("\n")
    print(">>> runWilcoxon (closed normal)")
    for(measure in measures) {
        runWilcoxon(measure, classifiers_closed, "normal", acs=acs)
    }
    cat("\n")
    print(">>> runBinomialOpenVsClosed")
    for(measure in measures) {
        runBinomialOpenVsClosed(measure, acs=acs)
    }
    cat("\n")
    print(">>> runWilcoxonOpenVsClosed")
    for(measure in measures) {
        runWilcoxonOpenVsClosed(measure, acs=acs)
    }
}

cat("\n")
print(">>> runBinomial (OCBB)")
for(measure in measures) {
    runBinomial(measure, classifiers_open_ocbb, "ocbb")
}
cat("\n")
print(">>> runWilcoxon (OCBB)")
for(measure in measures) {
    runWilcoxon(measure, classifiers_open_ocbb, "ocbb")
}

cat("\n")
print(">>> runBinomial (unbalanced)")
for(measure in measures) {
    runBinomial(measure, classifiers_open_unbalanced, "unbalanced")
}
cat("\n")
print(">>> runWilcoxon (unbalanced)")
for(measure in measures) {
    runWilcoxon(measure, classifiers_open_unbalanced, "unbalanced")
}

cat("\n")
print(">>> runBinomial (open imagenet)")
for(measure in measures) {
    runBinomial(measure, classifiers_open, "onlyImageNet")
}
cat("\n")
print(">>> runWilcoxon (open imagenet)")
for(measure in measures) {
    runWilcoxon(measure, classifiers_open, "onlyImageNet")
}

## cat("\n")
## print(">>> runBinomial (open-closed imagenet)")
## for(measure in measures) {
##     runBinomial(measure, classifiers_open_proposed_closed, "onlyImageNet")
## }
## cat("\n")
## print(">>> runWilcoxon (open-closed imagenet)")
## for(measure in measures) {
##     runWilcoxon(measure, classifiers_open_proposed_closed, "onlyImageNet")
## }

## cat("\n")
## print(">>> runBinomial (open-all imagenet)")
## for(measure in measures) {
##     runBinomial(measure, classifiers_open_all, "onlyImageNet")
## }
## cat("\n")
## print(">>> runWilcoxon (open-all imagenet)")
## for(measure in measures) {
##     runWilcoxon(measure, classifiers_open_all, "onlyImageNet")
## }

## cat("\n")
## print(">>> runBinomial (closed-all imagenet)")
## for(measure in measures) {
##     runBinomial(measure, classifiers_closed_all, "onlyImageNet")
## }
## cat("\n")
## print(">>> runWilcoxon (closed-all imagenet)")
## for(measure in measures) {
##     runWilcoxon(measure, classifiers_closed_all, "onlyImageNet")
## }

cat("\n")
print(">>> runBinomial (open CIFAR10)")
for(measure in measures) {
    runBinomial(measure, classifiers_open, "onlyCIFAR10")
}
cat("\n")
print(">>> runWilcoxon (open CIFAR10)")
for(measure in measures) {
    runWilcoxon(measure, classifiers_open, "onlyCIFAR10")
}

## cat("\n")
## print(">>> runBinomial (open-closed CIFAR10)")
## for(measure in measures) {
##     runBinomial(measure, classifiers_open_proposed_closed, "onlyCIFAR10")
## }
## cat("\n")
## print(">>> runWilcoxon (open-closed CIFAR10)")
## for(measure in measures) {
##     runWilcoxon(measure, classifiers_open_proposed_closed, "onlyCIFAR10")
## }

## cat("\n")
## print(">>> runBinomial (open-all CIFAR10)")
## for(measure in measures) {
##     runBinomial(measure, classifiers_open_all, "onlyCIFAR10")
## }
## cat("\n")
## print(">>> runWilcoxon (open-all CIFAR10)")
## for(measure in measures) {
##     runWilcoxon(measure, classifiers_open_all, "onlyCIFAR10")
## }

## cat("\n")
## print(">>> runBinomial (closed-all CIFAR10)")
## for(measure in measures) {
##     runBinomial(measure, classifiers_closed_all, "onlyCIFAR10")
## }
## cat("\n")
## print(">>> runWilcoxon (closed-all CIFAR10)")
## for(measure in measures) {
##     runWilcoxon(measure, classifiers_closed_all, "onlyCIFAR10")
## }

cat("\n")
print(">>> runBinomial (open MNIST)")
for(measure in measures) {
    runBinomial(measure, classifiers_open, "onlyMNIST")
}
cat("\n")
print(">>> runWilcoxon (open MNIST)")
for(measure in measures) {
    runWilcoxon(measure, classifiers_open, "onlyMNIST")
}

## cat("\n")
## print(">>> runBinomial (open-closed MNIST)")
## for(measure in measures) {
##     runBinomial(measure, classifiers_open_proposed_closed, "onlyMNIST")
## }
## cat("\n")
## print(">>> runWilcoxon (open-closed MNIST)")
## for(measure in measures) {
##     runWilcoxon(measure, classifiers_open_proposed_closed, "onlyMNIST")
## }

## cat("\n")
## print(">>> runBinomial (open-all MNIST)")
## for(measure in measures) {
##     runBinomial(measure, classifiers_open_all, "onlyMNIST")
## }
## cat("\n")
## print(">>> runWilcoxon (open-all MNIST)")
## for(measure in measures) {
##     runWilcoxon(measure, classifiers_open_all, "onlyMNIST")
## }

## cat("\n")
## print(">>> runBinomial (closed-all MNIST)")
## for(measure in measures) {
##     runBinomial(measure, classifiers_closed_all, "onlyMNIST")
## }
## cat("\n")
## print(">>> runWilcoxon (closed-all MNIST)")
## for(measure in measures) {
##     runWilcoxon(measure, classifiers_closed_all, "onlyMNIST")
## }
