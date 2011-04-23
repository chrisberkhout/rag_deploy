require 'rake'

import File.expand_path('../rag_setup.rake', __FILE__) unless Rake::Task.task_defined?('rag:setup')
import File.expand_path('../rag_deploy.rake', __FILE__) unless Rake::Task.task_defined?('rag:deploy')

RAG_NAME = "RAG Deploy"
RAG_URL  = "http://github.com/chrisberkhout/rag_deploy"

desc "RAG Deploy"
task :rag do
  puts "#{RAG_NAME}: Please visit #{RAG_URL} for more information."
end
