require 'rake'

import File.expand_path('../rag/rag_setup.rake', __FILE__) unless Rake::Task.task_defined?('rag:setup')
import File.expand_path('../rag/rag_deploy.rake', __FILE__) unless Rake::Task.task_defined?('rag:deploy')
import File.expand_path('../rag/rag_history.rake', __FILE__) unless Rake::Task.task_defined?('rag:history')

module RAG
  
  RAG_NAME = "RAG Deploy"
  RAG_URL  = "http://github.com/chrisberkhout/rag_deploy"
  RAG_HOOK = "lib/tasks/rag/rag_post-receive.disabled"

  desc "#{RAG_NAME}: About #{RAG_NAME}"
  task :rag do
    puts "#{RAG_NAME}: Please visit #{RAG_URL} for more information."
  end
  
end
