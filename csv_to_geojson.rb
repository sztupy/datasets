#!/usr/bin/env ruby

require 'fileutils'
require 'csv'
require 'json'

Dir.glob("**/*.csv") do |filename|
  puts "Converting #{filename}"
  begin
    locations = []
    CSV.open(filename, headers: true) do |csv|
      csv.each do |row|
        lat = nil
        lon = nil
        if row['Latitude'] && row['Longitude']
          lat = row['Latitude']
          lon = row['Longitude']
        elsif row['Location']
          lat, lon = *row['Location'].split(',')
        elsif row['Location map']
          lat, lon = *row['Location map'].split(',')
        elsif row['Map']
          lat, lon = *row['Map'].split(',')
        end
        if lat && lon
          locations << [lat, lon, row]
        end
      end
    end

    if !locations.empty?
      data = {
        type: 'FeatureCollection',
        features: []
      }

      File.open(filename + '.geojson', 'w+') do |out|
        locations.each do |loc|
          feature = {
            type: 'Feature',
            geometry: {
              type: 'Point',
              coordinates: [ loc[1], loc[0] ]
            },
            properties: {}
          }
          loc[2].each do |k,v|
            feature[:properties][k] = v
          end

          data[:features] << feature
        end

        out.puts data.to_json
      end
    end
  rescue => e
    puts "Error converting #{filename}: #{e}"
  end
end
