#!/usr/bin/env python3

from sklearn.svm import SVC
import numpy as np
import pylab as pl
import random

seed = 0.0332045735201546
random.seed(seed)

gamma = 0.5
C = 1
epsextra = 0.02
epsilon = lambda b: b + epsextra

quant_per_class = 10
negative = np.array([random.normalvariate(0, 2) for _ in range(quant_per_class)])
positive = np.array([random.normalvariate(4, 2) for _ in range(quant_per_class)])
del quant_per_class

decrease_precision = lambda vector: np.array([eval('{:.02f}'.format(x)) for x in vector])
negative = decrease_precision(negative)
positive = decrease_precision(positive)

increase_dimension = lambda vector: vector[:, np.newaxis]

# Training the SVM classifier per se.
features = np.concatenate((increase_dimension(negative), increase_dimension(positive)), axis=0)
labels = np.array([-1] * len(negative) + [1] * len(positive))
clf = SVC(gamma=gamma, C=C)
clf.fit(features, labels)
b, = clf.intercept_

# Obtaining the alpha parameters of the dual problem.
alphas = np.zeros(labels.shape)
alphas[clf.support_] = abs(clf.dual_coef_)

# Obtaining the values of decision function.
minxspan, maxxspan = -35, 20
x = np.linspace(minxspan, maxxspan, 1000)
y = clf.decision_function(increase_dimension(x))
eps = epsilon(b)
y_eps = y - eps
minyspan, maxyspan = min(y_eps), max(y)

# Highlighting the regions.
extrax, extray = 1, 0.1
alpha = 0.05
pl.axhspan(minyspan - extray, 0, color='red', alpha=alpha, label='Negative classification')
pl.axhspan(0, maxyspan + extray, color='blue', alpha=alpha, label='Positive classification')
del alpha
alpha = 0.2
openextra = 3.1
openmin, openmax = min(negative) - openextra, max(positive) + openextra
pl.axvspan(minxspan - extrax, openmin, color='gray', alpha=alpha, label='Open space')
pl.axvspan(openmax, maxxspan + extrax, color='gray', alpha=alpha)
del openextra, openmin, openmax, alpha

pl.xlim([minxspan - extrax, maxxspan + extrax])
pl.ylim([minyspan - extray, maxyspan + extray])
del extrax, extray
del minxspan, maxxspan, minyspan, maxyspan

pl.plot(x, y, color='k', linewidth=1, label='Decision function $f(\mathbf{x})$', linestyle='-')
pl.plot(x, y - eps, color='k', linewidth=1, label='Decision function $f(\mathbf{{x}})-\epsilon$\nin which $\epsilon=b+{}$'.format(epsextra), linestyle=':')

marker = 'x'
lw = 1
s = 50
pl.scatter(negative, [0] * len(negative), color='red', label='Negative training examples', marker=marker, lw=lw, s=s)
pl.scatter(positive, [0] * len(positive), color='blue', label='Positive training examples', marker=marker, lw=lw, s=s)
del marker, lw, s

pl.plot(x, [b]*len(x), label='Bias term $b = {:.06f}$'.format(b), color='green', linewidth=1, linestyle='--')

pl.legend()
pl.xlabel('Feature')
pl.ylabel('Decision value')
pl.savefig('example-RBF.pdf')
pl.close()

data = sorted(list(zip(features.reshape([-1]), labels, alphas)))
print('\\begin{table}[h]')
print('\\centering')
print('''\\caption{{One-dimensional features used for the example of
Figure~\\ref{{fig:example-RBF}}, their respective labels, and
$\\alpha$ parameters associated to each example.  The $\\alpha$
parameters were obtained considering $C={C}$ and $\\gamma={gamma}$
during the optimization process.  The value of $b$ obtained after
optimization is ${b}$.}}\\label{{tab:example-RBF}}'''.format(
    b=b, C=C, gamma=gamma,
))
print('\\begin{tabular}{ccc}')
print('\\hline')
print('Feature &\tLabel &\t$\\alpha$ parameter \\\\'.format(*x))
print('\\hline')
for x in data:
    print('${}$ &\t${}$ &\t${}$ \\\\'.format(x[0], x[1], x[2] if x[2] not in [0, 1] else int(x[2])))
print('\\hline')
print('\\end{tabular}')
print('\\end{table}')
