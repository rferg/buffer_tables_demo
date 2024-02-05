# frozen_string_literal: true

class BusinessThing < ApplicationRecord
  has_many :business_events
end
