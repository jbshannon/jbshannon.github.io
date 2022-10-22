# This file was generated, do not modify it. # hide
r = HTTP.get(
    "https://api.tfl.gov.uk/BikePoint/Search";
    query=["query" => "Lincoln's Inn Fields"]
)
@show search_results = r.body |> String |> JSON3.read