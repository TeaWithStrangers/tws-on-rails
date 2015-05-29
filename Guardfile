guard 'zeus' do
  # When a spec file changes, run it
  watch(%r{^spec/.+_spec\.rb$})

  # When a file in app/ changes
  watch(%r{^app/(.+)\.rb$})                           { |m| file_if_exists(m[1])        }

  # When a file in lib/ changes
  watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb"    }

  # When a file in app/controllers/ changes
  watch(%r{^app/controllers/(.+)_controller\.rb$})  { |m| controller_files(m[1])  }
end

def controller_files(resource)
  files = [
    "spec/controllers/#{resource}_controller_spec.rb",      # appropriate controller spec
    "spec/requests/#{resource}/",                           # all files in director of same name in spec/requests/
    "spec/requests/#{resource}_request_spec.rb",            # single file of same name in spec/requests/
    "spec/acceptance/#{resource}_acceptance_spec.rb"        # appropriate acceptance spec
  ]
  existing_files = files.select { |file| file if File.exists?(file) }
  puts "Running these files:\n #{existing_files}"
  existing_files
end

def file_if_exists(capture)
  filename = "spec/#{capture}_spec.rb"
  File.exists?(filename) ? filename : nil
end
