require 'rake'

import File.expand_path('../rag.rake', __FILE__) unless Rake::Task.task_defined?(:rag)

module RAG

  def self.confirm_variable(variable, opts)
    if ENV[variable].nil?
      print "Please enter #{opts[:name]}#{opts[:default] && " [#{opts[:default]}]"}: "
      input = $stdin.gets.chomp
      ENV[variable] = input=="" ? opts[:default] : input
    end
    puts "#{opts[:name].capitalize} is: #{ENV[variable]}"
  end

  namespace :rag do

    desc "Top level setup task"
    task :setup do
      puts "#{RAG_NAME}: Top level setup task for}"
    end

    namespace :setup do

      task :details do
        confirm_variable 'RAG_ACCOUNT', :name => "the destination account", :default => "user@host.com"
        ENV['RAG_USER'], ENV['RAG_HOST'] = ENV['RAG_ACCOUNT'].split('@')
        confirm_variable 'RAG_USER', :name => "the destination user"
        confirm_variable 'RAG_HOST', :name => "the destination host"
        confirm_variable 'RAG_HOME', :name => "the destination home directory", :default => "/home/#{ENV['RAG_USER']}/"
      end
    
      desc "Destination setup: empty git repository"
      task :repo do
        puts "Task for setup of repo"
        # rm -Rf ~/repo
        # git init ~/repo
        # cd ~/repo && git config receive.denyCurrentBranch ignore && cd -
      end

      desc "Destination setup: passwordless authentication"
      task :ssh do
        unless system "ssh -o PasswordAuthentication=no scaffapp@ubuntu.local echo success"
          # set up password-less authentication
            remote_cmd = "mkdir -p  ~/.ssh &&
                          chmod 755 ~/.ssh &&
                          touch     ~/.ssh/authorized_keys &&
                          chmod 600 ~/.ssh/authorized_keys &&
                          echo \"#{public_key}\" >> ~/.ssh/authorized_keys"
            system "ssh -o PasswordAuthentication=no scaffapp@ubuntu.local #{remote_cmd}"
        end
      end

      desc "Destination setup: git hook"
      task :hook do
        host = "ubuntu.local"
        user = "scaffapp"
        hook = "hooks/post-receive.disabled"
        dest = "/home/scaffapp/repo/.git/hooks/post-receive"
        system "rsync --chmod=u+rwx,go+rx --perms #{hook} #{user}@#{host}:#{dest}"
      end

    end # namespace :setup
  
  end # namespace :rag
end # module RAG