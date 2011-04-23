require 'rake'

import File.expand_path('../rag.rake', __FILE__) unless Rake::Task.task_defined?(:rag)

module RAG

  class Dest
    class <<self
      attr :account, true
      attr :username, true
      attr :hostname, true
    end
  end

  namespace :rag do

    desc "Top level setup task"
    task :setup do
      Dest.account = "scaffapp@ubuntu.local"
      puts "#{RAG_NAME}: Top level setup task for #{Dest.account}"
    end

    namespace :setup do

      task :details do
        RAG::account = "scaffapp@ubuntu.local"
        RAG::username, RAG::hostname = RAG::account.split('@')[0..1]
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