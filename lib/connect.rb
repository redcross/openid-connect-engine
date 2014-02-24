require 'connect/engine'
require 'rack/oauth2'
require 'openid_connect'
require 'constant_cache'

module Connect
  mattr_accessor :account_class, :session_class

  def self.account_class_name
    @@account_class
  end
  def self.account_class
    @@account_class.constantize
  end

  def self.session_class
    @@session_class.constantize
  end

  def self.table_name_prefix
    'connect_'
  end

  module Config
    def self.configure &block
      self.instance_exec &block
    end

    def self.block_config name
      define_singleton_method name do |&block|
        if block
          class_variable_set "@@#{name}", block
        else
          class_variable_get "@@#{name}"
        end
      end
    end

    block_config :begin_login
    block_config :current_user
    block_config :force_logout

    mattr_accessor :jwt_issuer, :private_key, :private_key_password, :certificate

    mattr_accessor :account_last_login, :account_attributes
  end

  ActiveSupport.run_load_hooks :connect, self
end