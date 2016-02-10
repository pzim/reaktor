require 'hipchat-api'
require 'logger'

module Notifiers
  class Hipchat
    include Singleton
    include Observable

    attr_accessor :notification

    def initialize
      @notification = nil
      @logger ||= Logger.new(STDOUT, Logger::INFO)
      env          = ENV.to_hash
      token        = env['REAKTOR_HIPCHAT_TOKEN']
      @room_id     = env['REAKTOR_HIPCHAT_ROOM']
      @from        = env['REAKTOR_HIPCHAT_FROM']
      hipchat_url  = env['REAKTOR_HIPCHAT_URL']
      @hipchat = if hipchat_url.nil? || hipchat_url.empty?
                   HipChat::API.new(token)
                 else
                   HipChat::API.new(token, hipchat_url)
                 end
      @logger.info("token = #{token}")
      # ensure room_id exists
      unless room_exist? @room_id
        @logger.info("The defined room_id: #{@room_id} does not exist.")
        @logger.info('Hipchat messages cannot be sent until a valid room is defined.')
      end
    end

    # The callback method for this observer
    def update(message)
      @logger.info("#{self}: #{message}")
      # Hipchat has message max length of 10K chars. If message size is
      # greater than 10K, need to get out the machete. Using last 5K
      # chars of message in this instance
      message = message.split(//).last(5000).join('') if message.length > 10_000
      @notification = message
      @hipchat.rooms_message(@room_id,
                             @from,
                             @notification,
                             notify = 0,
                             color = 'purple',
                             message_format = 'html')
    end

    def room_exist?(room_name)
      rooms = @hipchat.rooms_list
      if rooms['error'] && rooms['error']['code'] !~ /^2\d+/
        @logger.error "#{rooms['error']['code']} - #{rooms['error']['message']}"
        false
      end
      room = rooms['rooms'].select { |x| x['name'] == room_name }
      @logger.info("room = #{room}")
      room.empty? ? false : true
    end
  end
end
