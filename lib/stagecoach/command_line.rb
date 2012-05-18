module Stagecoach
  class CommandLine
    def self.line_break
      puts  "\n"
    end

    def self.trollop
      require 'trollop'
      # Command line options using Trollop.
      Trollop::options do
        version "Stagecoach %s" % VERSION
        banner <<-EOS
Usage
-----
Init stage:
  stagecoach -r[edmine] 4115 (or -g[ithub] 525) -b[ranch] my_new_branch -f[rom] branch_to_branch_out_from

Push:
  stagecoach -p

Deploy:
  stagecoach -d staging

For more info see the readme at https://github.com/omnikron/stagecoach#readme


#{"Flags".red}
        EOS
        opt :branch, "Enter your new branch name here, eg. stagecoach -b new_branch (optional)", :type => :string
        opt :deploy, "Use this option to  deploy from your current branch to any branch you choose, eg. stagecoach -d staging", :type => :string 
        opt :from, "Use this option to set the branch you want to branch off from.  Default is master", :type => :string, :default => "master"
        opt :github, "Enter your github issue number here, eg. stagecoach -g 1234 (optional)", :type => :string
        opt :list, "Use this to list local branches which you have created with Stagecoach"
        opt :push, "Use this option to push your changes to your remote branch (will be created if necessary)"
        opt :redmine, "Enter your redmine/planio issue number here, eg. stagecoach -r 1234 (optional)", :type  => :string
        opt :setup, "Use this the first time you run stagecoach to save your redmine repository and api key"
        opt :version, "Prints the current version"
      end
    end
  end
end
