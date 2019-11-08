#!/usr/bin/env ruby

IO.read('zones.txt').split.each do |z|
  sanitized_name = z.dup
  # tf does not like `.` in resource names
  sanitized_name.tr!('.', '_')

  tmpl = <<~HCL
    resource "aws_route53_zone" "#{sanitized_name}" {
      name = "#{z}"
    }

  HCL

  puts tmpl
end
