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
  stagecoach -s[tory] 4115 -b[ranch] my_new_branch -f[rom] branch_to_branch_out_from

Push:
  stagecoach -p

Deploy:
  stagecoach -d staging

For more info see the readme at https://github.com/omnikron/stagecoach#readme

#{"Flags".red}
        EOS
        opt :config, "Set Stagecoach's basic settings"
        opt :deploy, "Deploy from your current branch to any branch you choose, eg. stagecoach -d staging", :type => :string, :default => "staging"
        opt :from, "Set the branch from which you want to create a new branch with -b.  Default is master", :type => :string, :default => "master"
        opt :branch, "Enter your new branch name here, eg. stagecoach -b new_branch (optional)", :type => :string
        opt :push, "Use this option to push your changes to your remote branch (will be created if necessary)"
        opt :github, "Github issue number (if using github issue tracking), eg. stagecoach -g 1234", :type => :string
        opt :story, "Your pivotal tracker story number", :type  => :string
        opt :list, "List local branches which you have created with Stagecoach"
        opt :tidy, "Remove all branches that are already merged to master. Acts both remotely and locally."
        opt :version, "Prints the current version"
      end
    end
  end
end
