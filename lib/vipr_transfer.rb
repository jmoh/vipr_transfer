require 'rubygems'
require 'bundler'
require 'date'
require 'fileutils'

Bundler.setup(:default)

require 'vipr_transfer/transferrer'

# Small Library for managing remote and local queues for VIPR Images
module ViprTransfer; end
