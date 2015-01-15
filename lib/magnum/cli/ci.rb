require 'yaml'
module Magnum
  class Ci < Thor

    desc 'jenkins', 'Jenkins CI related tasks.'
    def jenkins()
      Magnum::Jenkins.new().invoke_all
    end

    # desc 'gitlab [MODULE_NAME]', 'Initializes an existing Puppet module.'
    # def init(module_name)
    #   Magnum::CreateGenerator.new([File.join(Dir.pwd, module_name), module_name], options).invoke_all
    # end

    def self.banner(task, namespace = false, subcommand = true)
      "#{basename} #{task.formatted_usage(self, namespace, subcommand).split(':').join(' ')}"
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
