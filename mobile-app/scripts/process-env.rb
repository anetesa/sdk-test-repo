#!/usr/bin/env ruby

require 'fileutils'
require 'pathname'

# Configuration of the .env.* and prefixes
ENV_CONFIGS = [
  { file: '.env.development', prefix: 'DEV' },
  { file: '.env.uat',         prefix: 'UAT' },
  { file: '.env.production',  prefix: 'PROD' }
]

def process_env_file(file_path, prefix)
  return '' unless File.exist?(file_path)
  content = File.read(file_path, encoding: 'UTF-8')
  lines   = content.split("\n")
  result  = []
  app_env_line = nil

  lines.each do |line|
    stripped = line.strip
    if stripped.empty? || stripped.start_with?('#')
      result << line
    elsif stripped =~ /^([^=]+)=(.*)$/
      key, value = $1.strip, $2.strip
      # Critical change: Do NOT prefix APP_ENV. Separate it.
      if key == 'APP_ENV'
        app_env_line = "#{key}=#{value}"
      else
        new_key = "#{prefix}_#{key}"
        result << "#{new_key}=#{value}"
      end
    else
      result << line
    end
  end

  # Return the app_env line and the rest of the block
  { app_env: app_env_line, block: result.join("\n") }
end

def process_all_env_files
  project_root = Pathname.new(__FILE__).parent.parent
  all_blocks   = []
  app_env_lines = {} # Store APP_ENV for each env

  ENV_CONFIGS.each do |cfg|
    path_str = project_root.join(cfg[:file]).to_s
    processed = process_env_file(path_str, cfg[:prefix])
    
    unless processed.empty?
      all_blocks << processed[:block] unless processed[:block].empty?
      # Store the APP_ENV line, keyed by the prefix
      app_env_lines[cfg[:prefix]] = processed[:app_env] if processed[:app_env]
    end
  end

  # Determine which APP_ENV to use. We assume only one .env.* exists
  # or that we can infer it. This logic may need to be more robust
  # depending on the build process. For now, we find the first available.
  final_app_env = app_env_lines.values.compact.first

  if all_blocks.any?
    # Prepend the single, correct APP_ENV line to the top
    final_content = [final_app_env, all_blocks.join("\n\n")].compact.join("\n\n")

    env_path = project_root.join('.env')
    File.write(env_path, final_content + "\n")
    if ARGV.include?('--verbose')
      vars = final_content.lines.count { |l| l.include?('=') && !l.start_with?('#') }
      puts "📊 #{vars} variables processed"
      puts "✅ Written to #{env_path}"
    end
  else
    puts "❌ Files not processed" if ARGV.include?('--verbose')
  end
end

if __FILE__ == $0
  process_all_env_files
end