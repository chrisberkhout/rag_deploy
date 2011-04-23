require 'rake'

import File.expand_path('../../rag.rake', __FILE__) unless Rake::Task.task_defined?(:rag)

module RAG
  namespace :rag do

    desc "Deploy on this system"
    task :deploy do
      # do something
      puts "Hello RAG!"
    end

  end # namespace :rag
end # module RAG