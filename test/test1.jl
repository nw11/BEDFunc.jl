#Note: you have to ensure, when in an interactive session (e.g. atom)
# That BEDFunc isn't loaded from somewhere else and you are
#  not getting conflicts with this. 
using Base.Test
DIR = dirname(dirname(@__FILE__()))
path=joinpath(DIR,"src/gtf.jl")
include(path)
filename = joinpath(DIR,"testdata/gencode.v25.annotation.100.gtf")
df=parse_gtf_gene_features_to_df(filename, [], ["gene"])
@test nrow(df) == 13

filename = joinpath(DIR,"testdata/gencode.v25.annotation.100.gtf.gz")
df=parse_gtf_gene_features_to_df(filename, [], ["gene"])
@test nrow(df) == 13
