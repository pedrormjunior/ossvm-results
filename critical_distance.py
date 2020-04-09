#!/usr/bin/env python3
# -*- coding: utf-8; -*-

# The piece of code herein were obtained from Orange package available
# at https://orange.biolab.si/ and https://github.com/biolab/orange.
# Orange were distributed under GNU General Public License, Version 3,
# which copy is available at https://www.gnu.org/licenses/gpl.txt.
#
# The function `compute_CD` below is kept as provided in the Orange
# package
# (https://raw.githubusercontent.com/biolab/orange/f208fce1ebaf184dadf2d9cadf87382ab582893b/Orange/evaluation/scoring.py).
# We have modified the function `graph_ranks` to satisfy our needs.
#
# 2018 Luís Augusto Martins Pereira, Campinas, SP, Brazil
# 2018 Pedro Ribeiro Mendes Júnior, Campinas, SP, Brazil
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

import math
import numpy
import matplotlib

def compute_CD(avranks, N, alpha="0.05", type="nemenyi"):
    """ Returns critical difference for Nemenyi or Bonferroni-Dunn test
    according to given alpha (either alpha="0.05" or alpha="0.1") for average
    ranks and number of tested data sets N. Type can be either "nemenyi" for
    for Nemenyi two tailed test or "bonferroni-dunn" for Bonferroni-Dunn test.
    """

    k = len(avranks)

    d = {("nemenyi", "0.05"): [0, 0, 1.959964, 2.343701, 2.569032, 2.727774,
                               2.849705, 2.94832, 3.030879, 3.101730, 3.163684,
                               3.218654, 3.268004, 3.312739, 3.353618, 3.39123,
                               3.426041, 3.458425, 3.488685, 3.517073, 3.543799]
        , ("nemenyi", "0.1"): [0, 0, 1.644854, 2.052293, 2.291341, 2.459516,
                               2.588521, 2.692732, 2.779884, 2.854606, 2.919889,
                               2.977768, 3.029694, 3.076733, 3.119693, 3.159199,
                               3.195743, 3.229723, 3.261461, 3.291224, 3.319233]
        , ("bonferroni-dunn", "0.05"): [0, 0, 1.960, 2.241, 2.394, 2.498, 2.576,
                                        2.638, 2.690, 2.724, 2.773],
         ("bonferroni-dunn", "0.1"): [0, 0, 1.645, 1.960, 2.128, 2.241, 2.326,
                                      2.394, 2.450, 2.498, 2.539]}

    #can be computed in R as qtukey(0.95, n, Inf)**0.5
    #for (x in c(2:20)) print(qtukey(0.95, x, Inf)/(2**0.5)

    q = d[(type, alpha)]

    cd = q[k] * (k * (k + 1) / (6.0 * N)) ** 0.5

    return cd


def graph_ranks(filename, avranks, names, cd=None, cdmethod=None, lowv=None, highv=None, width=6, textspace=1, reverse=False, **kwargs):
    """
    Draws a CD graph, which is used to display  the differences in methods'
    performance.
    See Janez Demsar, Statistical Comparisons of Classifiers over
    Multiple Data Sets, 7(Jan):1--30, 2006.

    Needs matplotlib to work.

    :param filename: Output file name (with extension). Formats supported
                     by matplotlib can be used.
    :param avranks: List of average methods' ranks.
    :param names: List of methods' names.

    :param cd: Critical difference. Used for marking methods that whose
               difference is not statistically significant.
    :param lowv: The lowest shown rank, if None, use 1.
    :param highv: The highest shown rank, if None, use len(avranks).
    :param width: Width of the drawn figure in inches, default 6 in.
    :param textspace: Space on figure sides left for the description
                      of methods, default 1 in.
    :param reverse:  If True, the lowest rank is on the right. Default\: False.
    :param cdmethod: None by default. It can be an index of element in avranks
                     or or names which specifies the method which should be
                     marked with an interval.
    """

    width = float(width)
    textspace = float(textspace)

    def nth(l, n):
        """
        Returns only nth elemnt in a list.
        """
        n = lloc(l, n)
        return [ a[n] for a in l ]

    def lloc(l, n):
        """
        List location in list of list structure.
        Enable the use of negative locations:
        -1 is the last element, -2 second last...
        """
        if n < 0:
            return len(l[0]) + n
        else:
            return n

    def mxrange(lr):
        """
        Multiple xranges. Can be used to traverse matrices.
        This function is very slow due to unknown number of
        parameters.

        >>> mxrange([3,5])
        [(0, 0), (0, 1), (0, 2), (1, 0), (1, 1), (1, 2)]

        >>> mxrange([[3,5,1],[9,0,-3]])
        [(3, 9), (3, 6), (3, 3), (4, 9), (4, 6), (4, 3)]

        """
        if not len(lr):
            yield ()
        else:
            #it can work with single numbers
            index = lr[0]
            if type(1) == type(index):
                index = [ index ]
            for a in range(*index):
                for b in mxrange(lr[1:]):
                    yield tuple([a] + list(b))

    from matplotlib.pyplot import savefig
    from matplotlib.figure import Figure
    from matplotlib.backends.backend_agg import FigureCanvasAgg

    def print_figure(fig, *args, **kwargs):
        assert len(args) == 1, args
        canvas = FigureCanvasAgg(fig)
        filename, = args
        if filename.endswith('.png'):
            canvas.print_png(filename, bbox_inches='tight', pad_inches=0, **kwargs)
        else:
            canvas.print_figure(filename, bbox_inches='tight', pad_inches=0, **kwargs)


    sums = avranks

    tempsort = sorted([ (a, i) for i, a in  enumerate(sums) ], reverse=reverse) # sort and tuple with position and rank

    ssums = nth(tempsort, 0)
    sortidx = nth(tempsort, 1)
    nnames = [ names[x] for x in sortidx ]

    if lowv is None:
        lowv = min(1, int(math.floor(min(ssums))))
    if highv is None:
        highv = max(len(avranks), int(math.ceil(max(ssums))))

    cline = 0.4

    k = len(sums)

    lines = None

    linesblank = 0
    scalewidth = width - 2 * textspace

    def rankpos(rank):
        if not reverse:
            a = rank - lowv
        else:
            a = highv - rank
        return textspace + scalewidth / (highv - lowv) * a

    distanceh = 0.25

    if cd and cdmethod is None:

        #get pairs of non significant methods

        def get_lines(sums, hsd):

            #get all pairs
            lsums = len(sums)
            allpairs = [ (i, j) for i, j in mxrange([[lsums], [lsums]]) if j > i ]

            #remove not significant
            notSig = [ (i, j) for i, j in allpairs if abs(sums[i] - sums[j]) <= hsd ]

            #keep only longest
            def no_longer(x, notSig):
                i, j = x
                for i1, j1 in notSig:
                    if (i1 <= i and j1 > j) or (i1 < i and j1 >= j):
                        return False
                return True

            longest = [ (i, j) for i, j in notSig if no_longer((i, j), notSig) ]

            return longest

        lines = get_lines(ssums, cd)
        linesblank = 0.2 + 0.2 + (len(lines) - 1) * 0.1

        #add scale
        distanceh = 0.25
        cline += distanceh

    #calculate height needed height of an image
    minnotsignificant = max(2 * 0.2, linesblank)
    height = cline + ((k + 1) / 2) * 0.2 + minnotsignificant

    fig = Figure(figsize=(width, height+1))
    ax = fig.add_axes([0, 0, 1, 1]) #reverse y axis
    ax.set_axis_off()

    hf = 1. / height # height factor
    wf = 1. / width

    def hfl(l):
        return [ a * hf for a in l ]

    def wfl(l):
        return [ a * wf for a in l ]


    # Upper left corner is (0,0).

    ax.plot([0, 1], [0, 1], c="w")
    ax.set_xlim(0, 1)
    ax.set_ylim(1, 0)

    def line(l, color='k', **kwargs):
        """
        Input is a list of pairs of points.
        """
        ax.plot(wfl(nth(l, 0)), hfl(nth(l, 1)), color=color, **kwargs)

    def text(x, y, s, *args, **kwargs):
        ax.text(wf * x, hf * y, s, *args, **kwargs)

    line([(textspace, cline), (width - textspace, cline)], linewidth=0.7)

    bigtick = 0.1
    smalltick = 0.05



    tick = None
    for a in list(numpy.arange(lowv, highv, 0.5)) + [highv]:
        tick = smalltick
        if a == int(a): tick = bigtick
        line([(rankpos(a), cline - tick / 2), (rankpos(a), cline)], linewidth=0.7)

    for a in range(lowv, highv + 1):
        text(rankpos(a), cline - tick / 2 - 0.05, str(a), ha="center", va="bottom")

    k = len(ssums)

    for i in range((k + 1) // 2):
        chei = cline + minnotsignificant + i * 0.2
        line([(rankpos(ssums[i]), cline), (rankpos(ssums[i]), chei), (textspace - 0.1, chei)], linewidth=0.7)
        text(textspace - 0.2, chei, nnames[i], ha="right", va="center")

    for i in range((k + 1) // 2, k):
        chei = cline + minnotsignificant + (k - i - 1) * 0.2
        line([(rankpos(ssums[i]), cline), (rankpos(ssums[i]), chei), (textspace + scalewidth + 0.1, chei)], linewidth=0.7)
        text(textspace + scalewidth + 0.2, chei, nnames[i], ha="left", va="center")

    if cd and cdmethod is None:

        #upper scale
        if not reverse:
            begin, end = rankpos(lowv), rankpos(lowv + cd)
        else:
            begin, end = rankpos(highv), rankpos(highv - cd)

        line([(begin, distanceh), (end, distanceh)], linewidth=0.7)
        line([(begin, distanceh + bigtick / 2), (begin, distanceh - bigtick / 2)], linewidth=0.7)
        line([(end, distanceh + bigtick / 2), (end, distanceh - bigtick / 2)], linewidth=0.7)
        text((begin + end) / 2, distanceh - 0.05, "CD="+str('%.4f'%float(cd)), ha="center", va="bottom")

        #non significance lines
        def draw_lines(lines, side=0.05, height=0.1):
            start = cline + 0.2
            for l, r in lines:
                line([(rankpos(ssums[l]) - side, start), (rankpos(ssums[r]) + side, start)], linewidth=2.5)
                start += height

        draw_lines(lines)

    elif cd:
        begin = rankpos(avranks[cdmethod] - cd)
        end = rankpos(avranks[cdmethod] + cd)
        line([(begin, cline), (end, cline)], linewidth=2.5, color='r', alpha=0.7)
        line([(begin, cline + bigtick / 2), (begin, cline - bigtick / 2)], linewidth=2.5,color='r', alpha=0.7)
        line([(end, cline + bigtick / 2), (end, cline - bigtick / 2)], linewidth=2.5,color='r', alpha=0.7)
    ax.autoscale(tight=True)

    print_figure(fig, filename, **kwargs)
