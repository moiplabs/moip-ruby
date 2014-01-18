# encoding: utf-8
require "rubygems"
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/deprecation'
require 'singleton'
require 'forwardable'

module MoIP

  class ValidationError < StandardError; end

  class MissingPaymentTypeError < ValidationError; end
  class MissingPayerError < ValidationError; end
  class MissingBirthdate < ValidationError; end

  class InvalidCellphone < ValidationError; end
  class InvalidExpiry < ValidationError; end
  class InvalidInstitution < ValidationError; end    
  class InvalidPhone < ValidationError; end
  class InvalidReceiving < ValidationError; end
  class InvalidValue < ValidationError; end

  autoload :DirectPayment, 'moip/direct_payment'
  autoload :Client,        'moip/client'
  autoload :Config,        'moip/config'

  def self.config
    Thread.current[:moip_config] ||= MoIP::Config.new
  end

  def self.setup
    yield config if block_given?
  end

  STATUS = {1 => "authorized", 2 => "started", 3 => "printed", 4 => "completed", 5 => "canceled", 6 => "analysing"}

  class << self
    extend Forwardable
    def_delegators :config, :uri, :token, :key

    def checkout(attributes = {})
      ActiveSupport::Deprecation.warn("MoIP.checkout has been deprecated. Use MoIP::Client.checkout instead", caller)
      MoIP::Client.checkout(attributes)
    end

    def query(token)
      ActiveSupport::Deprecation.warn("MoIP.query has been deprecated. Use MoIP::Client.query instead", caller)
      MoIP::Client.query(token)
    end

    def moip_page(token)
      ActiveSupport::Deprecation.warn("MoIP.moip_page has been deprecated. use MoIP::Client.moip_page instead", caller)
      MoIP::Client.moip_page(token)
    end

    def notification(params)
      ActiveSupport::Deprecation.warn("MoIP.notification has been deprecated. use MoIP::Client.notification instead", caller)
      MoIP::Client.moip_page(token)
    end
  end
end
