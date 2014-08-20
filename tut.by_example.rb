   # encoding: utf-8
require 'capybara' 
require 'capybara/dsl' 
require 'devil'
require 'net/http'
require 'net/http/post/multipart'

include Capybara::DSL

Capybara.current_driver = :selenium
module MyModule

  class Registrator

  def login(login)
      @login = login
    end

    def rules_agree
    Capybara.visit('http://profile.tut.by/')
    end

    def form_filling

      Capybara.click_on('Зарегистрироваться')
      Capybara.fill_in('FirstName', :with => 'spring')
      Capybara.fill_in('SecondName', :with => 'Balashkovs')
      Capybara.fill_in('Username', :with => @login)
      Capybara.fill_in('Password1', :with => '123456qwerty')
      Capybara.fill_in('Password2', :with => '123456qwerty')
      Capybara.find(:xpath, '//*[@id="_3_1"]/option[5]').select_option
      Capybara.find(:xpath, '//*[@id="_3_2"]/option[5]').select_option
      Capybara.find(:xpath, '//*[@id="_3_3"]/option[45]').select_option
      Capybara.find(:xpath, '//*[@id="msex"]').click
      Capybara.fill_in('city_div0', :with => 'минск')
      Capybara.click_on('Минск (Минск и Минская область, Беларусь)')  
      Capybara.fill_in('Answer', :with => '241' )
      Capybara.fill_in('ForgotPasswordPhone', :with => '+375252525252')
      capcha = getCapcha
      Capybara.click_on('Зарегистрироваться')
      Capybara.fill_in('ap_word', :with => capcha.encode('UTF-8') )
      sleep 10
      Capybara.click_on('Зарегистрироваться')
      
                
    end

    def nick_generate
      Capybara.visit('http://nick-name.ru/generate/')
      Capybara.click_on('Генерировать')
      return Capybara.find_field('resname').value
    end

  def capchaPut
    puts 'enter the captcha'
    capcha = gets.chomp
    return capcha
  end 

  def getCapcha 
      Capybara.save_screenshot('screen.png')
      Devil.with_image("screen.png") do |img|
     img.crop(245, 322, 180, 64)
     img.save("screen.jpg")
     end#do
     captcha_answer = ""
     while (1 > captcha_answer.length)
     puts 'send captcha'
     captcha_answer = %x'ruby captcha.rb'
     end
     return captcha_answer


    end


  end
end

t = MyModule::Registrator.new
logins = []

puts 'Enter a number of registration users'
numberOfUsers = gets.chomp

i=0
while i < numberOfUsers.to_i
  login =t.nick_generate + 'unique'
  t.login(login)
  t.rules_agree
  t.form_filling
  logins = logins + [login + ' ' ]
  i+=1
end
puts logins