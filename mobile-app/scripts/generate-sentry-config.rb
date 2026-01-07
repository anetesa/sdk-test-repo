#!/usr/bin/env ruby

require 'fileutils'
require 'pathname'

def generate_sentry_config
  project_root = Pathname.new(__FILE__).parent.parent
  ios_path = project_root.join('ios')
  sentry_properties_path = ios_path.join('sentry.properties')
  
  # Read variables from .env file
  env_file = project_root.join('.env')
  
  unless File.exist?(env_file)
    puts "❌ .env file not found. Run 'ruby scripts/process-env.rb' first"
    exit 1
  end
  
  # Read variables from .env file
  env_vars = {}
  File.readlines(env_file).each do |line|
    line.strip!
    next if line.empty? || line.start_with?('#')
    
    if line.include?('=')
      key, value = line.split('=', 2)
      env_vars[key.strip] = value.strip
    end
  end
  
  # Get APP_ENV (which should NOT have a prefix) and determine the prefix
  app_env = env_vars['APP_ENV']
  
  unless app_env
    puts "❌ APP_ENV not found in .env file"
    puts "💡 Add APP_ENV to your .env file (e.g., development, uat, or production)"
    exit 1
  end
  
  # Map APP_ENV to the correct prefix for other variables
  prefix_map = {
    'development' => 'DEV',
    'uat' => 'UAT',
    'production' => 'PROD'
  }
  
  prefix = prefix_map[app_env.downcase]
  
  unless prefix
    puts "❌ Invalid APP_ENV: #{app_env}"
    puts "💡 APP_ENV must be one of: development, uat, or production"
    exit 1
  end
  
  if ARGV.include?('--verbose')
    puts "🔧 Using environment: #{app_env} (prefix: #{prefix})"
  end
  
  # Search for Sentry variables with the corresponding prefix
  auth_token = env_vars["#{prefix}_APP_SENTRY_AUTH_TOKEN"]
  org = env_vars["#{prefix}_APP_SENTRY_ORG"]
  project = env_vars["#{prefix}_APP_SENTRY_PROJECT"]
  url = env_vars["#{prefix}_APP_SENTRY_URL"]
  
  # Verify that we have the token
  unless auth_token
    puts "❌ #{prefix}_APP_SENTRY_AUTH_TOKEN not found in .env file"
    puts "💡 Ensure #{prefix}_APP_SENTRY_AUTH_TOKEN is defined in your .env files"
    exit 1
  end
  
  # Generate content, using defaults only if the prefixed variable is missing
  content = [
    "auth.token=#{auth_token}",
    "defaults.org=#{org || 'medina-tc'}",
    "defaults.project=#{project || 'react-nativetwo'}",
    "defaults.url=#{url || 'https://sentry.io/'}",
    "defaults.auto_upload=false",
    ""
  ].join("\n")
  
  # Write file
  File.write(sentry_properties_path, content)
  
  if ARGV.include?('--verbose')
    puts "✅ Sentry configuration generated"
    puts "📁 Location: #{sentry_properties_path}"
    puts "🔧 Using org: #{org}"
    puts "🔧 Using project: #{project}"
    puts "🔧 Auth token: Set"
  end
end

if __FILE__ == $0
  generate_sentry_config
end