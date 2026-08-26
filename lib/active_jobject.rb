# frozen_string_literal: true

require 'json'
require 'net/http'

module ActiveJobject
  class Error < StandardError; end
end

require_relative 'active_jobject/version'

require_relative 'active_jobject/collection'
require_relative 'active_jobject/parser'

require_relative 'active_jobject/request'
require_relative 'active_jobject/request/engine/base'
require_relative 'active_jobject/request/engine/net_http'
require_relative 'active_jobject/request/engine/oauth2'
require_relative 'active_jobject/request/error'

require_relative 'active_jobject/base'
