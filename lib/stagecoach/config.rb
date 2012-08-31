# encoding: UTF-8
require 'psych'
require 'yaml'
require 'fileutils'

module Stagecoach
  class Config
    class << self
      def new
        File.open(CONFIG_FILE, 'w')
      end

      def open
        File.open(CONFIG_FILE, 'r+')
      end

      def yaml_to_hash
        YAML::load(Config.open) || {}
      end

      def save(hash, config_file = Config.open)
        original = yaml_to_hash
        updated = yaml_to_hash.merge(hash).to_yaml
        config_file.write(updated)
      end

      def check_if_outdated
        if File.exist?(OLD_CONFIG_FILE) && !File.exist?(CONFIG_FILE)
          FileUtils.move(OLD_CONFIG_FILE, CONFIG_FILE)
          puts "Stagecoach config is now at #{CONFIG_FILE}"
        end
      end

      def githook_install(source_dir, install_dir, file)
        FileUtils.cp(source_dir + file, install_dir + file)
        puts 'OK!'
        puts 'Making githook executable (may require admin password)'
        FileUtils.chmod(0711, ( install_dir + file ))
        puts 'OK!'
      end

      def setup
        # Say hello
        CommandLine.line_break
        puts "Stagecoach Initial Setup"
        CommandLine.line_break

        # Now scare everybody away again
        puts "You are running stagecoach from #{FileUtils.pwd.green}. Is this the root directory of your repository?"
        puts "Stagecoach may not work properly anywhere else! So proceed with caution"
        CommandLine.line_break
        print "[C]ontinue or [Q]uit:  "

        # Create a config file if necessary
        case STDIN.gets.chomp
        when /c/i
          Config.check_if_outdated
          Config.new unless File.exist?(CONFIG_FILE)
        when /q/i
          puts "Exiting..."
          exit
        end

        # Set up global github username if it is not there
        loop do
          if Git.global_config(:github, :user) == ""
            print "Please enter your github username:  "
            username = STDIN.gets.chomp
            case username
            when ""
              print "Github user can't be blank, please try again:"
              redo
            else
              Git.set_global_config(:github, :user, username)
            end
          end

          if Git.global_config(:github, :token) == ""
            print "Please enter your Github api token (you can find this at http://github.com/account/admin):  "
            case STDIN.gets.chomp
            when ""
              print "Github API key can't be blank, please try again:  "
              redo
            else
              Git.set_global_config(:github, :token, $_.chomp)
            end
          end
          break
        end

        # Install the commit-msg githook if it is not already there:
        source_dir = (File.dirname(__FILE__) + '/../githooks/')
        install_dir = FileUtils.pwd + '/.git/hooks/'
        git_hook = 'commit-msg'

        CommandLine.line_break
        puts "Would you like to install the stagecoach #{"commit-msg githook".green}?"
        puts "This automatically references stagecoach-created github issues from each commit you make"
        puts "Note that this will only affect branches created in stagecoach.  For more information run stagecoach -h"
        CommandLine.line_break
        print "[I]nstall or [S]kip this step:  "
        loop do
          case STDIN.gets.chomp
          when /i/i
            if File.exist?(install_dir + git_hook)
              case FileUtils.compare_file(source_dir + git_hook, install_dir + git_hook)
              when true
                puts 'The stagecoach githook is already installed in this repo. Skipping this step...'
                break
              when false
                puts "You have a commit-msg githook already.  Are you sure you want to install?  This will #{'overwrite'.red} your current commit-msg githook."
                print "[O]K or anything else to skip installation:  "
                case STDIN.gets.chomp
                when /o/i
                  Config.githook_install(source_dir, install_dir, git_hook)
                  break
                else
                  break
                end
              end
            else
              puts "Installing..."
              Config.githook_install(source_dir, install_dir, git_hook)
              break
            end
          when /s/i
            puts 'Skipping Installation.'
            break
          end
        end

        if not yaml_to_hash[:CONFIG_pivotal_tracker_api_token]
          print "Enter your Pivotal Tracker API token: "
          token = STDIN.gets.chomp
          save('CONFIG_pivotal_tracker_api_token' => token)
        end


        puts "Complete! Exiting..."
        exit

      end
    end
  end
end

class String
  def red; colorize(self, "\e[1m\e[31m"); end
  def green; colorize(self, "\e[32m"); end
  def colorize(text, color_code)  "#{color_code}#{text}\e[0m" end
end
