
using Base.Test
DIR = dirname(dirname(@__FILE__()))
path=joinpath(DIR,"src/gtf.jl")
include(path)
filename = joinpath(DIR,"testdata/gencode.v25.annotation.100.gtf")
df=parse_gtf_gene_features_to_df(filename, [], ["gene"])


@test nrow(df) == 13
