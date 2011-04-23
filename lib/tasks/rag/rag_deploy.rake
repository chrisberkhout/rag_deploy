require 'rake'

import File.expand_path('../../rag.rake', __FILE__) unless Rake::Task.task_defined?(:rag)

unless Rake::Task.task_defined?('rag:deploy')
  module RAG
    namespace :rag do

      desc "Deploy on this system"
      task :deploy [
        'deploy:tag',
        'deploy:release_dir',
        'deploy:shared_dirs',
        'deploy:bundle',
        'deploy:migrate_or_rollback',
        'deploy:symlink',
        'deploy:app_restart'
      ] do
        # do something
        puts "Hello RAG!"
      end
    
      namespace :deploy do
        
        task :tag do
          # `git tag | grep deploy-.* | sort | tail -1 | head -1`
        end
        
        task :release_dir do
        end

        task :shared_dirs do
        end
        
        task :bundle do
        end

        task :migrate_or_rollback do
          # invoke :app_suspend
          
          # if necessary, do `RAILS_ENV=production bundle exec rake db:create db:schema:load db:seed`
          
          # check rails 3 rake tasks.
        end
        
        task :symlink do
        end

        task :app_restart do
          # restart
          # then, invoke :app_resume
        end


        # maybe move these to different files...
        task :app_suspend do
          # insert holding page (in ~/current), stop wokers
        end

        task :app_resume do
          # remove holding page (or not, 'cos it's in ~/current), start wokers
        end

      end # namespace :deploy

    end # namespace :rag
  end # module RAG
end # unless defined
