#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'mechanize'
require 'tweetstream'
require 'open-uri'
require 'logger'
require 'uri'
require 'net/https'
require 'data_mapper'

DataMapper.setup(:default, 'sqlite3:db/oneplus.db')

class Users
  include DataMapper::Resource

  property :id, Serial
  property :email, String
  property :password, String
  property :invite, Boolean, :default  => false
  property :sell, Boolean, :default  => false
  property :data_end, DateTime
  property :textpublish, Text
  property :textsell, Text
end

DataMapper.finalize

@us = Users.first(:invite => false, :order => [ :id.asc ])

@user = @us.email
@pass = @us.password

TweetStream.configure do |config|
  config.consumer_key       = ''
  config.consumer_secret    = ''
  config.oauth_token        = ''
  config.oauth_token_secret = ''
  config.auth_method        = :oauth
end

@a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Windows Chrome'
}

@a.log = Logger.new 'mechanize.log'

@count = 0

@a.get('https://account.oneplus.net/login') do |app|
  app.form_with(:action => 'https://account.oneplus.net/login') do |f|
    f.email      = @user
    f.password   = @pass
  end.click_button
end

puts @a.page.body.inspect

def getinvite(url)
  @a.get(url) do |m|
    if (m.uri.to_s.match(/account.oneplus.net\/invite/i))
      @t2 = Time.now
      delta = @t2 - @t1
      puts "Time #{delta}"
      puts m.uri.to_s
      puts m.body.inspect
      my_form = m.form_with(:action => m.uri.to_s)
      if !my_form.nil?
        my_form.submit
        urlp = URI.parse('https://api.pushover.net/1/messages.json')
        req = Net::HTTP::Post.new(urlp.path)
        req.set_form_data({
                            :token => '',
                            :user => '',
                            :title => 'New invite',
                            :message => @us.email
                          })
        res = Net::HTTP.new(urlp.host, urlp.port)
        res.use_ssl = true
        res.verify_mode = OpenSSL::SSL::VERIFY_PEER
        res.start { |http|
          http.request(req)
        }
        @us.update(:invite => true)
        @a.get('https://account.oneplus.net/logout') do |out|
          logout = out.form_with(:action => 'https://account.oneplus.net/logout')
          logout.submit
        end
        @us = Users.first(:invite => false, :order => [ :id.asc ])
        @a.get('https://account.oneplus.net/login') do |app|
          app.form_with(:action => 'https://account.oneplus.net/login') do |f|
            f.email      = @us.email
            f.password   = @us.password
          end.click_button
        end
      else
        puts 'Used invite'
      end
    else
      puts 'Wrong url'
    end
  end
end

TweetStream::Client.new.track('oneplus') do |status|
  puts "#{status.text}"
  #test links
  #text = 'oneplus https://t.co/0JY07GelLz http://t.co/kBKZcHACrH http://t.co/yoaQnLGlnw http://t.co/ckatzqRi4t http://t.co/Ejr366bbFq http://t.co/o0HlgaEjzF'
  #urls = URI.extract(text, ['http', 'https'])
  urls = URI.extract(status.text, ['http', 'https'])
  urls.each do |u|
    @t1 = Time.now
    @a.get(u) do |p|
      html = Nokogiri::HTML(p.body)
      s = html.xpath('//noscript/meta')[0]
      url = s['content'].replace(s['content'].gsub(/0;URL=/, ''))
      if (url.match(/account.oneplus.net\/invite/i))
        getinvite(url)
      elsif (url.match(/mandrillapp.com/i))
        getinvite(url)
      elsif (url.match(/bit.ly/i))
        getinvite(url)
      elsif (url.match(/j.mp/i))
        getinvite(url)
      elsif (url.match(/ow.ly/i))
        getinvite(url)
      elsif (url.match(/goo.gl/i))
        getinvite(url)
      elsif (url.match(/fb.me/i))
        getinvite(url)
      elsif (url.match(/lnkd.in/i))
        getinvite(url)
      end
    end
  end
  if (@count == 20)
    puts @count
    @a.get('https://account.oneplus.net/dashboard')
    puts @a.page.body.inspect
    @count = 0
  else
    puts @count
    @count = @count + 1
  end
end
