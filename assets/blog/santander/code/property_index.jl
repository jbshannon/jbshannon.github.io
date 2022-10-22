# This file was generated, do not modify it. # hide
for (i, property) in enumerate(bp.additionalProperties)
    println("($i) ", property.key, " => ", property.value)
end