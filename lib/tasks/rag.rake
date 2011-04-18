namespace :rag do

  namespace :hook do
    desc "Install the git hook on a destination system"
    task :setup do
      host = "ubuntu.local"
      user = "scaffapp"
      hook = "hooks/post-receive.disabled"
      dest = "/home/scaffapp/repo/.git/hooks/post-receive"

      # system "ssh #{user}@#{host} mkdir -p #{repo}/.git/hooks"
      # system "ssh  mv #{repo}/.git/hooks/post-receive #{repo}/.git/hooks/post-receive.old"
      
      system "rsync --chmod=u+rwx,go+rx --perms #{hook} #{user}@#{host}:#{dest}"
    end
  end
  


  desc "Deploy your app with RAG"
  task :deploy do
    # do something
    puts "Hello RAG!"
  end
end