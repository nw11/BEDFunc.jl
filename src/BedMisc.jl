module BedMisc

export bedtools_intersect
export convert_methpipebed_to_bedfile
include(Pkg.dir("BedMisc","src","bedtools_intersect.jl"))

end # module
