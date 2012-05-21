module Stagecoach
  class Capistrano
    class << self
      def deploy(branch)
        CommandLine.line_break
        branch = branch =~ /master/i ? 'production' : branch

        puts "Deploying to #{branch}"
        puts `bundle exec cap #{branch} deploy`
      end
    end
  end
end
