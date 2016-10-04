require 'jumpstart_auth'
require 'bitly'
require 'klout'

Bitly.use_api_version_3

class MicroBlogger
	attr_reader :client

	def initialize
		puts "Initializing MicroBlogger"
		@client = JumpstartAuth.twitter
		Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'

	end

	def run
		puts "Welcome to the JSL Twitter Client!"
		command = ""
		while command != "q"
			printf "enter command: "
			input = gets.chomp
			parts = input.split(" ")
			command = parts[0]
			case command
				when 'q' then puts "Goodbye!"
				when 't' then tweet(parts[1..-1].join(" "))
				when 'dm' then dm(parts[1], parts[2..-1].join(" "))
				when 'spam' then spam_my_followers(parts[1..-1].join(" "))
				when 'elt' then everyones_last_tweet
				when 's' then shorten(parts[1..-1].join)
				when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
				else
					puts "Sorry, I don't know how to #{command}"
			end
		end
	end

	def tweet(message)
		if message.length <= 140
			@client.update(message)
		else
			puts "Error: Your tweet must be less than 140 characters."
		end
	end

	def dm(target, message)
		puts "Trying to send #{target} this direct message:"
		puts message
		screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
		if screen_names.include? (target)
			message = "d @#{target} #{message}"
			tweet(message)
		else
			puts "Error: You can only DM people who follow you."
		end
	end

	def followers_list
		screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
	end

	def spam_my_followers(message)
		screen_names = followers_list
		screen_names.each do |name|
			dm(name, message)
		end
	end

	def everyones_last_tweet
		friends = @client.friends.sort_by {|friend| @client.user(friend).screen_name.downcase}
			friends.each.sort_by do |friend|
				person = @client.user(friend)
				timestamp = person.status.created_at
				puts "#{person.screen_name} tweeted on #{timestamp.strftime("%A, %b %d")}..."
				puts person.status.text
				puts ""
			end
	end

	def shorten(original_url)
		bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
		puts "Shortening this URL: #{original_url}"
		bitly.shorten(original_url).short_url
	end

	def klout_score
		friends = @client.friends.collect{|f| @client.user(f).screen_name}
		friends.each do |friend|
			i = Klout::Identity.find_by_screen_name(friend)
			user = Klout::User.new(i.id)
			puts friend
			puts user.score.score
			puts ""
		end
	end
end

blogger = MicroBlogger.new
blogger.run
blogger.klout_score
