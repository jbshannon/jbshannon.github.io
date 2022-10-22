# This file was generated, do not modify it. # hide
base_url = "https://api.tfl.gov.uk/BikePoint/BikePoints_"
station_id = "809"
r = HTTP.get(base_url * station_id)
r.body |> String |> JSON3.read |> print_bike_point