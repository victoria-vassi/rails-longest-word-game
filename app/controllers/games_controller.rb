require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
    @letters.join
  end

  def score
    @attempt = params[:submit_answer]
    @start_time = Time.now
    @end_time = Time.now
    @grid = params[:grid_letters]
    @score = run_game(@attempt, @grid, @start_time, @end_time)
    p @score
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt, grid)
      if english_word?(attempt)
        score += 1
        [score, "Congratulation! #{ [:submit_answer]} is a valid English word"]
      else
        [0, "Sorry but #{ [:submit_answer]} does not seem to be a valid English word"]
      end
    else
      [0, "Sorry but #{ [:submit_answer]} can't build out of #{@letters}"]
    end
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last

    result
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    result = JSON.parse(response.read)
    result['found']
  end
end
