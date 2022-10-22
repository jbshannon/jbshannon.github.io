# This file was generated, do not modify it. # hide
function print_bike_point(bp)
    println("$(bp.commonName) (id: $(bp.id))")
    println("Number of standard bikes: $(bp.additionalProperties[10].value)")
    println("Number of E-bikes: $(bp.additionalProperties[11].value)")
    println("Number of empty docks: $(bp.additionalProperties[8].value)")
end

print_bike_point(bp)