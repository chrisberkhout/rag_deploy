RAG Deploy

- goals:
  - can be triggered manually (command line) or automatically (via git hooks)
  - no magic (it's always clear what is being done)
  - rag_deploy setup can coexist with other deployment systems (capistrano, etc.)
  - multiple rag_deploy setups can coexist peacefully

- install:
  
  - set up your server
  - set up the account to deploy to
  
  - in your app repo dir:
    curl -L https://github.com/chrisberkhout/rag_deploy/tarball/master | tar xzv --strip-components=1 --exclude README.md
  - commit

  * set up the repo on the server
  * set up the git hook on the server
    rake -f lib/tasks/rag.rake rag:hook:setup

- other stuff:
  rake -f lib/tasks/rag.rake rag:deploy
