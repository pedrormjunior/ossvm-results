library(dplyr)
library(tidyr)

options(width=180)
options(scipen=100)

digits=10
nsmall=10

verbose <- function(expr) print(expr)
## verbose <- function(expr) NULL

run <- function(metric) {
    print(paste0(">>>>>>>>>>>>>>>> ", toupper(metric), " <<<<<<<<<<<<<<<<"))
    nacc = read.csv(paste0("stat___", metric, ".csv"))

    proposed_method_open = "ssvmO"
    proposed_method_closed = "ssvmC"
    baselines_open <- c("svmO", "ocsvmO", "svmdbcO", "onevsetO", "wsvmO", "pisvmO")
    baselines_closed <- c("svmC", "ocsvmC", "svmdbcC", "onevsetC", "wsvmC", "pisvmC")
    classifiers_open <- c("svmO", "ocsvmO", "svmdbcO", "onevsetO", "wsvmO", "pisvmO", "ssvmO")
    classifiers_closed <- c("svmC", "ocsvmC", "svmdbcC", "onevsetC", "wsvmC", "pisvmC", "ssvmC")
    classifiers <- c("svm", "ocsvm", "svmdbc", "onevset", "wsvm", "pisvm", "ssvm")

    {   # Statistical tests for classifiers with OPEN-SET grid search.
        {                               # Sign test
            y = spread(nacc, classifier, result)
            yy = y[, classifiers_open]

            verbose("Winning cases (open)")
            counter <- t(mapply(function(baseline) apply(apply(yy[, c(proposed_method_open, baseline)], 1, function(x) { x == max(x) }), 1, sum), baselines_open))
            colnames(counter) = c(proposed_method_open, "other")
            verbose(counter)
            verbose(all(counter[, proposed_method_open] >= counter[, "other"]))
            stopifnot(all(counter[, proposed_method_open] >= counter[, "other"]))

            nn = dim(yy)[1]
            p.values.raw = yy %>% summarize_each(funs(binom.test(sum(ssvmO > .), nn)$p.value),
                                                 c(svmO, ocsvmO, svmdbcO, onevsetO, wsvmO, pisvmO))

            verbose("Sign test (open) --- p-values with holm correction")
            zz = round(p.adjust(as.numeric(p.values.raw[1, ]), method="holm"), 10)
            names(zz) = baselines_open
            verbose(as.matrix(zz))
            print(format(unname(zz), nsmall=nsmall, digits=digits))
        }


        {                               # Wilcoxon test
            verbose("Mean of the accuracy (open)")
            aux <- as.matrix(colMeans(yy[, classifiers_open]))
            verbose(aux)
            verbose(paste("Winning method:", rownames(aux)[which.max(aux)]))
            stopifnot(rownames(aux)[which.max(aux)] == proposed_method_open)

            xnacc = nacc %>% group_by(lenacs, dataset, classifier) %>% summarise(nacc=mean(result))
            y = spread(xnacc, classifier, nacc)
            yy = y[, classifiers_open]

            p.values.raw = yy %>% summarize_each(funs(wilcox.test(., ssvmO, paired=T)$p.value),
                                                 c(svmO, ocsvmO, svmdbcO, onevsetO, wsvmO, pisvmO))

            zz = round(p.adjust(as.numeric(p.values.raw[1, ]), method="holm"), 10)
            names(zz) = baselines_open
            verbose("Wilcoxon test (open) --- p-values with holm correction")
            verbose(as.matrix(zz))
            print(format(unname(zz), nsmall=nsmall, digits=digits))
        }

    }

    { # Statistical tests for classifiers with CLOSED-SET grid search.
        {                               # Sign test
            y = spread(nacc, classifier, result)
            yy = y[, classifiers_closed]

            verbose("Winning cases (closed)")
            counter <- t(mapply(function(baseline) apply(apply(yy[, c(proposed_method_closed, baseline)], 1, function(x) { x == max(x) }), 1, sum), baselines_closed))
            colnames(counter) = c(proposed_method_closed, "other")
            verbose(counter)
            verbose(all(counter[, proposed_method_closed] >= counter[, "other"]))
            stopifnot(all(counter[, proposed_method_closed] >= counter[, "other"]))

            nn = dim(yy)[1]
            p.values.raw = yy %>% summarize_each(funs(binom.test(sum(ssvmC > .), nn)$p.value),
                                                 c(svmC, ocsvmC, svmdbcC, onevsetC, wsvmC, pisvmC))

            verbose("Sign test (closed) --- p-values with holm correction")
            zz = round(p.adjust(as.numeric(p.values.raw[1, ]), method="holm"), 10)
            names(zz) = baselines_closed
            verbose(as.matrix(zz))
            print(format(unname(zz), nsmall=nsmall, digits=digits))
        }

        {                               # Wilcoxon test
            verbose("Mean of the accuracy (closed)")
            aux <- as.matrix(colMeans(yy[, classifiers_closed]))
            verbose(aux)
            verbose(paste("Winning method:", rownames(aux)[which.max(aux)]))
            stopifnot(rownames(aux)[which.max(aux)] == proposed_method_closed)

            xnacc = nacc %>% group_by(lenacs, dataset, classifier) %>% summarise(nacc=mean(result))
            y = spread(xnacc, classifier, nacc)
            yy = y[, classifiers_closed]

            p.values.raw = yy %>% summarize_each(funs(wilcox.test(., ssvmC, paired=T)$p.value),
                                                 c(svmC, ocsvmC, svmdbcC, onevsetC, wsvmC, pisvmC))

            zz = round(p.adjust(as.numeric(p.values.raw[1, ]), method="holm"), 10)
            names(zz) = baselines_closed
            verbose("Wilcoxon test (closed) --- p-values with holm correction")
            verbose(as.matrix(zz))
            print(format(unname(zz), nsmall=nsmall, digits=digits))
        }

    }

    { # Statistical tests comparing the open- vs closed-set grid search procedures applied to the methods.
        {                               # Sign test
            verbose("Open vs closed comparison --- winning cases")
            acc_comparison <- t(mapply(function (o, c) {
                c(sum(mapply(function(vo, vc) vo > vc, y[[o]], y[[c]])), sum(mapply(function(vo, vc) vo < vc, y[[o]], y[[c]]))) }, classifiers_open, classifiers_closed))
            colnames(acc_comparison) <- c("open", "closed")
            rownames(acc_comparison) <- classifiers
            verbose(acc_comparison)
            verbose(all(acc_comparison[, "open"] >= acc_comparison[, "closed"]))
            ## stopifnot(all(acc_comparison[, "open"] >= acc_comparison[, "closed"]))

            verbose("Sign test --- open vs close comparison --- p-values")
            oxc = data.frame(alg=classifiers_open, p.value=rep(NA, length(classifiers_open)))
            for (i in 1:7) oxc[i, 2] = round(binom.test(sum(y[[classifiers_open[i]]] > y[[classifiers_closed[i]]]), length(y[[classifiers_open[i]]]))$p.value, 10)
            oxc$alg <- classifiers
            verbose(oxc)
            print(format(oxc$p.value, nsmall=nsmall, digits=digits))
        }

        {                               # Wilcoxon test
            verbose("Open vs closed comparison --- accuracy")
            acc_comparison <- t(mapply(function (o, c) { c(mean(y[[o]]), mean(y[[c]])) }, classifiers_open, classifiers_closed))
            colnames(acc_comparison) <- c("open", "closed")
            rownames(acc_comparison) <- classifiers
            verbose(acc_comparison)

            verbose("Wilcoxon test --- open vs close comparison --- p-values")
            oxc = data.frame(alg=classifiers_open, p.value=rep(NA, length(classifiers_open)))
            for (i in 1:7) oxc[i, 2] = round(wilcox.test(y[[classifiers_open[i]]], y[[classifiers_closed[i]]], paired=T)$p.value, 10)
            oxc$alg <- classifiers
            verbose(oxc)
            print(format(oxc$p.value, nsmall=nsmall, digits=digits))
        }
    }
}

run("na")                          # normalized accuracy
run("mafm")                        # macro-averaging open-set f-measure
run("mifm")                        # micro-averaging open-set f-measure
run("bbmafm")                      # macro-averaging f-measure
run("bbmifm")                      # micro-averaging f-measure
