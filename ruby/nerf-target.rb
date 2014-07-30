 #!/usr/bin/env ruby
 
require 'bundler'
require 'logger'
Bundler.require

# The seconds after an initial hit, for which we ignore subsequent hits
# (to avoid a barrage of hits skipping through several tracks quickly).
REARM_DELAY = 10  # seconds.

# Usage: ruby nerf-target.rb /dev/tty.usbserial-A6008k35
fail 'Call this program passing the USB/Serial device as an argument.' unless ARGV.first
 
port_str = ARGV.first
baud_rate = 9600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

logger = Logger.new STDOUT
logger.info "Trying #{port_str}..."

ignore_hits_until = Time.now.utc

SerialPort.open(port_str, baud_rate, data_bits, stop_bits, parity) do |sp|
  logger.info "Listening on #{port_str}."

  while true do
    while (cmd = sp.gets) do
      cmd.chomp!
      logger.debug "Received: #{cmd}"
      if cmd.start_with? 'NP'
        _, timestamp, force = cmd.split ',', 3
        logger.info "Hit at #{timestamp} with force #{force}."

        if Time.now > ignore_hits_until
          ignore_hits_until = Time.now.utc + REARM_DELAY
          # This skips Spotify on OSX
          # You could substitute your own commands/make a HTTP call/put a message on a queue, etc.
          `osascript -e 'tell application "Spotify" to next track'`
          logger.info "Skipping Spotify."
          logger.debug "Ignoring hits until #{ignore_hits_until.strftime '%T %Z'}."
        else
          logger.debug "Ignoring this hit."
        end
      end
    end
  end
end