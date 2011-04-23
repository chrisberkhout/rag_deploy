require 'rake'

import File.expand_path('../rag.rake', __FILE__) unless Rake::Task.task_defined?(:rag)

module RAG

  namespace :rag do

    desc "#{RAG_NAME}: Set up the destination server"
    task :setup => ['setup:ssh', 'setup:repo', 'setup:hook'] do
      puts "#{RAG_NAME}: Top level setup task for..."
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

        confirm_variable 'RAG_ACCOUNT', :name => "the destination account", :default => "user@host.com"
        ENV['RAG_USER'], ENV['RAG_HOST'] = ENV['RAG_ACCOUNT'].split('@')
        confirm_variable 'RAG_USER', :name => "the destination user"
        confirm_variable 'RAG_HOST', :name => "the destination host"
        confirm_variable 'RAG_HOME', :name => "the destination home", :default => "/home/#{ENV['RAG_USER']}/"
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
        puts "Task for setup of repo"
        # rm -Rf ~/repo
        # git init ~/repo
        # cd ~/repo && git config receive.denyCurrentBranch ignore && cd -
      end

      desc "#{RAG_NAME}: Set up the git hook on the destination server"
      task :hook => ['setup:variables', :repo] do
        host = "ubuntu.local"
        user = "scaffapp"
        hook = "hooks/post-receive.disabled"
        dest = "/home/scaffapp/repo/.git/hooks/post-receive"
        system "rsync --chmod=u+rwx,go+rx --perms #{hook} #{user}@#{host}:#{dest}"
      end

    end # namespace :setup
  
  end # namespace :rag
end # module RAG