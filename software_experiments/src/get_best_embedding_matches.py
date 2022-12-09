#!/usr/bin/python3
# Copyright (c) Facebook, Inc. and its affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.
#
# LASER  Language-Agnostic SEntence Representations
# is a toolkit to calculate multilingual sentence embeddings
# and to use them for document classification, bitext filtering
# and mining
#
# --------------------------------------------------------
#
# Tool to calculate to embed a text file
# The functions can be also imported into another Python code

import os
import sys
import faiss
import argparse
import tempfile
import numpy as np
import pickle


#from embed import SentenceEncoder, EncodeLoad, EncodeFile, EmbedLoad
#from text_processing import Token, BPEfastApply


# Load existing embeddings
def EmbedLoad(fname, dim=768, verbose=False):
    x = np.fromfile(fname, dtype=np.float32, count=-1)
    x.resize(x.shape[0] // dim, dim)
    if verbose:
        print(' - Embeddings: {:s}, {:d}x{:d}'.format(fname, x.shape[0], dim))
    return x


def TextLoadUnify(fname, args):
    names = []
    if "," in fname:
        names = fname.split(",")
    else:
        names = []
        names.append(fname)

    inds = []
    sents = []

    for name in names:
        if args.verbose:
            print(' - loading texts {:s}: '.format(name), end='')
        with open(name, 'rb') as fin:
            binlist = pickle.load(fin)
        sent2ind = {}
        n = 0
        nu = 0
        for pair in binlist:
            sline = pair[0]
            tline = pair[1]
            line = sline+"\t"+tline
            new_ind = len(sent2ind)
            inds.append(sent2ind.setdefault(line, new_ind))
            if args.unify:
                if inds[-1] == new_ind:
                    sents.append(line)
                    nu += 1
            else:
                sents.append(line)
                nu += 1
            n += 1
        if args.verbose:
            print('{:d} lines, {:d} unique'.format(n, nu))
        del sent2ind
    return inds, sents

###############################################################################
#
# Wrapper for knn on CPU/GPU
#
###############################################################################

def knn(x, y, k, use_gpu):
    return knnGPU(x, y, k) if use_gpu else knnCPU(x, y, k)


###############################################################################
#
# Perform knn on GPU
#
###############################################################################

def knnGPU(x, y, k, mem=5*768*768*768):
    dim = x.shape[1]
    batch_size = mem // (dim*4)
    sim = np.zeros((x.shape[0], k), dtype=np.float32)
    ind = np.zeros((x.shape[0], k), dtype=np.int64)
    for xfrom in range(0, x.shape[0], batch_size):
        xto = min(xfrom + batch_size, x.shape[0])
        bsims, binds = [], []
        for yfrom in range(0, y.shape[0], batch_size):
            yto = min(yfrom + batch_size, y.shape[0])
            # print('{}-{}  ->  {}-{}'.format(xfrom, xto, yfrom, yto))
            idx = faiss.IndexFlatIP(dim)
            idx = faiss.index_cpu_to_all_gpus(idx)
            idx.add(y[yfrom:yto])
            bsim, bind = idx.search(x[xfrom:xto], min(k, yto-yfrom))
            bsims.append(bsim)
            binds.append(bind + yfrom)
            del idx
        bsims = np.concatenate(bsims, axis=1)
        binds = np.concatenate(binds, axis=1)
        aux = np.argsort(-bsims, axis=1)
        for i in range(xfrom, xto):
            for j in range(k):
                sim[i, j] = bsims[i-xfrom, aux[i-xfrom, j]]
                ind[i, j] = binds[i-xfrom, aux[i-xfrom, j]]
    return sim, ind


###############################################################################
#
# Perform knn on CPU
#
###############################################################################

def knnCPU(x, y, k):
    dim = x.shape[1]
    idx = faiss.IndexFlatIP(dim)
    idx.add(y)
    sim, ind = idx.search(x, k)
    return sim, ind


###############################################################################
#
# Scoring
#
###############################################################################

def score(x, y, fwd_mean, bwd_mean, margin):
    return x.dot(y)
    #return margin(x.dot(y), (fwd_mean + bwd_mean) / 2)


def score_candidates(x, y, candidate_inds, fwd_mean, bwd_mean, margin, verbose=False):
    if verbose:
        print(' - scoring {:d} candidates'.format(x.shape[0]))
    scores = np.zeros(candidate_inds.shape)
    for i in range(scores.shape[0]):
        for j in range(scores.shape[1]):
            k = candidate_inds[i, j]
            scores[i, j] = score(x[i], y[k], fwd_mean[i], bwd_mean[k], margin)
    return scores


###############################################################################
#
# Main
#
###############################################################################

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='LASER: Mine bitext')
    parser.add_argument('src',
        help='Source language corpus')
    parser.add_argument('trg',
        help='Translation memory corpus')
    parser.add_argument('--encoding', default='utf-8',
        help='Character encoding for input/output')
    parser.add_argument('--output', required=True,
        help='Output file')
    parser.add_argument('--threshold', type=float, default=0,
        help='Threshold on extracted bitexts')

    # mining params
    parser.add_argument('-k', '--neighborhood',
        type=int, default=4,
        help='Neighborhood size')
    parser.add_argument('--unify', action='store_true',
        help='Unify texts')
    parser.add_argument('--gpu', action='store_true',
        help='Run knn on all available GPUs')
    parser.add_argument('--verbose', action='store_true',
        help='Detailed output')

    # embeddings
    parser.add_argument('--src-embeddings', required=True,
        help='Precomputed source sentence embeddings')
    parser.add_argument('--trg-embeddings', required=True,
        help='Precomputed target sentence embeddings')
    parser.add_argument('--dim', type=int, default=768,
        help='Embedding dimensionality')
    args = parser.parse_args()

    print('LASER: tool to search, score or mine bitexts')
    if args.gpu:
        print(' - knn will run on all available GPUs (recommended)')
    else:
        print(' - knn will run on CPU (slow)')

    src_inds, src_sents = TextLoadUnify(args.src, args)
    trg_inds, trg_sents = TextLoadUnify(args.trg, args)

    def unique_embeddings(emb, ind, verbose=False):
        aux = {j: i for i, j in enumerate(ind)}
        if verbose:
            print(' - unify embeddings: {:d} -> {:d}'.format(len(emb), len(aux)))
        return emb[[aux[i] for i in range(len(aux))]]

    # load the embeddings
    if "," in args.src_embeddings:
        sources = args.src_embeddings.strip().split(",")
        x = EmbedLoad(sources[0], args.dim, verbose=args.verbose)
        for i in range(1,len(sources)):
            x_tmp = EmbedLoad(sources[i], args.dim, verbose=args.verbose)
            x = np.vstack((x, x_tmp))
    else:
        x = EmbedLoad(args.src_embeddings, args.dim, verbose=args.verbose)
    if args.unify:
        x = unique_embeddings(x, src_inds, args.verbose)
    faiss.normalize_L2(x)

    if "," in args.trg_embeddings:
        sources = args.trg_embeddings.strip().split(",")
        y = EmbedLoad(sources[0], args.dim, verbose=args.verbose)
        for i in range(1,len(sources)):
            y_tmp = EmbedLoad(sources[i], args.dim, verbose=args.verbose)
            print(y.shape)
            print(y_tmp.shape)
            print()
            y = np.vstack((y, y_tmp))
            print(y.shape)
    else:
        y = EmbedLoad(args.trg_embeddings, args.dim, verbose=args.verbose)
    if args.unify:
        y = unique_embeddings(y, trg_inds, args.verbose)
    faiss.normalize_L2(y)

    # calculate knn in both directions
    if args.verbose:
        print(' - perform {:d}-nn source against target'.format(args.neighborhood))
    x2y_sim, x2y_ind = knn(x, y, min(y.shape[0], args.neighborhood), args.gpu)
    x2y_mean = x2y_sim.mean(axis=1)

    if args.verbose:
        print(' - perform {:d}-nn target against source'.format(args.neighborhood))
    y2x_sim, y2x_ind = knn(y, x, min(x.shape[0], args.neighborhood), args.gpu)
    y2x_mean = y2x_sim.mean(axis=1)

    # margin function
    margin = lambda a, b: a / b

    fout = open(args.output, mode='w', encoding=args.encoding, errors='surrogateescape')

    if args.verbose:
        print(' - Searching for closest sentences in target')
        print(' - writing alignments to {:s}'.format(args.output))
    scores = score_candidates(x, y, x2y_ind, x2y_mean, y2x_mean, margin, args.verbose)
    best = x2y_ind[np.arange(x.shape[0]), scores.argmax(axis=1)]

    nbex = x.shape[0]
    ref = np.linspace(0, nbex-1, nbex).astype(int)  # [0, nbex)
    err = nbex - np.equal(best.reshape(nbex), ref).astype(int).sum()
    print(' - errors: {:d}={:.2f}%'.format(err, 100*err/nbex))
    print(len(src_sents))
    print(len(trg_sents))
    for i in src_inds:
        s = score(x[i], y[best[i]], x2y_mean[i], y2x_mean[best[i]], margin)
        print(src_sents[i]+"\t"+trg_sents[best[i]]+"\t"+str(s), file=fout)

    fout.close()

