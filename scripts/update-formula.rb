#!/usr/bin/env ruby
require "digest"
require "fileutils"
require "open-uri"

version = ARGV[0]
abort("Usage: ruby update-formula.rb VERSION") unless version

tarball_url = "https://files.pythonhosted.org/packages/source/j/jsonstruct-cli/jsonstruct_cli-#{version}.tar.gz"
tarball_path = "jsonstruct_cli-#{version}.tar.gz"

puts "🔽 Downloading #{tarball_url}"
URI.open(tarball_url) do |r|
  File.open(tarball_path, "wb") { |f| f.write(r.read) }
end

sha256 = Digest::SHA256.file(tarball_path).hexdigest
puts "✅ SHA256: #{sha256}"

formula_path = "Formula/jsonstruct.rb"
content = File.read(formula_path)

new_content = content
  .gsub(/jsonstruct_cli-[\d.]+\.tar\.gz/, "jsonstruct_cli-#{version}.tar.gz")
  .gsub(/sha256 "[a-f0-9]{64}"/, "sha256 \"#{sha256}\"")

File.write(formula_path, new_content)
puts "✅ Updated #{formula_path}"

