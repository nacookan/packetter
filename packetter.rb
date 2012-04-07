#!/usr/bin/ruby -Ku

require 'rubygems'
require 'mechanize'
require 'nkf'
require 'oauth'
require 'twitter'

load File.join(File.dirname(__FILE__), 'config.rb')

# logger
#require 'logger'
#Mechanize.log = Logger.new('packetter.txt')
#Mechanize.log.level = Logger::DEBUG

# setup
puts 'setup...'
agent = Mechanize.new
agent.follow_meta_refresh = true
agent.user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.142 Safari/535.19'

# login
puts 'login...'
agent.get('https://my.softbank.jp/msb/d/top')
agent.page.forms.first.field_with(:name => 'msn').value = $my_softbank[:user_id]
agent.page.forms.first.field_with(:name => 'password').value = $my_softbank[:password]
agent.page.forms.first.click_button

# jumo to mainmenu
puts 'jump to bill before fixed...'
agent.get('https://my.softbank.jp/msb/d/webLink/doSend/WCO010000')
agent.page.forms.first.click_button
agent.get('https://bl11.my.softbank.jp/wco/billBeforeFixed/WCO020')

# fee
fee = 0
tds = agent.page.root.search('td')
tds.each do |td|
  l = td.search('span.flt_l').inner_text
  r = td.search('span.flt_r').inner_text
  if l =~ /ＰＣダイレクト/
    fee = r
    break
  end
end
puts "packet fee : #{fee}"

# date
date = agent.page.root.search('span.fw_n').inner_text.gsub(/^.*?（(.+?)ご利用分）.*$/m, '\1')
puts "date : #{date}"

# latest file
latest_file = File.join(File.dirname(__FILE__), 'latest')

# load latest and compare
if File.exist?(latest_file)
  puts 'load latest...'
  f = open(latest_file)
  latest = f.read.chomp
  f.close

  # compare
  fee_new = fee.delete(',').to_i
  fee_old = latest.delete(',').to_i
  fee_diff = fee_new - fee_old
  if fee_diff < 0
    diff = ''
  else
    diff = " (+#{fee_diff.to_s.gsub(/(.*\d)(\d\d\d)/, '\1,\2')}円)"
  end
  puts "diff : #{diff}"
end

# save latest
f = File.open(latest_file, 'w')
f.puts fee
f.close

# post
puts 'post...'
Twitter.configure do |config|
  config.consumer_key = $twitter[:consumer_key];
  config.consumer_secret = $twitter[:consumer_secret];
  config.oauth_token = $twitter[:access_token];
  config.oauth_token_secret = $twitter[:access_token_secret];
end

client = Twitter::Client.new
client.update("#{date}のSoftBankパケット通信料 : #{fee}#{diff}")
puts("#{date}のSoftBankパケット通信料 : #{fee}#{diff}")

puts 'finished.'
