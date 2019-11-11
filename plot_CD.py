#!/usr/bin/env python2
# -*- coding: utf-8; -*-

# Plot Critical Difference diagrams according to [1].
#
# Copyright (C) 2018 Luís Augusto Martins Pereira, Campinas, SP, Brazil
# Copyright (C) 2018 Pedro Ribeiro Mendes Júnior, Campinas, SP, Brazil
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <https://www.gnu.org/licenses/>.

import numpy as np
import pandas as pd
from scipy.stats import rankdata
from critical_distance import compute_CD, graph_ranks
import os, sys
import operator as op

import matplotlib
matplotlib.rcParams.update({'font.size': 10})
matplotlib.rcParams.update({'font.size': 16})
matplotlib.rcParams.update({'legend.fontsize': u'medium'})
matplotlib.rcParams.update({'legend.fontsize': 16})
matplotlib.rcParams.update({'legend.labelspacing': 0.5})
matplotlib.rcParams.update({'legend.labelspacing': 0.0})
matplotlib.rcParams.update({'font.weight': u'normal'})
matplotlib.rcParams.update({'font.weight': u'bold'})
matplotlib.rcParams.update({'axes.titleweight': u'normal'})
matplotlib.rcParams.update({'axes.titleweight': u'bold'})
matplotlib.rcParams.update({'axes.labelweight': u'normal'})
matplotlib.rcParams.update({'axes.labelweight': u'bold'})
matplotlib.rcParams.update({'text.usetex': True})

csv_dir = 'CSV_files'
output_dir = 'CD_diagrams'
extensions = ['png', 'pdf']
datatype = 'normal'
gs_extensions = ['O', 'C']

measure_name_map = {
    'mafm': '$\mathrm{OSFM}_{M}$',
    'mifm': '$\mathrm{OSFM}_{\mu}$',
    'na': '$\mathrm{NA}$',
    'harmonicNA': '$\mathrm{HNA}$',
    'aks': '$\mathrm{AKS}$',
    'aus': '$\mathrm{AUS}$',
    'bbmafm': '$\mathrm{FM}_{M}$',
    'bbmifm': '$\mathrm{FM}_{\mu}$',
}

classifier_name_map = {
    'evmC': '$\mathrm{EVM}$',
    'evmO': '$\mathrm{EVM}$',
    'ocsvmC': '$\mathrm{SVM}^{\mathrm{OC}}$',
    'ocsvmO': '$\mathrm{SVM}^{\mathrm{OC}}$',
    'ssvmC': '$\mathbf{{SSVM}}$',
    'ssvmO': '$\mathbf{{SSVM}}$',
    'svddC': '$\mathrm{SVDD}$',
    'svddO': '$\mathrm{SVDD}$',
    'svmC': '$\mathrm{SVM}$',
    'svmO': '$\mathrm{SVM}$',
    'svmdbcC': '$\mathrm{DBC}$',
    'svmdbcO': '$\mathrm{DBC}$',
    'pisvmC': '$\mathrm{PISVM}$',
    'pisvmO': '$\mathrm{PISVM}$',
    'onevsetC': '$\mathrm{1VS}$',
    'onevsetO': '$\mathrm{1VS}$',
    'wsvmC': '$\mathrm{WSVM}$',
    'wsvmO': '$\mathrm{WSVM}$',
}

results_csv = [
    'NA.csv',
    'HNA.csv',
    'AKS.csv',
    'AUS.csv',
    'OSFMM.csv',
    'OSFMm.csv',
    'FMM.csv',
    'FMm.csv',
]

def mean_experiments(df):
    """This function receives all the results for every experiment
performed.  For each group of 10 experiments, it performs the mean of
them for statistical tests.

    """
    assert isinstance(df, pd.DataFrame), type(df)

    newdf = (df
             .groupby(['lenacs', 'dataset', 'classifier'])
             .agg({'experiment': 'size', 'result': 'mean'}))
    assert len(set(newdf.experiment)) == 1 and \
        newdf.experiment[0] == 10, newdf.experiment
    newdf = newdf.drop('experiment', axis=1)
    newdf = newdf.reset_index()

    return newdf

if __name__ == '__main__':
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for csv_filename in results_csv:
        csv_filename = '{}_{}'.format(datatype, csv_filename)
        for gs in gs_extensions:
            control_method = 'ssvm{}'.format(gs)

            # Output filename for the CD diagram.
            name, _ = csv_filename.split('.')

            # Loading the data.
            csv_path = os.path.join(csv_dir, csv_filename)
            df = pd.read_csv(csv_path)

            # Select data by grid search type (open or closed).
            df = df[map(lambda classifier: classifier.endswith(gs),
                        df.classifier)]
            df = mean_experiments(df)
            assert control_method in set(df.classifier), \
                (control_method, set(df.classifier))

            data = []
            names = []
            classifiers = np.unique(df['classifier'])

            # Prepare data
            for i, classifier in enumerate(classifiers):
                mask = df['classifier'] == classifier
                data.append(np.array(df['result'][mask]))
                names.append(classifier_name_map[classifier])

                if classifier == control_method:
                    cdmethod = i

            data = np.array(data).T

            # Compute the average of the ranks
            ranks = [rankdata(-1*d) for d in data]
            avranks = np.mean(ranks, axis=0)

            # Compute the critical distance
            n_datasets = data.shape[0]
            cd = compute_CD(avranks, N=n_datasets, alpha='0.05',
                            type="bonferroni-dunn")

            # Plot and save critical distance diagram
            for ext in extensions:
                output_filename = 'CD_{}_{}.{}'.format(name, gs, ext)
                output = os.path.join(output_dir, output_filename)
                print('Generating CD diagram "{}"...'.format(output))
                graph_ranks(output, avranks, names, cdmethod=cdmethod,
                            cd=cd, width=6, textspace=1.5, reverse=True)
