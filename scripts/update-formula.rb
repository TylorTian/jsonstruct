#!/usr/bin/env ruby
require "open-uri"
require "digest"

version = ARGV[0] or abort("Usage: ruby scripts/update-formula.rb <version>")
jsonstruct_url = "https://files.pythonhosted.org/packages/source/j/jsonstruct-cli/jsonstruct_cli-#{version}.tar.gz"
pyjwt_url = "https://files.pythonhosted.org/packages/source/p/pyjwt/pyjwt-2.10.1.tar.gz"

puts "🔽 Downloading #{jsonstruct_url}"
jsonstruct_tar = URI.open(jsonstruct_url).read
jsonstruct_sha = Digest::SHA256.hexdigest(jsonstruct_tar)
puts "✅ jsonstruct_sha: #{jsonstruct_sha}"

puts "🔽 Downloading #{pyjwt_url}"
pyjwt_tar = URI.open(pyjwt_url).read
pyjwt_sha = Digest::SHA256.hexdigest(pyjwt_tar)
puts "✅ pyjwt_sha: #{pyjwt_sha}"

formula_path = "../homebrew-tap/Formula/jsonstruct.rb"
abort("❌ Formula not found: #{formula_path}") unless File.exist?(formula_path)
content = File.read(formula_path)

content.gsub!(/(url\s+").*?(")/, "\\1#{jsonstruct_url}\\2")
content.gsub!(/(sha256\s+").*?(")/, "\\1#{jsonstruct_sha}\\2")

content.gsub!(/(resource\s+"pyjwt".*?\n\s*url\s+").*?(")/m, "\\1#{pyjwt_url}\\2")
content.gsub!(/(resource\s+"pyjwt".*?\n.*?\n\s*sha256\s+").*?(")/m, "\\1#{pyjwt_sha}\\2")

File.write(formula_path, content)
puts "✅ Updated #{formula_path}"

