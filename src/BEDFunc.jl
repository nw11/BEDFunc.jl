module BEDFunc

export bedtools_intersect
export convert_methpipebed_to_bedfile
include(Pkg.dir("BEDFunc","src","bedtools_intersect.jl"))

export load_dataframe_from_url
include(Pkg.dir("BEDFunc","src","misc.jl"))
end # module
