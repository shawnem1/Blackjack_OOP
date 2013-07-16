#require 'rubygems'
#require 'pry'

class Card

  attr_accessor :suit, :value

  def initialize(s, v)
    @suit = s
    @value = v
  end

  def show_value
    puts "#{value} of #{get_suit}"
  end

  def to_s
    show_value
  end

  def get_suit
    case suit
      when 'S' then 'Spades'
      when 'H' then 'Hearts'
      when 'C' then 'Clubs'
      when 'D' then 'Diamonds'
    end
  end
  
end

################################################

class Deck

  attr_accessor :cards

  def initialize
    @cards = []
    %w(S H C D).product(%w(2 3 4 5 6 7 8 9 10 J Q K A)).each do |arr|
      @cards << Card.new(arr[0], arr[1])
    end
  end

  def shuffle_deck
    cards.shuffle!
  end

  def deal_one
    cards.pop
  end

end

################################################

module Hand

  def show_hand
    puts "****#{name}'s, Hand****"
    puts ''
    cards.each do|card|
    "=> #{card}"
    end
    puts ''
    puts "Total: #{hand_total}"
  end

  def hand_total
    face_values = cards.map{|card| card.value  }

    total = 0
    face_values.each do |val|
      case val
      when 'A' then total += 11
      when 'K' then total += 10
      when 'Q' then total += 10
      when 'J' then total += 10
      else
        total += (val.to_i == 0 ? 10 : val.to_i)
      end
    end
    #Account for Aces
    face_values.select {|e| e == "A"}.count.times do
      if total > 21 
        total -= 10
      end
    end
    total
  end

  def busted?
    hand_total > Blackjack::BLACKJACK_AMOUNT
  end

  def add_card(new_card)
    cards << new_card
  end

end

################################################

class Dealer

  include Hand

  attr_accessor :name, :cards

  def initialize
    @name = "Dealer"
    @cards = []
  end

  def show_flop
  puts "****#{name}'s, Hand****"
  puts ''
  "#{cards[1]}"
  end

end

################################################

class Player

  include Hand

  attr_accessor :name, :cards

  def initialize(n)
    @name = n
    @cards = []
  end

end

################################################


class Blackjack

  attr_accessor :deck, :player, :dealer

  BLACKJACK_AMOUNT = 21
  DEALER_HIT_MIN = 17

  def initialize
    @deck = Deck.new
    @dealer = Dealer.new
    @player = Player.new("Player1")
  end

  def set_player_name
    puts 'What is your name?'
    player.name = gets.chomp
    puts ''
  end

  def deal_cards
    player.add_card(deck.deal_one)
    dealer.add_card(deck.deal_one)
    player.add_card(deck.deal_one)
    dealer.add_card(deck.deal_one)
  end

  def show_flop
    dealer.show_flop
    puts ''
    player.show_hand
  end

  def blackjack_or_bust?(player_or_dealer)
    if player_or_dealer.hand_total == BLACKJACK_AMOUNT
      if player_or_dealer.is_a?(Dealer)
        puts "Sorry, dealer hit blackjack. #{player.name} loses."
      else
        puts "Congratulations, you hit blackjack! #{player.name} wins!"
      end
      play_again?
    elsif player_or_dealer.busted?
      if player_or_dealer.is_a?(Dealer)
        puts "Congratulations, dealer busted. #{player.name} win!"
      else
        puts "Sorry, #{player.name} busted. #{player.name} loses."
      end
      play_again?
    end
  end

  def player_turn

    blackjack_or_bust?(player)

    while !player.busted?
      puts "Would you like to 1) hit or 2) stand?"
      response = gets.chomp

      if !['1', '2'].include?(response)
        puts "Error: you must enter 1 or 2"
        next
      end

      if response == '2'
        puts "#{player.name} chose to stay."
        break
      end

      new_card = deck.deal_one
      "Dealing card to #{player.name}: #{new_card}"
      player.add_card(new_card)
      puts "#{player.name}'s total is now: #{player.hand_total}"

      blackjack_or_bust?(player)
    end
    puts "#{player.name} stays at #{player.hand_total}."
  end

  def dealer_turn
    puts "Dealer's turn."

    blackjack_or_bust?(dealer)

    while dealer.hand_total < DEALER_HIT_MIN
      new_card = deck.deal_one
      "Dealing card to dealer: #{new_card}"
      dealer.add_card(new_card)
      puts "Dealer total is now: #{dealer.hand_total}"

      blackjack_or_bust?(dealer)
    end
    puts "Dealer stays at #{dealer.hand_total}."
  end

  def who_won?
    if player.hand_total > dealer.hand_total
      puts "Congratulations, #{player.name} wins!"
    elsif player.hand_total < dealer.hand_total
      puts "Sorry, #{player.name} loses."
    else
      puts "It's a tie!"
    end
    play_again?
  end

  def play_again?
    puts ""
    puts "Would you like to play again? 1) yes 2) no, exit"
    if gets.chomp == '1'
      puts "Starting new game..."
      puts ""
      deck = Deck.new
      player.cards = []
      dealer.cards = []
      start
    else
      puts "Goodbye!"
      exit
    end
  end

  def start
    set_player_name
    deck.shuffle_deck
    deal_cards
    show_flop
    player_turn
    dealer_turn
    who_won?
  end

end

game = Blackjack.new
game.start

################################################
=begin
deck = Deck.new
deck.shuffle_deck
dealer = Dealer.new
puts "Please enter your name"
player = Player.new(gets.chomp)
puts "Welcome to Ruby Blackjack, #{player.name}."
player.add_card(deck.deal_one)
player.add_card(deck.deal_one)
player.show_hand
dealer.add_card(deck.deal_one)
dealer.add_card(deck.deal_one)
dealer.show_hand
=end