# RAG Deploy

_Really_ simple deployment with rake and git.

## Introduction

You want to deploy, so...

1. You push to the target server. 
2. It receives the push and runs the `rake rag:deploy` task, which handles tagging, symlinks, gems, migration/rollback with a maintenance page, and restart.

That's it! It's small and simple. It does application deployment and no other system administration. It's clear exactly what is happening and where, and it's easy to modify or extend its behavior. You can trigger it manually (on the server) or automatically (via its git hook).

## Status

Unmaintined.

The idea of git triggering a server-side job to deploy is good. Here I've done it with rake, but using [Babushka](http://babushka.me/) in its place would allow for better separation of generic tasks from application specific tasks.

I've used this a bit, but the code is not pretty. I'm keeping it for reference rather than use.

## Install and use

First, set up your server, including git and rake, and an account and vhost config for the application. You might like to use [Babushka](http://babushka.me/) or [Chef](http://wiki.opscode.com/display/chef/).

Then, on your development machine, in the source directory of your app, run:

    curl -L https://github.com/chrisberkhout/rag_deploy/tarball/master | \
    tar xzv --strip-components=1 --exclude README.md

Set up the target server's ssh keys, git repo and git hook by running:

    rake rag:setup

As instructed by `rag:setup`, add a git remote for the target server, for example:

    git add remote rag ssh://yourapp@yourserver.com/home/yourapp/repo

Commit. Review the RAG files, particularly `rag_deploy.rake`, and make any changes specific to your application or preferences. Commit again.

Deploy by pushing a new commit to the target server. It can be an empty commit if you want to redeploy without changes. For example:

    git commit --allow-empty -m "No change this time, just a new commit for deployment."
    git push rag master

## Assumptions

RAG Deploy assumes you are using git for version control and bundler for managing any gems. It also assumes that you are deploying to a small number of unix-based systems, with `rsync` (e.g. Mac, Ubuntu), and a separate account for each of your applications. Your [vhost config](https://github.com/chrisberkhout/babushka-deps/blob/master/user/site.rb) should redirect all requests to a static `public/maintenance.html` page if one exists.

The automatic database migration and rollback assumes your app is on Rails, using ActiveRecord.

## Other git-based deployment setups

You may be interested in:

* [Deploying Websites With a Tiny Git Hook](http://ryanflorence.com/deploying-websites-with-a-tiny-git-hook/)
* [GitHub-esque deployment using Capistrano and Git](https://github.com/rubypond/git-based-deploy)

## Feedback

Any feedback is welcome! The best way to reach me is via email at gmail.com (chrisberkhout@).

## Copyright

The MIT License

Copyright (C) 2011 by Chris Berkhout (http://chrisberkhout.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
