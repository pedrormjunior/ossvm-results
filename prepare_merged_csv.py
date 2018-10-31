#!/usr/bin/env python2

import os, sys
import operator as op
import numpy as np
import pandas as pd

version = 'R3v5'
output_dir = 'CSV_files'

filename_pattern = 'statcsv_ossvm_{}_{}'
datatype = 'normal'

suffixes_dir_normal = [
    'normal',
    'normal_max6',
    'normal_max9',
    'onlyCIFAR10',
    'onlyImageNet',
    'onlyMNIST',
]

suffixes_dir = suffixes_dir_normal

classifier_map = {
    'mcevm_ovx_gsec': 'evmC',
    'mcevm_ovx_gseo': 'evmO',
    'mcocsvm_ova_gsic': 'ocsvmC',
    'mcocsvm_ova_gsio': 'ocsvmO',
    'mcossvm_ova_gsic': 'ssvmC',
    'mcossvm_ova_gsio': 'ssvmO',
    'mcsvdd_ova_gsic': 'svddC',
    'mcsvdd_ova_gsio': 'svddO',
    'mcsvm_ova_gsic_highGamma_fixedC': 'svmC',
    'mcsvm_ova_gsio_highGamma_fixedC': 'svmO',
    'mcsvmdbc_ova_gsic': 'svmdbcC',
    'mcsvmdbc_ova_gsio': 'svmdbcO',
    'pisvm_ovx_gsec': 'pisvmC',
    'pisvm_ovx_gseo': 'pisvmO',
    'svm1vsll_ovx_gsec': 'onevsetC',
    'svm1vsll_ovx_gseo': 'onevsetO',
    'wsvm_ovx_gsec': 'wsvmC',
    'wsvm_ovx_gseo': 'wsvmO',
}

measure_map = {
    'na': 'NA',
    'harmonicNA': 'HNA',
    'aks': 'AKS',
    'aus': 'AUS',
    'bbmafm': 'OSFMM',
    'bbmifm': 'OSFMm',
    'mafm': 'FMM',
    'mifm': 'FMm',
}

dataset_map = {
    'yeast_pmlb': 'YEAST',
    'mfeat-zernike_pmlb': 'ZERNIKE',
    'mfeat-fourier_pmlb': 'FOURIER',
    'optdigits_pmlb': 'OPTDIGITS',
    'movement_libras_pmlb': 'MOVEMENT',
    'led7_pmlb': 'LED7',
    'led24_pmlb': 'LED24',
    'caltech256_bow_dense_hard_average_1000': 'CALTECH256',
    'vowel_pmlb': 'VOWEL',
    'mfeat-morphological_pmlb': 'MFEAT',
    '15scenes_bow_soft_max_1000': '15SCENES',
    'ImageNet_googlenet_openset_images_07102017': 'IMAGENET',
    'auslan': 'AUSLAN',
    'pendigits_pmlb': 'PENDIGITS',
    'kddcup_limited': 'KDDCUP',
    'krkopt_pmlb': 'KRKOPT',
    'aloi_bic': 'ALOI',
    'letter': 'LETTER',
    'cifar10_local4_train_eval': 'CIFAR10',
    'mfeat-factors_pmlb': 'FACTORS',
    'mfeat-karhunen_pmlb': 'KARHUNEN',
    'mnist_h_fc1_train': 'MNIST',
}

suffix_file = '___0___0___0.csv'

def get_dir(suffix_dir):
    dirname = filename_pattern.format(version, suffix_dir)
    files = os.listdir(dirname)
    files = filter(lambda filename: filename.endswith(suffix_file), files)
    files = [os.path.join(dirname, filename) for filename in files]
    return files

files = reduce(op.concat, map(get_dir, suffixes_dir))

def get_measure(filename):
    return measure_map[filename.split('/')[1].split('___')[1]]

measures = set([get_measure(filename) for filename in files])

def filter_measure(files, measure):
    filtered = [filename for filename in files if get_measure(filename) == measure]
    return filtered

def concat_csvs(files):
    def readcsv(filename):
        # with open(filename) as fd:
        #     return fd.readlines()
        csv = pd.read_csv(filename)
        return csv
    # lst_lines = map(readcsv, files)
    lst_lines = pd.concat(map(readcsv, files))
    # print lst_lines.shape
    return lst_lines

def select_results(df, gs='O'):
    # df: Pandas dataframe
    assert gs in ['C', 'O', '']

    def is_with_openset_grid_search(classifiername):
        return classifiername.endswith(gs)

    return df[map(is_with_openset_grid_search, df.classifier)]

def mean_experiments(df):
    newdf = df.groupby(('lenacs', 'dataset', 'classifier')).agg({'experiment':'size', 'result':'mean'})
    return newdf.reset_index()

# for gs in ['C', 'O', '']:
for gs in ['']:
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    for measure in measures:
        print 'Generating CSV for {} measure...'.format(measure)
        filtered = filter_measure(files, measure)
        df = concat_csvs(filtered)
        df.classifier = [classifier_map[classifier] for classifier in df.classifier]
        df.dataset = [dataset_map[dataset] for dataset in df.dataset]
        df = select_results(df, gs)
        df = df.sort_values(['classifier', 'dataset', 'lenacs', 'experiment'])
        # df = mean_experiments(df)
        # df = df.drop('experiment', axis=1)
        output = os.path.join(output_dir, '{}_{}{}.csv'.format(datatype, measure, '_{}'.format(gs) if gs else gs))
        with open(output, 'w') as fd:
            print >> fd, df.to_csv(index=False),
