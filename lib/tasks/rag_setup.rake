# RAG Deploy: http://github.com/chrisberkhout/rag_deploy

require 'rake'

module RAG
  extend Rake::DSL if defined? Rake::DSL

  RAG_NAME = "RAG Deploy"
  RAG_HOOK = "lib/tasks/rag_post-receive.disabled"

  namespace :rag do

    desc "#{RAG_NAME}: Set up the destination server"
    task :setup => ['setup:ssh', 'setup:repo', 'setup:hook'] do
      puts "#{RAG_NAME} destination server setup is complete! :D"
    end

    namespace :setup do

      # Set up environment variables used by rag:setup:*
      task :variables do
        def self.confirm_variable(variable, opts)
          if ENV[variable].nil?
            print "Please enter #{opts[:name]}#{opts[:default] && " [#{opts[:default]}]"}: "
            input = $stdin.gets.chomp
            ENV[variable] = input=="" ? opts[:default] : input
          end
          puts "#{opts[:name].capitalize} is: #{ENV[variable]}"
        end

        confirm_variable 'RAG_ACCOUNT', :name => "the destination account", :default => "user@hostname.com"
        ENV['RAG_USER'], ENV['RAG_HOST'] = ENV['RAG_ACCOUNT'].split('@')
        confirm_variable 'RAG_USER', :name => "the destination user"
        confirm_variable 'RAG_HOST', :name => "the destination host"
        confirm_variable 'RAG_HOME', :name => "the destination home", :default => "/home/#{ENV['RAG_USER']}"
        ENV['RAG_REPO'] = "#{ENV['RAG_HOME']}/repo".gsub(/\/+/,'/')
        confirm_variable 'RAG_REPO', :name => "the destination repository"
      end
  
      desc "#{RAG_NAME}: Set up passwordless authentication on the destination server"
      task :ssh => ['setup:variables'] do
        print "Checking passwordless authentication for #{ENV['RAG_ACCOUNT']}... "
        if system "ssh -q -o PasswordAuthentication=no #{ENV['RAG_ACCOUNT']} echo success > /dev/null"
          puts "working!"
        else
          puts "not yet set up."
          puts "Attempting to set up passwordless authentication for #{ENV['RAG_ACCOUNT']}...\n"
          PUBLIC_KEY_FILE = "~/.ssh/id_rsa.pub"
          key = `cat #{PUBLIC_KEY_FILE}`.chomp
          formatted_key = key.scan(/.{1,70}/).to_a.map{ |l| "     #{l}\n" }.join('')
          print "\nYour #{PUBLIC_KEY_FILE} file " + (key.empty? ? "is empty. Please create one.\n" : "contains:\n#{formatted_key}\n")
          print "Please enter your public key"
          print key.empty? ? ": " : " or press enter to use your #{PUBLIC_KEY_FILE}: "
          key = (input = $stdin.gets.chomp)=="" ? key : input
          remote_command = 
            "mkdir -p  ~/.ssh &&
             chmod 755 ~/.ssh &&
             touch     ~/.ssh/authorized_keys &&
             chmod 600 ~/.ssh/authorized_keys &&
             echo \"#{key}\" >> ~/.ssh/authorized_keys"
          system "ssh", "-o PubkeyAuthentication=no", ENV['RAG_ACCOUNT'], remote_command
          if system "ssh -o PasswordAuthentication=no #{ENV['RAG_ACCOUNT']} echo success > /dev/null"
            puts "Successfully set up passwordless authentication for #{ENV['RAG_ACCOUNT']}."
          else
            puts "ERROR: Could not set up passwordless authentication for #{ENV['RAG_ACCOUNT']}!"
          end
        end
      end

      desc "#{RAG_NAME}: Set up an empty git repository on the destination server"
      task :repo => ['setup:variables'] do
        puts "Setting up an empty git repository on the destination server..."
        if system "ssh #{ENV['RAG_ACCOUNT']} [ -e #{ENV['RAG_REPO']} ]"
          puts "The directory #{ENV['RAG_ACCOUNT'] + ENV['RAG_REPO']} already exists!"
          print "IT WILL BE DELETED and freshly initialized IF YOU PRESS ENTER! "
          $stdin.gets
          puts "Roger that, proceeding..."
        end
        remote_command = 
          "rm -Rf #{ENV['RAG_REPO']} && 
           git init -q #{ENV['RAG_REPO']} &&
           cd #{ENV['RAG_REPO']} &&
           git config receive.denyCurrentBranch ignore"
        system "ssh", ENV['RAG_ACCOUNT'], remote_command
        puts "Initialised the destination server repository. Add it as a remote by running:"
        puts "\n     git remote add rag ssh://#{ENV['RAG_ACCOUNT'] + ENV['RAG_REPO']}\n\n"
      end

      desc "#{RAG_NAME}: Set up the git hook on the destination server"
      task :hook => ['setup:variables'] do
        hook = <<-END.gsub(/^ */, '')
          #!/bin/bash 
          ########### rag_deploy post-receive hook ###########
          
          # Get the details of the first received ref (others are ignored)
          read oldrev newrev refname &&
          echo "rag_deploy: received ${oldrev:0:6}..${newrev:0:6} ($refname)" &&
          
          # Change to the working directory and unset GIT_DIR so we can work on it
          cd .. && unset GIT_DIR &&
          
          # Make sure the working directory does not contain changes
          git clean -x -d --force --quiet &&
          
          # Check out the new version
          git checkout -q --force $newrev && git submodule update --init --recursive &&
          
          # Clear any files that should not be around anymore
          git clean -x -d --force --quiet &&
          
          # Deploy it!
          echo "rag_deploy: running rake rag:deploy..." &&
          echo "" &&
          rake -f lib/tasks/rag_deploy.rake rag:deploy
        END
        remote_command = <<-END.gsub(/^ */, '')
          echo '#{hook}' > #{ENV['RAG_REPO']}/.git/hooks/post-receive &&
          chmod 755 #{ENV['RAG_REPO']}/.git/hooks/post-receive
        END
        print "Setting up post-receive git hook (any existing post-receive will be overwritten)... "
        system "ssh", ENV['RAG_ACCOUNT'], remote_command
        puts "done!"
      end

    end # namespace :setup

  end # namespace :rag
  
end # module RAG
