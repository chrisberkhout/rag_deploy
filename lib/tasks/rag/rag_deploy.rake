require 'rake'

import File.expand_path('../../rag.rake', __FILE__) unless Rake::Task.task_defined?(:rag)

unless Rake::Task.task_defined?('rag:deploy')
  module RAG
    namespace :rag do

      desc "Deploy on this system"
      task :deploy do
        # do something
        puts "Hello RAG!"
      end
    
      namespace :deploy do
        # `git tag | grep deploy-.* | sort | tail -1 | head -1`
      
      
      end # namespace :deploy

    end # namespace :rag
  end # module RAG
end # unless defined
