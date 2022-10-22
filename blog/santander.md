+++
title = "Jack Shannon | Looking for Santander Cycles with Shortcuts"
date = Date(2022, 10, 22)
+++

# Using Shortcuts to Check Santander Cycles

TfL's Santander Cycles have been my favorite way to get around central London since I first tried them during Covid lockdowns. The annual subscription (with a student discount!) means I can make short journeys faster than on a bus, sometimes even faster than on the tube. But I had one problem when making the journey into LSE – often I would arrive to find every docking station completely full, meaning I had to pull out my phone to search for the nearest available docking space. That's not the most elegant thing to do when you're pulled over on the side of a busy road straddling a bike, especially when the app turns out to be frozen. I wanted to find an easier way to check for empty spaces near my destination.

In this post I show how to get the number of bikes and empty docks at any station using the [TfL API](https://tfl.gov.uk/info-for/open-data-users/unified-api#on-this-page-1) and then show the steps to do this in the Shortcuts app. The Shortcut can be run from the Shortcuts app, from your iPhone or iPad's home screen as a standalone app or within a widget, from Siri, from your Mac's task bar, or even from a complication on your Apple Watch face. If you'd like to use these shortcuts yourself, here are the iCloud sharing links:

- [Get Santander Cycle Feed](https://www.icloud.com/shortcuts/c09620f69b804c62a11f2c8bb4b2b5ef)
- [Check Bikes Example](https://www.icloud.com/shortcuts/d02693b7d1204478a7cf881c6c4de5db)

## The TfL API

TfL has developed a [unified API](https://tfl.gov.uk/info-for/open-data-users/unified-api#on-this-page-1) that provides real-time information about its services to anyone with the appropriate programming know-how. The API provides a [`BikePoint`](https://api.tfl.gov.uk/swagger/ui/index.html?url=/swagger/docs/v1#!/BikePoint/BikePoint_GetAll) endpoint that returns information about all docking stations. Let's pull this information and see what the JSON data for a single bikepoint looks like:

```julia:./code/req_all
using HTTP, JSON3
r = HTTP.get("https://api.tfl.gov.uk/BikePoint")
bikepoints = r.body |> String |> JSON3.read
bp = first(bikepoints)
JSON3.pretty(bp)
```
\output{./code/req_all}

There's a lot going on here, but the important things we observe are:

- The unique `id` field will let us query the API for just this station
- The `commonName` field gives the name of the station as it appears in the app
- The information we want (the number of bikes/E-bikes and empty docking points) live inside the `additionalProperties` field

The structure of the `additionalProperties` field is a bit odd in that the keys are actually values themselves, so we can't access them by name. Let's get the index of each key-value pair:

```julia:./code/property_index
for (i, property) in enumerate(bp.additionalProperties)
    println("($i) ", property.key, " => ", property.value)
end
```
\output{./code/property_index}

So the indices we care about are `[8, 10, 11]`.

```julia:./code/read_first
function print_bike_point(bp)
    println("$(bp.commonName) (id: $(bp.id))")
    println("Number of standard bikes: $(bp.additionalProperties[10].value)")
    println("Number of E-bikes: $(bp.additionalProperties[11].value)")
    println("Number of empty docks: $(bp.additionalProperties[8].value)")
end

print_bike_point(bp)
```
\output{./code/read_first}

Now that we know how to get the information we want for any station, we need to find the IDs of the stations we want to include in our search. The API provides a `BikePoint/Search` endpoint where we can search stations by name:

```julia:./code/search_ex
r = HTTP.get(
    "https://api.tfl.gov.uk/BikePoint/Search";
    query=["query" => "Lincoln's Inn Fields"]
)
@show search_results = r.body |> String |> JSON3.read
```
\output{./code/search_ex}

Now that we have the ID, we can use the `BikePoint/{id}` endpoint to request data for that bike point only:

```julia:./code/req809
base_url = "https://api.tfl.gov.uk/BikePoint/BikePoints_"
station_id = "809"
r = HTTP.get(base_url * station_id)
r.body |> String |> JSON3.read |> print_bike_point
```
\output{./code/req809}

## Accessing the API through Shortcuts

Apple's Shortcuts app is able to read JSON objects as dictionaries, so with a little manipulation (and a lot of dragging and dropping) we can replicate the results of the above API call. I wanted to be able to run my Shortcut for multiple destinations (e.g. work, home, etc.), so I separated the Shortcut into two: an inner Shortcut to receive a list of stations and return a list of messages, and an outer Shortcut to pass a list of stations to the inner Shortcut and display the results as an alert.

### The Inner Shortcut: Accessing the API

The steps to follow are:

1. Set the base URL
2. Add the station ID to the URL
3. Request the data from the API
4. Parse the response into a dictionary
5. Extract the station's `commonName`
6. Extract the `additionalProperties` as a list
   1. Get the number of standard bikes at index 10
   2. Get the number of E-bikes at index 11
   3. Get the number of empty docks at index 8
7. Combine the results into text that can be displayed

#### Setting the Base URL

![Setting the base URL](https://i.imgur.com/pxozQqv.jpg)

#### Constructing the API Call

We begin looping over every item in the list:

![Constructing the API Call](https://i.imgur.com/9xawuLo.jpg)

#### Parsing the API Response

![Parsing the API Response](https://i.imgur.com/TOyDXSe.jpg)

#### Getting the Station Name

![Getting the Station Name](https://i.imgur.com/IDb1pZp.jpg)

#### Getting the Station Properties

Because we want to access the `additionalProperties` dictionary multiple times, we have to create a variable for it:

![Getting the Station Properties](https://i.imgur.com/Fl5qHd5.jpg)

Scripting functionality in Shortcuts is fairly limited, so I had to hardcode the next three steps rather than using something like a loop:

![Imgur](https://i.imgur.com/2NKDqoe.jpg)

![Imgur](https://i.imgur.com/w3SphGm.jpg)

![Imgur](https://i.imgur.com/TPAqt0b.jpg)

#### Constructing the Output

Now I combine everything into a single message. I leave an emtpy line at the top so that when the Shortcut returns multiple stations they are separated by a space. I chose to represent each number with an emoji since it saves visual space, allowing all three numbers to fit into one line on my watch.

When you tell Siri to run the shortcut, the results are read aloud. This can sound pretty confusing with the output text I currently have written, but you can tweak the text output to make it sound more natural when spoken if you prefer to run the Shortcut through Siri.

![Constructing the Output](https://i.imgur.com/s6tX0Ng.jpg)

### The Outer Shortcut: Making a List of Stations

Constructing a list of stations you want to be included in the Shortcut can be a bit difficult, depending on how you approach it. I used the map in the mobile app to find the names of the stations I wanted to include and looked up the ID for each station. You can do this using the API, but I found it quicker to look up the [XML feed](https://tfl.gov.uk/tfl/syndication/feeds/cycle-hire/livecyclehireupdates.xml) and search for the station name using my browser (the number you need for the shortcut is the `<id>` field, not `<terminalName>`).

Once we've done that, the Shortcut itself is very simple:

![Outer Shortcut](https://i.imgur.com/T4x9Xgg.jpg)

Running the Shortcut produces a native alert:

![Outer Shortcut Result](https://i.imgur.com/3ehTuKz.jpg)

The great advantage of this Shortcut is that you can get these results are incredibly accessible because Shortcuts are built into iOS. You can add the Shortcut to your home screen as an icon, run it from a widget, access it from your Mac's task bar, or even run it from a complication on your watch face:

![Outer Shortcut Result on Apple Watch](https://i.imgur.com/jGhff4h.png)

I use this Shortcut pretty much every time I leave the house, and it's saved me from riding up to an empty station more times than I can count. If you'd like to try them out for yourself, here are the iCloud sharing links:

- [Get Santander Cycle Feed](https://www.icloud.com/shortcuts/c09620f69b804c62a11f2c8bb4b2b5ef)
- [Check Bikes Example](https://www.icloud.com/shortcuts/d02693b7d1204478a7cf881c6c4de5db)