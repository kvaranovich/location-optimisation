function get_osm_by_bbox(left, bottom, right, top, output_file = "map.osm")
    URL = "https://overpass-api.de/api/map?bbox=" * join([left, bottom, right, top], ",")
    download(URL, output_file)
end
