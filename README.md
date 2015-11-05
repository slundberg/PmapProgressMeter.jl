# PmapProgressMeter

[![Build Status](https://travis-ci.org/slundberg/PmapProgressMeter.jl.svg?branch=master)](https://travis-ci.org/slundberg/PmapProgressMeter.jl)

This is a simple wrapper around `pmap` that uses the `ProgressMeter` package. It takes care of getting the synchronization right among parallel workers.

## Installation

```julia
Pkg.clone("https://github.com/slundberg/PmapProgressMeter.jl")
```

## Usage

```julia
using ProgressMeter
using PmapProgressMeter

pmap(Progress(10), x->begin sleep(1); x end, 1:10)
```
