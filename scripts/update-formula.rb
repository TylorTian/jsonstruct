#!/usr/bin/env ruby
require "open-uri"
require "digest"

version = ARGV[0] or abort("Usage: ruby scripts/update-formula.rb <version>")

# URLs for source distributions
jsonstruct_url = "https://files.pythonhosted.org/packages/source/j/jsonstruct-cli/jsonstruct_cli-#{version}.tar.gz"
pyjwt_url = "https://files.pythonhosted.org/packages/source/p/pyjwt/pyjwt-2.10.1.tar.gz"

# Helper to retry downloads
def retry_download(url, max_retries: 5, delay: 5)
  retries = 0
  begin
    return URI.open(url).read
  rescue OpenURI::HTTPError => e
    retries += 1
    if retries < max_retries
      puts "⏳ Waiting #{delay}s and retrying (#{retries}/#{max_retries})..."
      sleep delay
      retry
    else
      abort("❌ Failed to download #{url} after #{max_retries} attempts: #{e.message}")
    end
  end
end

# Download and hash jsonstruct
puts "🔽 Downloading #{jsonstruct_url}"
jsonstruct_tar = retry_download(jsonstruct_url)
jsonstruct_sha = Digest::SHA256.hexdigest(jsonstruct_tar)
puts "✅ jsonstruct_sha: #{jsonstruct_sha}"

# Download and hash pyjwt
puts "🔽 Downloading #{pyjwt_url}"
pyjwt_tar = retry_download(pyjwt_url)
pyjwt_sha = Digest::SHA256.hexdigest(pyjwt_tar)
puts "✅ pyjwt_sha: #{pyjwt_sha}"

# Update formula file in homebrew-tap repo
formula_path = File.expand_path("../../homebrew-tap/Formula/jsonstruct.rb", __dir__)
abort("❌ Formula not found: #{formula_path}") unless File.exist?(formula_path)
content = File.read(formula_path)

# Replace url and sha256 for jsonstruct package
content.gsub!(/(url\s+").*?("\n)/, "\\1#{jsonstruct_url}\\2")
content.gsub!(/(sha256\s+").*?("\n)/, "\\1#{jsonstruct_sha}\\2")

# Replace resource URL and sha for pyjwt
content.gsub!(/(resource\s+"pyjwt".*?\n\s*url\s+").*?("\n)/m, "\\1#{pyjwt_url}\\2")
content.gsub!(/(resource\s+"pyjwt".*?\n.*?\n\s*sha256\s+").*?("\n)/m, "\\1#{pyjwt_sha}\\2")

# Write back to formula
File.write(formula_path, content)
puts "✅ Updated #{formula_path}"

