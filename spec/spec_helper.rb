require 'rspec'
require 'active_record'
require 'shoulda-matchers'

require 'answer'
require 'survey'
require 'question'

ActiveRecord::Base.establish_connection(YAML::load(File.open('./db/config.yml'))['test'])


RSpec.configure do |config|
  config.after(:each) do
    Survey.all.each { |survey| survey.destroy}
    Question.all.each { |question| question.destroy}
    Answer.all.each { |answer| answer.destroy}
  end
end
