require 'thor'
require 'pathname'

module Magnum
  autoload :BaseGenerator,      'magnum/generators/base_generator'
  autoload :CreateGenerator,    'magnum/generators/create_generator'
  autoload :Cli,                'magnum/cli'
  autoload :Module,             'magnum/cli/module'
  autoload :Ci,                 'magnum/cli/ci'
  autoload :Jenkins,            'magnum/cli/jenkins'

  def self.root
    @root ||= Pathname.new(File.expand_path('../', File.dirname(__FILE__)))
  end
end
