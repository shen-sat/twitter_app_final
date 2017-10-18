#gems required
require 'sinatra'
require 'rubygems'
require 'twitter'
require 'yaml'
require 'erb'

#sinatra bit of code - displays the html code constructed by making a new Begin class object and then calling the method init_app on that object
get '/' do 
	b = Begin.new
	b.init_app
end

#This is code for the 'Begin' class which has a method (init_app, which draws data from Twitter and constructs the html code).
#Sinatra will call an object from this class and then run the def_init method on that object to run its associated code.
#The def_init method returns html code (ruby methods return whatever value is produced last) which is needed by Sinatra to render the webpage.
class Begin
	def init_app
		#Twitter authentication stuff **--REMEMBER TO DELETE YOUR DETAILS IF YOU MAKE PUBLIC--**
		client = Twitter::REST::Client.new do |config|
		  config.consumer_key        = ENV['CONSUMER_KEY']
		  config.consumer_secret     = ENV['CONSUMER_SECRET']
		  config.access_token        = ENV['ACCESS_TOKEN']
		  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
		 end

		#get the time limit for 24 hours before the time of search and convert it to string 
		yesterday_time = Time.now.utc - (60*60*24)
		search_date_limit = yesterday_time.to_date.to_s

		#set up an array to collect the tweets from the search
		todays_pixelart_tweets = [] 

		#set the search operators. These are regular search operators that can be used within Twitter itself. 
		pixel_art_tweets = client.search("#pixelart AND filter:images AND -filter:retweets AND -filter:replies AND since:#{search_date_limit}")

		#for each tweet in previous search, make sure it has media, make sure that media is a pic and make sure it was created by the ime set previously.
		#This bit of code also has a .dup method -- this takes variables that can't be modified (eg tweet.created_at) and duplicates it so it can be modified.
		#In this code it is modified to display time in UTC (ie that's what the .utc method is for)
		pixel_art_tweets.each do |tweet|
			if tweet.media? && tweet.media[0].attrs[:type] == "photo" && tweet.created_at.dup.utc > yesterday_time
				todays_pixelart_tweets.push(tweet)
			end
		end

		#sort the resulting tweet array by number favorite count
		sorted_tweets = todays_pixelart_tweets.sort_by do |tweet|
			tweet.favorite_count
		end
		
		#the sorted array will be in ascending order, so reverse it to get most-liked tweet at the top
		reverse_sorted_tweets = sorted_tweets.reverse
		
		#because the html page this will be rendered into is a four by four grid, take the first four tweets and assign them to an array, then so the same
		#with the next four tweets
		top_four_tweets = reverse_sorted_tweets[0..3]
		next_four_tweets = reverse_sorted_tweets[4..7]

		#set up the html code for the page and insert pixel art images and assign it to variable 'template'
		template = %(
			<!DOCTYPE html>
			<html>
				<head>
					<meta charset="utf-8">
					<title>Twitter Pixelart App</title>
					<meta name="viewport" content="width=device-width, initial-scale=1">
					<link rel="stylesheet" href="https://unpkg.com/tachyons@4.8.1/css/tachyons.min.css">
					<link href="https://cdnjs.cloudflare.com/ajax/libs/lightbox2/2.9.0/css/lightbox.min.css" rel="stylesheet">
				</head>
				<body>
					<!-- basic banner -->
					<div class="mt4 w-100 w-80-m w-60-ns center tc ph3 mb5 mb4-ns">
						<h1 class="f2 f1-l fw9 gray-90 mb0 lh-title sans-serif">MY FIRST WEB APP</h1>
						<h2 class="fw1 f5 gray-80 mt3 mb4 lh-copy sans-serif">Below are the eight most favourited #pixelart images on Twitter in the past 24 hours.<br>
						Up-to-date images and their details are pulled from Twitter every time you refresh this page.</h2>
					</div>
					
					<!-- top 10 pixelarts -->
					<section class="cf w-100 pa2-ns sans-serif">
						<% top_ten_tweets.each do |tweet| %>
						<article class="fl w-100 w-50-m mb4 w-25-ns pa2-ns">
							<div class="aspect-ratio aspect-ratio--1x1">
								<a href="<%= tweet.media[0].media_url %>" data-lightbox="art" data-title="<%= tweet.user.screen_name %>">
									<img style="background-image:url(<%= tweet.media[0].media_url %>);" 
									class="db bg-center cover aspect-ratio--object" />
								</a>
							</div>
							<h3 class="f5 f4-ns mb0 black-90">
								<a href="<%= tweet.user.url %>" class="ph1 ph0-ns dim gray link hover-blue"><%= tweet.user.screen_name %></a>
								<span class="f5 f4-ns mb0 gray fr">♥ <%= tweet.favorite_count %></span>
							</h3>
							<h3 class="f6 f5 fw4 mt1 black-60">
								<a href="<%= tweet.url %>" class="ph1 ph0-ns pb3 dim gray link hover-blue">View Tweet</a>
							</h3>
						</article>
						<% end %>
					</section>
					
					<!-- footer -->
					<footer class="pv4 ph3 ph5-m ph6-l mid-gray sans-serif">
						<small class="f6 db tc">© 2017 <b class="ttu">PIXELARTAPP</b></small>
						<div class="tc mt1">
							<a href="https://github.com/shen-sat" title="Shen" class="f6 dib ph2 link mid-gray dim hover-green">Shen</a> |
							<a href="https://github.com/hanapotski" title="Hannah" class="f6 dib ph2 link mid-gray dim hover-light-purple">Hannah</a>
						</div>
					</footer>
					<script src="https://cdnjs.cloudflare.com/ajax/libs/lightbox2/2.9.0/js/lightbox-plus-jquery.min.js"></script>
				</body>
			</html>
		)

		#create an instance of the class ERB (which we do using the earlier required erb gem)... 
		#...and pass it the template variable (which contains the html code)
		html = ERB.new(template).result(binding)
		#putting html right at the end ensure this method, init_app, returns the html variable whenever it is called
		html
	end
end

=begin ---- spare/junk code ----
		top_pic = top_tweet.media[0]
		# assign other variables to attributes of the tweet and/or its pic
		pic_url = top_pic.media_url
		fave_count = top_tweet.favorite_count
		screen_name = top_tweet.user.screen_name
		user_url = top_tweet.user.url
=end
