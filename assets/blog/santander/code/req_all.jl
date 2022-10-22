# This file was generated, do not modify it. # hide
using HTTP, JSON3
r = HTTP.get("https://api.tfl.gov.uk/BikePoint")
bikepoints = r.body |> String |> JSON3.read
bp = first(bikepoints)
JSON3.pretty(bp)