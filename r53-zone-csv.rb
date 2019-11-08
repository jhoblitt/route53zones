#!/usr/bin/env ruby
#
# Given an AWS account and a hardcoded prefix for reverse DNS, enumerate all matching hosted
# zones, look up the NS and SOA records, and jam everything into a CSV for handoff.

require 'json'
require 'pp'
require 'csv'

PREFIX = "229.139"

text = %x{aws route53 list-hosted-zones --no-paginate}

json = JSON.parse(text)

zones = json["HostedZones"].select do |entry|
  entry["Name"] =~ Regexp.new(Regexp.escape(PREFIX))
end

full = zones.map do |zone|
  output = %x{aws route53 list-resource-record-sets --hosted-zone-id #{zone["Id"]}}
  parsed = JSON.parse(output)
  pp parsed
  zone.merge(parsed)
end

rows = full.map do |zone|
  [
    zone["Id"].split("/").last,
    zone["Name"],
    zone["ResourceRecordSets"].find {|r| r["Type"] == "SOA"}["ResourceRecords"].map(&:values).join(" "),
    zone["ResourceRecordSets"].find {|r| r["Type"] == "NS"}["ResourceRecords"].map(&:values).join(" "),
  ]
end

CSV.open("final.csv", "w") do |csv|
  rows.each do |row|
    csv << row
  end
end
