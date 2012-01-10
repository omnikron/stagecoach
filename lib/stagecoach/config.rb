require 'yaml'

module Stagecoach
  class Config
    def self.open
      File.open('../lib/config.yaml', 'r+')
    end

    def self.yaml_to_hash 
      YAML::load(self.open)
    end

    def self.save(hash, config_file)
      config_file.pos = 0
      config_file.write(hash.to_yaml)
    end
  end
end

class String
  def red; colorize(self, "\e[1m\e[31m"); end
  def green; colorize(self, "\e[32m"); end
  def colorize(text, color_code)  "#{color_code}#{text}\e[0m" end
end

