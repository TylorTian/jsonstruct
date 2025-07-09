#!/usr/bin/env ruby
require "open-uri"
require "digest"

version = ARGV[0]
abort("Usage: ruby scripts/update-formula.rb <version>") unless version

pypi_url = "https://files.pythonhosted.org/packages/source/j/jsonstruct-cli/jsonstruct_cli-#{version}.tar.gz"
puts "🔽 Downloading #{pypi_url}"
file = URI.open(pypi_url).read
sha256 = Digest::SHA256.hexdigest(file)
puts "✅ SHA256: #{sha256}"

formula_path = "../homebrew-tap/Formula/jsonstruct.rb"
abort("❌ Formula not found at #{formula_path}") unless File.exist?(formula_path)

content = File.read(formula_path)
content.gsub!(/jsonstruct_cli-.*?\.tar\.gz"/, "jsonstruct_cli-#{version}.tar.gz\"")
content.gsub!(/sha256\s+\".*?\"/, "sha256 \"#{sha256}\"")
File.write(formula_path, content)

puts "✅ Updated #{formula_path}"
puts "🚀 Now run:\n  cd ../homebrew-tap && git commit -am 'bump: jsonstruct #{version}' && git push"

