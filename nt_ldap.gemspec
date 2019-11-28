lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nt_ldap/version"

Gem::Specification.new do |spec|
  spec.name          = "nt_ldap"
  spec.version       = NtLdap::VERSION
  spec.authors       = ["Tsutomu Nakamura"]
  spec.email         = ["tsuna.0x00@gmail.com"]

  spec.summary       = %q{LDAP migration tool from AD to NT schema}
  spec.description   = %q{This tool migrate AD LDAP entries to NT LDAP entries.}
  spec.homepage      = "https://github.com/TsutomuNakamura/nt_ldap"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
