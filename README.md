# RAG Deploy

_Really_ simple deployment with rake and git.

## Introduction

1. You want to deploy, so you push to the target server. 
2. It runs the `rake rag:deploy` task, which handles tagging, symlinks, gems, migration/rollback with a maintenance page, and restart.

## Status

In development. Working but in need of clean up.
No built in support for different config for each deployment target.

## Goals

* Simple and small.
* App deployment only, no other sysadmin.
* No magic: it's always clear what is being done.
* Can be triggered manually (on the target server command line) or automatically (via a git hook).
* Can coexist with other deployment systems (e.g. Capistrano).
* Can support multiple deployment targets and different configuration for each target.

## Assumptions

* You are using git.
* You are developing on and deploying to systems with `rsync` (e.g. Mac, Ubuntu).
* Your [vhost config](https://github.com/chrisberkhout/babushka-deps/blob/master/user/site.rb) will redirect all requests to a static `public/maintenance.html` page if one exists.
* If you are using gems you are using bundler.
* You want to deploy to a small number of individual servers.
* You use one account per app.

## Install and use

* Set up your server, including git and rake, and an account and vhost config for the app (e.g. with [Babushka](http://babushka.me/) or [Chef](http://wiki.opscode.com/display/chef/)).
* In your app, run:

        curl -L https://github.com/chrisberkhout/rag_deploy/tarball/master | \
        tar xzv --strip-components=1 --exclude README.md

* Commit.
* Review the RAG files, particularly for the `rag:deploy` task, and make any changes specific to your app or preferences. Commit again.
* Still on your development machine, set up the target server's ssh keys, git repo and git hook by running:

        rake rag:setup

* Add a git remote for the target server, as instructed by `rag:setup`, for example:

        git add remote rag ssh://yourapp@yourserver.com/home/yourapp/repo

* Deploy by pushing a new commit (empty if you want to redeploy without changes) to the target server, for example:

        git commit --allow-empty -m "No change this time, just want a new commit for deployment."
        git push rag master

## Feedback

Any feedback is welcome! The best way to reach me is via email at gmail.com (chrisberkhout@).
