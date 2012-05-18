require 'rubygems'
require 'active_resource'

module RedmineApi
  class Client < ActiveResource::Base; end
  class Issue < RedmineApi::Client; end
  class Users < RedmineApi::Client; end
end

module Stagecoach
  class Redmine
    class << self

      def users
        RedmineApi::Users.find(:all, :params => {:nometa => 1})  
      end

      def issue(issue_number)
        return RedmineApi::Issue.find(issue_number)
      end

      def issue_url(issue)
        # originally this was:
        #
        # RedmineApi::Client.site + "/issues/" + issue.id
        #
        # but this caused URI merge errors on some setups.
        "#{RedmineApi::Client.site}issues/#{issue.id}"
      end

      # Open the issue in a browser.
      def view_issue(issue)
        issue_url = Redmine.issue_url(issue)
        print "Open issue in browser? [Y]es or anything else to exit:  "
        `open #{issue_url.to_s}` if gets.chomp == "Y"
        puts "Staging completed!  Exiting..."
      end
    end
  end
end
