require 'irb/completion'
require 'rubygems'
require 'map_by_method'
require 'pp'
IRB.conf[:AUTO_INDENT]=true

require 'irb/ext/save-history'
IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"

require "wirble"
Wirble.init
Wirble.colorize