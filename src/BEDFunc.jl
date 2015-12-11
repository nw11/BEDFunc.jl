module BEDFunc

export bedtools_intersect
export convert_methpipebed_to_bedfile
export write_bedfile
include(Pkg.dir("BEDFunc","src","bedtools_intersect.jl"))

export load_dataframe_from_url
include(Pkg.dir("BEDFunc","src","misc.jl"))

export query
export BEDQuery
export bgzip_and_index
include(Pkg.dir("BEDFunc","src","tabix.jl"))

export parse_gtf_gene_features_to_df
include(Pkg.dir("BEDFunc","src","gtf.jl"))
end # module
