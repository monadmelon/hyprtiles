-- HyprTiles Tilemaker Processing Script

local highway_class = {
    motorway = "motorway", motorway_link = "motorway",
    trunk = "trunk", trunk_link = "trunk",
    primary = "primary", primary_link = "primary",
    secondary = "secondary", secondary_link = "secondary",
    tertiary = "tertiary", tertiary_link = "tertiary",
    unclassified = "minor", residential = "minor",
    living_street = "minor", service = "service",
    track = "track", path = "path", footway = "path",
    cycleway = "path", pedestrian = "path", steps = "path"
}

function node_function(node)
    local place = node:Find("place")
    local name = node:Find("name")
    
    if place ~= "" and name ~= "" then
        node:Layer("place", false)
        node:Attribute("name", name)
        node:Attribute("class", place)
        if place == "city" then node:MinZoom(5)
        elseif place == "town" then node:MinZoom(8)
        elseif place == "village" then node:MinZoom(10)
        else node:MinZoom(12) end
    end
    
    local amenity = node:Find("amenity")
    local tourism = node:Find("tourism")
    if amenity == "hospital" or amenity == "school" or tourism == "hotel" then
        node:Layer("poi", false)
        node:Attribute("name", name)
        node:Attribute("class", amenity ~= "" and amenity or tourism)
        node:MinZoom(14)
    end
end

function way_function(way)
    local highway = way:Find("highway")
    local waterway = way:Find("waterway")
    local natural = way:Find("natural")
    local landuse = way:Find("landuse")
    local building = way:Find("building")
    local leisure = way:Find("leisure")
    local name = way:Find("name")
    
    -- Water
    if natural == "water" or landuse == "reservoir" then
        way:Layer("water", true)
        way:Attribute("class", "water")
        if name ~= "" then way:Attribute("name", name) end
        way:MinZoom(6)
        return
    end
    
    if waterway ~= "" then
        way:Layer("waterway", false)
        way:Attribute("class", waterway)
        way:MinZoom(waterway == "river" and 8 or 11)
        return
    end
    
    if natural == "coastline" then
        way:Layer("water", true)
        way:Attribute("class", "ocean")
        way:MinZoom(0)
        return
    end
    
    -- Landcover
    if natural == "beach" then
        way:Layer("landcover", true)
        way:Attribute("class", "sand")
        way:MinZoom(10)
        return
    end
    
    if natural == "wood" or landuse == "forest" then
        way:Layer("landcover", true)
        way:Attribute("class", "wood")
        way:MinZoom(9)
        return
    end
    
    -- Parks
    if leisure == "park" or leisure == "garden" then
        way:Layer("park", true)
        way:Attribute("class", leisure)
        if name ~= "" then way:Attribute("name", name) end
        way:MinZoom(11)
        return
    end
    
    -- Landuse
    if landuse == "residential" or landuse == "commercial" or landuse == "industrial" then
        way:Layer("landuse", true)
        way:Attribute("class", landuse)
        way:MinZoom(11)
        return
    end
    
    -- Buildings
    if building ~= "" and building ~= "no" then
        way:Layer("building", true)
        way:MinZoom(13)
        return
    end
    
    -- Roads
    if highway ~= "" then
        local class = highway_class[highway]
        if class then
            way:Layer("transportation", false)
            way:Attribute("class", class)
            if name ~= "" then way:Attribute("name", name) end
            if class == "motorway" or class == "trunk" then way:MinZoom(5)
            elseif class == "primary" then way:MinZoom(7)
            elseif class == "secondary" then way:MinZoom(9)
            elseif class == "tertiary" then way:MinZoom(10)
            elseif class == "minor" then way:MinZoom(12)
            else way:MinZoom(13) end
        end
    end
end

function relation_scan_function(relation)
    if relation:Find("type") == "multipolygon" then
        local natural = relation:Find("natural")
        if natural == "water" then relation:Accept() end
    end
end

function relation_function(relation)
    local natural = relation:Find("natural")
    local name = relation:Find("name")
    if natural == "water" then
        relation:Layer("water", true)
        relation:Attribute("class", "water")
        if name ~= "" then relation:Attribute("name", name) end
        relation:MinZoom(6)
    end
end
