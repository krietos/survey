require 'spec_helper'

describe Survey do
  it {should have_many :questions}
end
