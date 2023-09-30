# frozen_string_literal: true

class DevController < ApplicationController
  def set_time
    new_time = Time.zone.parse params[:new_time]
    session[:time_override] = new_time
    redirect_to params[:return_to]
  end

  def clear_time
    session.delete(:time_override)
    redirect_to params[:return_to]
  end

  def styles
  end
end
