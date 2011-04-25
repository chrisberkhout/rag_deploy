require 'rake'

import File.expand_path('../../rag.rake', __FILE__) unless Rake::Task.task_defined?(:rag)

unless Rake::Task.task_defined?('rag:history')
  module RAG
    namespace :rag do

      desc "#{RAG_NAME}: Show deployment history for a given git remote"
      task :history do
        account, path = `git remote show #{ENV['R']}`.match(/Push  URL: ssh:\/\/(.+?)(\/.+?)$/).to_a[1..2]

        unless account && path
          raise "Please specify the git remote to get history from. For example:\n     rake rag:history R=rag"
        end
        puts "-------------------------------------------------------------------------"
        puts "RAG deployments to '#{ENV['R']}' (#{account}#{path})"
        puts "-------------------------------------------------------------------------"
        puts `ssh #{account} "cd #{path}; git show-ref --tags"`.
          select{ |l| l =~ / refs\/tags\/deploy-[\d-]+$/ }.
          map{ |l| l.match(/^(\w+?) refs\/tags\/(deploy-[\d-]+)$/)[1..2] }.
          map{ |l| "#{l[1]}   SHA1: #{l[0]}" }.
          sort.
          join("\n")
      end
      
    end # namespace :rag
  end # module RAG
end # unless defined
