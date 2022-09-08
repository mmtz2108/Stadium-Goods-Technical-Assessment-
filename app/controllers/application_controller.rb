class ApplicationController < ActionController::API
 include ActionController::Cookies
 

def get_social
  urls = [
    'https://takehome.io/twitter',
    'https://takehome.io/facebook',
    'https://takehome.io/instagram'
  ]

  #Typhoeus allows parallel http requests
  hydra = Typhoeus::Hydra.new
  
  twitter = enqueue_twitter(hydra)
  fb = enqueue_facebook(hydra)
  ig = enqueue_instagram(hydra)


  #Running a self closing loop on_complete to handle all errors for each social media app. Logging a message to the console to let us know of any retries.
  twitter.on_complete do |response|
   if response.success?
    puts "great twitter!"
   else  
    hydra.queue(twitter)
    hydra.run  
    puts 'retrying twitter'
   end
  end
    
  fb.on_complete do |response|
    if response.success?
     puts "great fb!"
    else  
     hydra.queue(fb)
     hydra.run 
     puts 'retrying fb' 
    end
   end

   ig.on_complete do |response|
    if response.success?
     puts "great ig!"
    else  
     hydra.queue(ig)
     hydra.run 
     puts 'retrying ig' 
    end
   end


   hydra.run

   #render as json and parse the data as JSON as well.
  render json: {'twitter' => JSON.parse(twitter.response.body),'facebook' => JSON.parse(fb.response.body), 'instagram' => JSON.parse(ig.response.body)}

  
end

#created these methods as callbacks to add to the queue.
def enqueue_twitter(hydra)
  twitter = Typhoeus::Request.new("https://takehome.io/twitter", followlocation: true)
  hydra.queue(twitter)
  twitter
end

def enqueue_facebook(hydra)
  fb = Typhoeus::Request.new("https://takehome.io/facebook", followlocation: true)
  hydra.queue(fb)
  fb
end

def enqueue_instagram(hydra)
  ig = Typhoeus::Request.new("https://takehome.io/instagram", followlocation: true)
  hydra.queue(ig)
  ig
end
end
