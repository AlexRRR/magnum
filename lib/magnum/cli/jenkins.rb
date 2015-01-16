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
      generate_config

      f = File.read('config.xml')
      user = options.has_key?('ldap_user') ? options[:ldap_user] : ask("jenkins username:")
      pass = options.hast_key?('ldap_pass') ? options[:ldap_pass] : ask("jenkins pass:", :echo => false)
      job_name = self.project_url.split(/\//).last
      puts("https://jenkins.intra.local.ch/createItem?name=#{job_name}")
      jobs = RestClient::Resource.new("https://jenkins.intra.local.ch/createItem?name=puppet_#{job_name}",
      user,
      pass)
      jobs.post(f, {:content_type => 'application/xml'}){|response, request, result, &block|
        case response.code
        when 200
          puts("Successfuly created job!")
          response
        else
          puts("Could not create jenkins job!")
          response.return!(request, result, &block)
        end
      }
    end

    private
    def generate_config
      g = Git.open('./')
      origin_index = g.remotes.index{|b| b.name == 'origin'}
      origin = g.remotes[origin_index]
      self.git_url = origin.url
      self.project_url = git_url.split(/@/)[1].split(/\.git/)[0].sub(/:/,'/')
      puts("create #{git_url}  #{project_url}")
      template 'ci/config.xml.erb', target.join('config.xml')
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

    private
    def options
      original_options = super
      rcfile = File.expand_path('~/.magnumrc')
      return original_options unless File.exists?(rcfile)
      defaults = ::YAML::load_file(rcfile) || {}
      Thor::CoreExt::HashWithIndifferentAccess.new(defaults.merge(original_options))
    end


  end
end
