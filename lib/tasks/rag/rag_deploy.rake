require 'rake'

import File.expand_path('../../rag.rake', __FILE__) unless Rake::Task.task_defined?(:rag)
require 'fileutils'

unless Rake::Task.task_defined?('rag:deploy')
  module RAG
    namespace :rag do

      desc "#{RAG_NAME}: Deploy on this system"
      task :deploy => [
        'deploy:tag',
        'deploy:shared_dirs',
        'deploy:bundle_if_gemfile',
        'deploy:db_if_necessary',
        'deploy:release_and_restart',
        'deploy:delete_old_releases'
      ] do
        # do something
        puts "#{RAG_NAME}: Finished deploying #{`git tag | grep deploy-.* | sort | tail -1`.chomp}!"
      end
    
      namespace :deploy do
        
        desc "#{RAG_NAME}: This this version for deployment"
        task :tag do
          system "git tag deploy-`date -u +'%Y-%m-%d-%H%M%S'`"
          puts "The new deploy tag is: #{`git tag | grep deploy-.* | sort | tail -1`.chomp}"
        end
        
        desc "#{RAG_NAME}: Create shared directories"
        task :shared_dirs do
          FileUtils.mkdir_p      'public',                     :verbose => true
          Dir.chdir(File.expand_path('public')) do
            FileUtils.mkdir_p '../../shared/assets',           :verbose => true
            FileUtils.symlink '../../shared/assets', 'assets', :verbose => true, :force => true
          end
          FileUtils.mkdir_p      '../shared/log',              :verbose => true
          FileUtils.symlink      '../shared/log',    'log',    :verbose => true, :force => true
        end
        
        desc "#{RAG_NAME}: Run gem bundler if there is a Gemfile"
        task :bundle_if_gemfile do
          if File.exist?('Gemfile')
            FileUtils.mkdir_p       'vendor',                     :verbose => true
            Dir.chdir(File.expand_path('vendor')) do
              FileUtils.mkdir_p  '../../shared/bundle',           :verbose => true
              FileUtils.symlink  '../../shared/bundle', 'bundle', :verbose => true, :force => true
            end
            system "bundle install --deployment"
          end
        end

        desc "#{RAG_NAME}: Suspend the currently deployed application"
        task :app_suspend do
          Dir.chdir(File.expand_path("../current/public")) do
            if File.exist?('maintenance.disabled.html')
              FileUtils.symlink 'maintenance.disabled.html', 'maintenance.html', :verbose => true
              puts "Inserted maintenance page."
            end
          end
          # stop workers here
        end

        desc "#{RAG_NAME}: Setup, migrate or rollback the database if necessary"
        task :db_if_necessary => [ :bundle_if_gemfile ] do
          ENV['RACK_ENV'] = "production"
          new_migration = Dir.glob('db/migrate/*.rb').map{ |f| f[/\/(\d+)\w+\.rb/, 1] }.compact.sort.last
          if !new_migration.nil?
            current_migration = `rake db:version`[/Current version: (\d+)/, 1]
            if current_migration.to_i == 0
              `rake db:create db:schema:load db:seed`
            elsif new_migration != current_migration
              Rake::Task['rag:deploy:app_suspend'].invoke
              if new_migration > current_migration
                `rake db:migrate VERSION=#{new_migration}`
              elsif new_migration < current_migration
                Dir.chdir('../current') { `rake db:migrate VERSION=#{new_migration}` }
              end
            end
          end
        end

        desc "#{RAG_NAME}: Finalize the new release and restart the application"
        task :release_and_restart do
          system "mkdir -p tmp; touch tmp/restart.txt"
          system "RAG_TAG=`git tag | grep deploy-.* | sort | tail -1`; rsync -C -r --links -v --progress . ../$RAG_TAG/"
          system "RAG_TAG=`git tag | grep deploy-.* | sort | tail -1`; cd ..; rm current; ln -s $RAG_TAG current"
          # start/restart workers here
        end
        
        desc "#{RAG_NAME}: Delete old release directories"
        task :delete_old_releases do
          Dir.chdir('..') do
            to_delete = Dir.glob('deploy-*').sort[0..-(1+5)] # keep last 5 release dirs
            to_delete = to_delete - [File.exists?("current") && File.readlink("current")] # keep target of current
            to_delete.each do |d| 
              puts "Deleting directory #{d}"; system "rm -Rf #{d}" 
            end
          end
        end
        
      end # namespace :deploy

    end # namespace :rag
  end # module RAG
end # unless defined
