# frozen_string_literal: true

class BusinessThingsController < ApplicationController
  def action
    BusinessEvent.add!(thing)
    render status: :accepted
  end

  private

  def thing
    @thing ||= BusinessThing.find(thing_id)
  end
end
