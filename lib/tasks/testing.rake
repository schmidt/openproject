#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
#
# Copyright (C) 2012-2013 the OpenProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

if Rails.env.test?
  require 'coveralls/rake/task'
  Coveralls::RakeTask.new
end

namespace :test do
  desc 'Run unit and functional scm tests'
  task :scm do
    errors = %w(test:scm:units test:scm:functionals).collect do |task|
      begin
        Rake::Task[task].invoke
        nil
      rescue => e
        task
      end
    end.compact
    abort "Errors running #{errors.to_sentence(:locale => :en)}!" if errors.any?
  end

  namespace :scm do
    namespace :setup do
      desc "Creates directory for test repositories"
      task :create_dir do
        FileUtils.mkdir_p Rails.root + '/tmp/test'
      end

      supported_scms = [:subversion, :git, :filesystem]

      desc "Creates a test subversion repository"
      task :subversion => :create_dir do
        repo_path = "tmp/test/subversion_repository"
        system "svnadmin create #{repo_path}"
        system "gunzip < test/fixtures/repositories/subversion_repository.dump.gz | svnadmin load #{repo_path}"
      end

      (supported_scms - [:subversion]).each do |scm|
        desc "Creates a test #{scm} repository"
        task scm => :create_dir do
          # system "gunzip < test/fixtures/repositories/#{scm}_repository.tar.gz | tar -xv -C tmp/test"
          system "tar -xvz -C tmp/test -f test/fixtures/repositories/#{scm}_repository.tar.gz"
        end
      end

      desc "Creates all test repositories"
      task :all => supported_scms
    end

    desc "Updates installed test repositories"
    task :update do
      require 'fileutils'
      Dir.glob("tmp/test/*_repository").each do |dir|
        next unless File.basename(dir) =~ %r{^(.+)_repository$} && File.directory?(dir)
        scm = $1
        next unless fixture = Dir.glob("test/fixtures/repositories/#{scm}_repository.*").first
        next if File.stat(dir).ctime > File.stat(fixture).mtime

        FileUtils.rm_rf dir
        Rake::Task["test:scm:setup:#{scm}"].execute
      end
    end

    Rake::TestTask.new(:units => "db:test:prepare") do |t|
      t.libs << "test"
      t.verbose = true
      t.test_files = FileList['test/unit/repository*_test.rb'] + FileList['test/unit/lib/redmine/scm/**/*_test.rb']
    end
    Rake::Task['test:scm:units'].comment = "Run the scm unit tests"

    Rake::TestTask.new(:functionals => "db:test:prepare") do |t|
      t.libs << "test"
      t.verbose = true
      t.test_files = FileList['test/functional/repositories*_test.rb']
    end
    Rake::Task['test:scm:functionals'].comment = "Run the scm functional tests"
  end

  desc 'runs all tests'
  namespace :suite do
    task :run => [:cucumber, :spec, :test]
  end
end
