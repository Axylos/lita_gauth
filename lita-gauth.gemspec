Gem::Specification.new do |spec|
  spec.name          = "lita-gauth"
  spec.version       = "0.1.0.4"
  spec.authors       = ["Axylos"]
  spec.email         = ["robertdraketalley@gmail.com"]
  spec.description   = "auth with google api"
  spec.summary       = "client for google auth"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.7"
  spec.add_dependency "google_auth_box", ">= 0.1.0"

  spec.add_development_dependency "bundler", "~> 1.3"

  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
end
