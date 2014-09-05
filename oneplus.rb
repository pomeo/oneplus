#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'mechanize'
require 'tweetstream'
require 'open-uri'
require 'logger'
require 'uri'
require 'net/https'

@a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Windows Chrome'
}

def getinvite(url)
  @a.get(url) do |m|
    if (m.uri.to_s.match(/account.oneplus.net\/invite/i))
      puts m.uri.to_s
      @t2 = Time.now
      delta = @t2 - @t1
      puts "Time #{delta}"
      my_form = m.form_with(:action => m.uri.to_s)
      if !my_form.nil?
        my_form.submit
      else
        puts 'Использованный инвайт'
      end
    else
      puts 'Кривая ссылка'
    end
  end
end

text = 'oneplus https://t.co/0JY07GelLz http://t.co/yoaQnLGlnw http://t.co/ckatzqRi4t http://t.co/Ejr366bbFq http://t.co/o0HlgaEjzF'
urls = URI.extract(text, ['http', 'https'])
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
    elsif (url.match(/goo.gl/i))
      getinvite(url)
    end
  end
end
