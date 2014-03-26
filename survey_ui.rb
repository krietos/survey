require 'active_record'
require './lib/question'
require './lib/answer'
require './lib/survey'
require 'pry'
require './lib/josh'

ActiveRecord::Base.establish_connection(YAML::load(File.open('./db/config.yml'))['development'])

def main_menu
  system "clear"
  puts "Are you logging in as a designer or guest?\n\n", "For designer, enter 'd'.", "For guest, enter 'g'."
  input = gets.chomp
  case input
  when 'd'
    designer_menu
  when 'g'
    welcome_user
  else
    puts "That was not a valid choice. Please choose one of the options."
    main_menu
  end
end

################################ DESIGNER OPTIONS #################################

def designer_menu
  system "clear"
  puts "To create a new survey, enter 'n'.", "To view existing surveys, enter 'e'.", "To view survey results, enter 'r'.", "To exit this menu and return to the main menu, press 'x'."
  input = gets.chomp
  case input
  when 'n'
    system "clear"
    new_survey
  when 'e'
    system "clear"
    view_surveys
  when 'r'
    system "clear"
    survey_results
  when 'x'
    system "clear"
    main_menu
  else
    designer_menu
  end
end

def new_survey
  input = nil
  until input == 'n'
    puts "What is the name of this new survey?"
    survey_name = gets.chomp
    new_survey = Survey.create(:name => survey_name)
    add_question(new_survey)
    puts "Do you have another Survey to add? y/n"
    input = gets.chomp
    case input
    when 'y'
    when 'n'
    else
      puts 'Invalid input'
    end
  end
  designer_menu
end

def add_question(new_survey)
  input = nil
  until input == 'n'
    puts 'Please enter a question for this survey'
    question = gets.chomp
    puts "Is this an open ended question? y/n"
    open_ended = gets.chomp
    open_ended = if open_ended == 'y'
                   true
                 elsif open_ended == 'n'
                   false
                 end

    puts "Does this question accept multiple answers? y/n"
    multi_answer = gets.chomp
    multi_answer = if multi_answer == 'y'
                     true
                   elsif multi_answer =='n'
                     false
                   end

    puts "Do you want to allow this question to have an other option? y/n"
    allow_other = gets.chomp
    allow_other = if allow_other == 'y'
                    true
                  elsif allow_other == 'n'
                    false
                  end

    new_question = Question.create(:desc => question, :survey_id => new_survey.id, :multi_answer => multi_answer, :open_ended => open_ended, :allow_other => allow_other)
    if open_ended == false
      add_answer(new_question)
      puts 'Do you have another question to add to this survey? y/n'
      input = gets.chomp
      case input
      when 'y'
      when 'n'
      else
        puts 'invalid input'
      end
    end
  end
end

def add_answer(new_question)
  input = nil
  until input == 'n'
    puts "Please enter an answer to this question"
    answer = gets.chomp
    new_answer = Answer.create(:desc => answer, :question_id => new_question.id, :times_chosen => 0)
    puts "Do you have another answer to add to this question? y/n"
    input = gets.chomp
    case input
    when 'n'
    when 'y'
    else
      puts 'invalid input'
    end
  end
end

def survey_results
  input = nil
  loop do
    puts "Which survey do you want to see the results for? Enter the number. Enter 'x' to exit."
    Survey.all.each { |survey| puts "#{survey.id}. #{survey.name}" }
    input = gets.chomp
    if input == 'x'
      break
    else
      selected_survey = Survey.where({id: input}).first
      if !selected_survey.nil?
        view_survey_results(selected_survey)
      else
        puts "Not a valid survey."
      end
    end
  end
  designer_menu
end

def view_survey_results(survey)
  system "clear"
  puts "This is the number of times each answer was chosen for each question."
  questions = Question.where({survey_id: survey.id})
  questions.each do |question|
    puts question.desc + "\n\n"
    answers = Answer.where({question_id: question.id})
    times_chosen_total = 0
    answers.each do |answer|
      times_chosen_total += answer.times_chosen.to_i
    end
    answers.each do |answer|
      puts "\t#{answer.desc} -- chosen #{answer.times_chosen} times, chosen #{((answer.times_chosen.to_f / times_chosen_total.to_f) * 100).to_i} % of the time."
    end
  end
end

############################## USER MENU ####################################################

def welcome_user
  choice = nil
  loop do
    system "clear"
    puts "Welcome to Survey Bot 3000. Enter the number of the survey you would like to take today, or enter 'x' to exit.\n\n"
    Survey.all.each { |survey| puts "#{survey.id}. #{survey.name}" }
    choice = gets.chomp
    if choice == 'x'
      break
    else
      selected_survey = Survey.where({id: choice}).first
      if !selected_survey.nil?
        take_survey(selected_survey)
      else
        puts 'Not a valid Survey'
      end
    end
  end
  main_menu
end

def take_survey(survey)
  puts "This is the #{survey.name} survey, press 'enter' to continue."
  gets.chomp
  system "clear"
  questions = Question.where({:survey_id => survey.id})
  questions.each do |question|
    system "clear"
    puts question.desc
    if question.open_ended == true
      puts "Please enter the answer in your own words below."
      open_input = gets.chomp
      Answer.create({:desc => "open_answer", :question_id => question.id, :open_answer => open_input})
    else
      answers = Answer.where({:question_id => question.id})
      answers = answers.select{ |answer| answer.open_answer == nil}
      answers.each do |answer|
        puts answer.desc
      end
      if question.multi_answer == true
        puts 'This question accepts multiple answers'
        puts 'Enter the answer(s) you are choosing seperated by a comma and a space'
      elsif question.allow_other == true
        puts "Enter the answer you are choosing, or input your own answer."
      else
        puts "Enter the answer you are choosing."
      end
      selected_answers = gets.chomp
      answer_array = selected_answers.split(', ')
      answer_array.each do |answer|
        chosen_answer = Answer.where({desc: answer, question_id: question.id}).first
        if chosen_answer == nil
          Answer.create({desc: 'other_answer', question_id: question.id, open_answer: answer})
        else
        chosen_answer.update({ times_chosen: (chosen_answer.times_chosen + 1)})
        end
      end
    end
  end
end

main_menu
