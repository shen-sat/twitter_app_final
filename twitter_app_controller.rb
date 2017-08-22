#gems required
require 'sinatra'
require 'rubygems'
require 'twitter'
require 'yaml'
require 'erb'

#Twitter authentication stuff **--REMEMBER TO DELETE YOUR DETAILS IF YOU MAKE PUBLIC--**
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "t3F5fBiVwUjsZyzxAcpDWGHF4"
  config.consumer_secret     = "YjEpZWx5xQYZ8RD82Dbgutd4m7kytoa3H3nvcppAVOy56LmhSe"
  config.access_token        = "2347401997-3PzoVOwfAUCr5BVQJ4VmyooGGBXSlcMxV433NDs"
  config.access_token_secret = "kAkks0m2oWbKb2H9z874f6fMEsquH5xvdB6Tdm7CS95CQ"
 end

#get the time limit for 24 hours before the time of search and convert it to string 
yesterday_time = Time.now.utc - (60*60*24)
search_date_limit = yesterday_time.to_date.to_s

#set up an array to collect the tweets from the search
todays_pixelart_tweets = [] 

#set the search operators. These are regular search operators that can be used within Twitter itself. 
pixel_art_tweets = client.search("#pixelart AND filter:images AND -filter:retweets AND -filter:replies AND since:#{search_date_limit}")

#for each tweet in previous search, make sure it has media, make sure that media is a pic and make sure it was created by the ime set previously.
#This bit of code also has a .dup method -- this takes variable that can't be modified (eg tweet.created_at) and duplicates it so it can be modified.
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



=begin
top_pic = top_tweet.media[0]
# assign other variables to attributes of the tweet and/or its pic
pic_url = top_pic.media_url
fave_count = top_tweet.favorite_count
screen_name = top_tweet.user.screen_name
user_url = top_tweet.user.url
=end



#set up the html code for the page and insert pixel art images
template = %(
<html>
<title>W3.CSS Template</title>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Lato">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<style>
body,h1,h2,h3,h4,h5,h6 {font-family: "Lato", sans-serif;}
body, html {
    height: 100%;
    color: #777;
    line-height: 1.8;
}
</style>

<body>
<!-- Container (Portfolio Section) -->
<div class="w3-content w3-container w3-padding-64" id="portfolio">
  <h3 class="w3-center">MY FIRST WEB APP</h3>
  <p class="w3-center">Below are the eight most favourited #pixelart images on Twitter in the past 24 hours<br>
 	<em>Click on the images to make them bigger and view details</em></p><br>

  <!-- Responsive Grid. Four columns on tablets, laptops and desktops. Will stack on mobile devices/small screens (100% width). --> 
  <div class="w3-row-padding w3-center"> 
	
	
	
	<!--set html code, image and details for each tweet in first array -->
	<% top_four_tweets.each do |tweet| %>
		<div class="w3-col m3">
		<img src="<%= tweet.media[0].media_url %>" style="width:100%" onclick="onClick(this)" class="w3-hover-opacity" 
		alt="Created at <%= tweet.created_at %> by @<a href='<%= tweet.user.url %>'><%= tweet.user.screen_name %></a>
		</br>Fave count: <%= tweet.favorite_count %>  ||  <a href='<%= tweet.url %>'>View tweet</a>">
		</div>
	<% end %>
  </div>

  <!--set divider between rows of images -->
  <div class="w3-row-padding w3-center w3-section">
    
	<!--set html code, image and details for each tweet in next array -->
	<% next_four_tweets.each do |tweet| %>
		<div class="w3-col m3">
		<img src="<%= tweet.media[0].media_url %>" style="width:100%" onclick="onClick(this)" class="w3-hover-opacity" 
		alt="Created at <%= tweet.created_at %> by @<a href='<%= tweet.user.url %>'><%= tweet.user.screen_name %></a>
		</br>Fave count: <%= tweet.favorite_count %>  ||  <a href='<%= tweet.url %>'>View tweet</a>">
		</div>
	<% end %>

  </div>
</div>

<!-- Modal for full size images on click-->
<div id="modal01" class="w3-modal w3-black" onclick="this.style.display='none'">
  <span class="w3-button w3-large w3-black w3-display-topright" title="Close Modal Image"><i class="fa fa-remove"></i></span>
  <div class="w3-modal-content w3-animate-zoom w3-center w3-transparent w3-padding-64">
    <img id="img01" class="w3-image">
    <p id="caption" class="w3-opacity w3-large"></p>
  </div>
</div>





<!-- Footer -->
<footer class="w3-center w3-black w3-padding-64 w3-opacity w3-hover-opacity-off">

  <div class="w3-xlarge w3-section">
    <a href="https://twitter.com/shen_sat"<i class="fa fa-twitter w3-hover-opacity"></i></a>
    <a href="https://www.linkedin.com/in/shen-satkunarasa-8586b2b2/?ppe=1"<i class="fa fa-linkedin w3-hover-opacity"></i></a>
  </div>
  <p>Powered by <a href="https://www.w3schools.com/w3css/default.asp" title="W3.CSS" target="_blank" class="w3-hover-text-green">w3.css</a></p>
</footer>
 
<!-- Add Google Maps -->
<script>
function myMap()
{
  myCenter=new google.maps.LatLng(41.878114, -87.629798);
  var mapOptions= {
    center:myCenter,
    zoom:12, scrollwheel: false, draggable: false,
    mapTypeId:google.maps.MapTypeId.ROADMAP
  };
  var map=new google.maps.Map(document.getElementById("googleMap"),mapOptions);

  var marker = new google.maps.Marker({
    position: myCenter,
  });
  marker.setMap(map);
}

// Modal Image Gallery
function onClick(element) {
  document.getElementById("img01").src = element.src;
  document.getElementById("modal01").style.display = "block";
  var captionText = document.getElementById("caption");
  captionText.innerHTML = element.alt;
}

// Change style of navbar on scroll
window.onscroll = function() {myFunction()};
function myFunction() {
    var navbar = document.getElementById("myNavbar");
    if (document.body.scrollTop > 100 || document.documentElement.scrollTop > 100) {
        navbar.className = "w3-bar" + " w3-card-2" + " w3-animate-top" + " w3-white";
    } else {
        navbar.className = navbar.className.replace(" w3-card-2 w3-animate-top w3-white", "");
    }
}

// Used to toggle the menu on small screens when clicking on the menu button
function toggleFunction() {
    var x = document.getElementById("navDemo");
    if (x.className.indexOf("w3-show") == -1) {
        x.className += " w3-show";
    } else {
        x.className = x.className.replace(" w3-show", "");
    }
}
</script>


</body>
</html>

)

#create an instance of the class ERB (which we do using the earlier required erb gem) and pass it the html code
html = ERB.new(template).result(binding)

#sinatra bit of code - displays the html code
get '/' do 
	html

end
