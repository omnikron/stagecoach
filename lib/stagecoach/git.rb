module Stagecoach
  class Git
    class << self
      def branches
        `git branch`.split("\n").collect(&:strip)
      end

      def list(local_stagecoach_branches, all_branches_list)
        deletable_branches = []
        local_stagecoach_branches.keys.sort.each do |branch_name|
          # branch_attributes = local_stagecoach_branches[branch_name]
          if all_branches_list.include?(branch_name.strip)
            if Git.branch_merged_to_master?(branch_name)
              puts branch_name  + " *".red
              deletable_branches << branch_name
            else
             puts branch_name
            end
          end
        end
        CommandLine.line_break
        puts "*".red + " = merged to master, can be deleted by stagecoach -t" if deletable_branches.length > 0
        CommandLine.line_break
        deletable_branches
      end

      def local_stagecoach_branches(config)
        local_stagecoach_branches = {}
        config.each { |k,v| local_stagecoach_branches[k] = v unless k =~ /redmine_site|redmine_api_key|redmine_user_id|master|staging/i}
      end

      def tidy(deletable_branches)
        CommandLine.line_break
        if deletable_branches.length > 0
          puts "All branches that have been merged into master will be deleted locally and remotely.".red
          print "Continue? [Y]es or anything else to cancel: "
          case STDIN.gets.chomp
          when /^y/i
            erase(deletable_branches)
          else
            puts 'No branches deleted.  Exiting...'
          end
        else
          puts 'No fully-merged branches found.  Exiting without doing anything.'
        end
        exit
      end

      def remote_branches
        (`git ls-remote`.split(" ").each.select { |e| e =~ /refs\/heads/}).collect {|a| a.gsub("refs/heads/", "")}
      end

      def erase(list)
        change_to_branch('master')
        branches_on_remote = Git.remote_branches
        list.each {|b| delete_branch(b, branches_on_remote ) }
      end

      def delete_branch(branch, list)
        puts "Local: " + `git branch -D #{branch}`
        if list.include?(branch)
          puts "Remote: "
          puts `git push origin :#{branch}`
        end
      end

      def global_config(header, config)
        `git config --global #{header}.#{config}`
      end

      def set_global_config(header, config, value)
        `git config --global #{header}.#{config} #{value}`
      end

      def changes
        `git diff-files --name-status -r --ignore-submodules`
      end

      def status
        `git status`
      end

      def current_branch
        branches.each do |b|
          if b =~ /\*/
            return b[1..-1].strip
          end
        end
      end

      def branch_merged_to_master?(branch)
         @list ||= `git branch --merged master`.split("\n").collect(&:strip)
         @list.include?(branch.strip)
      end


      def correct_branch?
        CommandLine.line_break
        print "You are currently in local branch: #{Git.current_branch.red} \nAre these details correct? ([Y]es or [Q]uit):  "
        case STDIN.gets.chomp
        when /y/i
        when /q/i
          exit
        else
          puts "Please enter Y to continue or Q to quit."
        end
      end

      def new_branch(branch)
        CommandLine.line_break
        `git checkout -b #{branch}`
      end

      def change_to_branch(branch)
        CommandLine.line_break
        puts "Changing to branch '#{branch}'"
        if branch_exist?(branch)
          `git checkout #{branch}`
        else
          print "Branch '#{branch}' does not exist. [C]reate or [Q]uit:  "
          case STDIN.gets.chomp
          when /c/i
            new_branch(branch)
          when /q/i
            exit
          end
        end
      end

      def diff(branch1, branch2)
        diff = `git diff --name-status #{branch1}..#{branch2}`
        return diff
      end


      def merge(to_branch, from_branch)
        CommandLine.line_break
        puts "Merging into #{to_branch} (after pulling updates)"
        Git.change_to_branch(to_branch)
        puts `git pull origin #{to_branch}`
        puts `git merge #{from_branch}`
        begin
          raise 'Merge failed' if $?.exitstatus != 0
        rescue
          puts $!.class.name + ": " + $!.message      # $! refers to the last error object
          puts "Please resolve the merge conflict and deploy again. Exiting..."
        end
      end

      def push(branch)
        CommandLine.line_break
        puts "Pushing your changes to branch '#{branch}'"
        puts `git push origin #{branch}`
      end


      def checkout(branch)
        puts `git checkout #{branch}`
      end

      def pull(branch)
        puts `git pull origin #{branch}`
      end

      def branch_exist?(branch)
        branches.find { |e| /#{branch}/ =~ e }
      end

      def new_issue(title, description)
        `ghi open -m "#{title}\n#{description}"`
      end

      def assign_issue_to_me(issue_number)
        `ghi assign #{issue_number}`
      end

      def branch_has_commits?(branch)
        log = `git log --branches --not --remotes --simplify-by-decoration --decorate --oneline`
        if log.include? branch
          return true
        else
          return false
        end
      end

      def issue(id)
        `ghi list #{id}`
      end
    end
  end
end
