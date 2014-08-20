# encoding: utf-8
#require 'capybara' 
#require 'capybara/dsl'
#require 'devil' 
require 'net/http'
require 'net/http/post/multipart'


#include Capybara::DSL

module AntigateApi
  class Client
    attr_reader :key
    attr_accessor :options

    DEFAULT_CONFIGS = {
      recognition_time: 5, # First waiting time
      sleep_time: 1, # Sleep time for every check interval
      timeout: 60, # Max time out for decoding captcha
      debug: false # Verborse or not
    }

    def initialize(key, opts={})
      @key = key
      @options = DEFAULT_CONFIGS.merge(opts)
    end

    def send_captcha( captcha_file )
      uri = URI.parse( 'http://antigate.com/in.php' )
      file = File.new( captcha_file, 'rb' )
      req = Net::HTTP::Post::Multipart.new( uri.path,
                                           :method => 'post',
                                           :key => @key,
                                           :file => UploadIO.new( file, 'image/jpeg', 'image.jpg' ),
                                           :numeric => 0 )
      http = Net::HTTP.new( uri.host, uri.port )
      begin
        resp = http.request( req )
      rescue => err
        puts err
        return nil
      end

      id = resp.body
      id[ 3..id.size ]
    end

    def get_captcha_text( id )
      data = { :key => @key,
               :action => 'get',
               :id => id,
               :min_len => 5,
               :max_len => 5 }
      uri = URI.parse('http://antigate.com/res.php' )
      req = Net::HTTP::Post.new( uri.path )
      http = Net::HTTP.new( uri.host, uri.port )
      req.set_form_data( data )

      begin
        resp = http.request(req)
      rescue => err
        puts err
        return nil
      end

      text = resp.body
      if text != "CAPCHA_NOT_READY"
        return text[ 3..text.size ]
      end
      nil
    end

    def report_bad( id )
      data = { :key => @key,
               :action => 'reportbad',
               :id => id }
      uri = URI.parse('http://antigate.com/res.php' )
      req = Net::HTTP::Post.new( uri.path )
      http = Net::HTTP.new( uri.host, uri.port )
      req.set_form_data( data )

      begin
        resp = http.request(req)
      rescue => err
        puts err
      end
    end

    def decode(captcha_file)
      captcha_id = self.send_captcha(captcha_file)
      if ["OR_NO_SLOT_AVAILABLE"].include? captcha_id
        raise AntigateApi::Errors::Error("captcha_id: #{captcha_id}")
      end
      start_time = Time.now.to_i
      sleep @options[:recognition_time]

      code = nil
      while code == nil do
        code = self.get_captcha_text( captcha_id )
        duration = Time.now.to_i - start_time
        puts "Spent time: #{duration}" if @options[:debug]
        sleep @options[:sleep_time]
        raise AntigateApi::Errors::TimeoutError.new if duration > @options[:timeout]
      end

      [captcha_id, code]
    end
  end
end


#Capybara.current_driver = :selenium
#Capybara.visit('http://profile.tut.by/')
  
#Capybara.save_screenshot('screen.png')

#Devil.with_image("screen.png") do |img|
#     img.crop(245, 322, 180, 64)
#     img.save("screen.jpg")

#     end

#ANTIGATE_KEY = 'fe229a552048e435b3fce8339b3c2fc2'
	
ANTIGATE_KEY = '19ae2f4e7fd67c047d60de2337cc82b4'

#captcha = "./screen.jpg"
recognition_time = 10



options = {
  recognition_time: 5, # First waiting time
  sleep_time: 1, # Sleep time for every check interval
  timeout: 60, # Max time out for decoding captcha
  debug: false # Verborse or not
}

def sendImage 
#      Capybara.save_screenshot('screen.png')
#      Devil.with_image("screen.png") do |img|
#     img.crop(245, 322, 180, 64)
#     img.save("screen.jpg")

#     end#do
         recognition_time = 10

#key = 'fe229a552048e435b3fce8339b3c2fc2'
options = {
  recognition_time: 5, # First waiting time
  sleep_time: 1, # Sleep time for every check interval
  timeout: 60, # Max time out for decoding captcha
  debug: false # Verborse or not
}
client = AntigateApi::Client.new(ANTIGATE_KEY, options)
captcha_id, captcha_answer = client.decode("screen.jpg")
#puts captcha_answer
return captcha_answer


    #ANTIGATE_KEY = 'fe229a552048e435b3fce8339b3c2fc2'

    #captcha = "./screen.jpg"



  
  


  end
 puts sendImage
#client = AntigateApi::Client.new(ANTIGATE_KEY, options)
#captcha_id, captcha_answer = client.decode("screen.jpg")
#puts captcha_id + " " + captcha_answer

#recognize capcha
#id = send_captcha( key, captcha )
#sleep( recognition_time )
#code = nil
#while code == nil do
#  code = get_captcha_text( key, id )
#  sleep 1
#end#while
#return  code

#  end



