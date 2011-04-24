require 'rake'

import File.expand_path('../../rag.rake', __FILE__) unless Rake::Task.task_defined?(:rag)
require 'fileutils'

unless Rake::Task.task_defined?('rag:deploy')
  module RAG
    namespace :rag do

      desc "Deploy on this system"
      task :deploy [
        'deploy:tag',
        'deploy:release_dir',
        'deploy:shared_dirs',
        'deploy:bundle_if_gemfile',
        'deploy:db_if_necessary',
        'deploy:symlink_and_restart'
      ] do
        # do something
        puts "#{RAG_NAME}: Finished deploying #{ENV['RAG_DEPLOY_TAG']}!"
      end
    
      namespace :deploy do
        
        task :tag do
          if ENV['RAG_DEPLOY_TAG'].nil?
            ENV['RAG_LAST_DEPLOY_TAG'] = `git tag | grep deploy-.* | sort | tail -1 | head -1`.chomp
            puts ENV['RAG_LAST_DEPLOY_TAG'] == "" ? 
              "This is the first deployment!" :
              "Previous deploy tag: #{ENV['RAG_LAST_DEPLOY_TAG']}"
            ENV['RAG_DEPLOY_TAG'] = `echo deploy-\`date -u +"%Y-%m-%d-%H%M%S"\``
            `git tag #{ENV['RAG_DEPLOY_TAG']}`
            puts "The new deploy tag is: #{ENV['RAG_DEPLOY_TAG']}"
          end
        end
        
        task :release_dir do
          `rsync -C -r -v --progress . ../#{ENV['RAG_DEPLOY_TAG']}/`
        end

        task :shared_dirs do
          Dir.chdir('../#{ENV['RAG_DEPLOY_TAG']}') do
            FileUtils.mkdir_p      'public',                     :verbose => true
            Dir.chdir('public') do
              FileUtils.mkdir_p '../../shared/assets',           :verbose => true
              FileUtils.symlink '../../shared/assets', 'assets', :verbose => true, :force => true
            end
            FileUtils.mkdir_p      '../shared/log',              :verbose => true
            FileUtils.symlink      '../shared/log',    'log',    :verbose => true, :force => true
          end
        end
        
        task :bundle_if_gemfile do
          Dir.chdir('../#{ENV['RAG_DEPLOY_TAG']}') do
            if File.exist?('Gemfile')
              FileUtils.mkdir_p       'vendor',                     :verbose => true
              Dir.chdir('vendor') do
                FileUtils.mkdir_p  '../../shared/bundle',           :verbose => true
                FileUtils.symlink  '../../shared/bundle', 'bundle', :verbose => true, :force => true
              end
              system "bundle install --deployment"
            end
          end
        end

        task :app_suspend do
          if File.exist?('../current/public/maintenance.disabled.html')
            FileUtils.mv '../current/public/maintenance.disabled.html', '../current/public/maintenance.html'
            puts "Inserted maintenance page."
          end
          # stop workers here
        end

        task :db_if_necessary do
          ENV['RACK_ENV'] = "production"
          new_migration = Dir.glob('db/migrate/*.rb').map{ |f| f[/\/(\d+)\w+\.rb/, 1] }.compact.sort.last
          if !new_migration.nil?
            current_migration = `rake db:version`[/Current version: (\d+)/, 1]
            if current_migration.to_i == 0
              `rake db:create db:schema:load db:seed db:migrate`
            elsif new_migration != current_migration
              Rake::Task[:app_suspend].invoke
              if new_migration > current_migration
                `rake db:migrate VERSION=#{new_migration}`
              elsif new_migration < current_migration
                Dir.chdir('../current') { `rake db:migrate VERSION=#{new_migration}` }
              end
            end
          end
        end
        
        task :symlink_and_restart do
          FileUtils.mkdir_p 'tmp'
          FileUtils.touch 'tmp/restart.txt'
          Dir.chdir('..') do
            FileUtils.symlink 'current', ENV['RAG_DEPLOY_TAG'], :verbose => true, :force => true
          end
          # start/restart workers here
        end

      end # namespace :deploy

    end # namespace :rag
  end # module RAG
end # unless defined
