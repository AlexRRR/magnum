require 'yaml'
require 'git'
require 'rest_client'
module Magnum
  class Jenkins < Thor

    include Thor::Actions
    include Thor::Shell

    attr_accessor :project_url
    attr_accessor :git_url

    desc 'create', 'Create jenkins CI job for this module'
    def create()
      begin
        g = Git.open('./')
      rescue ArgumentError
        puts('There is no .git repo here!!')
        abort
      end
      origin_index = g.remotes.index{|b| b.name == 'origin'}
      origin = g.remotes[origin_index]
      self.git_url = origin.url
      self.project_url = git_url.split(/@/)[1].split(/\.git/)[0].sub(/:/,'/')
      puts("create #{git_url}  #{project_url}")
      template 'ci/config.xml.erb', target.join('config.xml')
      f = File.read('config.xml')
      user = ask("jenkins username:")
      pass = ask("jenkins pass:")
      job_name = self.project_url.split(/\//).last
      puts("https://jenkins.intra.local.ch/createItem?name=#{job_name}")
      jobs = RestClient::Resource.new("https://jenkins.intra.local.ch/createItem?name=#{job_name}",
                                   user,
                                   pass)
      jobs.post(f, {:content_type => 'application/xml'})
    end

    def self.banner(task, namespace = false, subcommand = true)
      "#{basename} #{task.formatted_usage(self, namespace, subcommand).split(':').join(' ')}"
    end

    private
    def target
      @target ||= Pathname.new(File.expand_path(File.join(Dir.pwd)))
    end

    def self.source_root
      Magnum.root.join('generator_files')
    end

    # private
    # def options
    #   original_options = super
    #   rcfile = File.expand_path('~/.magnumrc')
    #   return original_options unless File.exists?(rcfile)
    #   defaults = ::YAML::load_file(rcfile) || {}
    #   Thor::CoreExt::HashWithIndifferentAccess.new(defaults.merge(original_options))
    # end
  end
end
