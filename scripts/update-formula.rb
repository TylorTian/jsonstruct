require 'digest'
require 'open-uri'

version = ARGV[0] or abort("usage: ruby update-formula.rb <version>")
tar_url = "https://files.pythonhosted.org/packages/source/j/jsonstruct-cli/jsonstruct_cli-\#{version}.tar.gz"
tar_file = "jsonstruct_cli-\#{version}.tar.gz"

puts "Fetching \#{tar_url}..."
File.write(tar_file, URI.open(tar_url).read, mode: 'wb')
sha256 = Digest::SHA256.file(tar_file).hexdigest
puts "SHA256: \#{sha256}"

rb_file = "Formula/jsonstruct.rb"
content = File.read(rb_file)
content.gsub!(/jsonstruct_cli-.*?\.tar\.gz",\n  sha256 ".*?"/, "jsonstruct_cli-\#{version}.tar.gz",\n  sha256 "\#{sha256}")
File.write(rb_file, content)
puts "Updated \#{rb_file}"
