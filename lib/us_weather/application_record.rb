# frozen_string_literal: true

module USWeather
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
