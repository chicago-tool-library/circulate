# frozen_string_literal: true

class ErrorsController < ApplicationController
  def show
    @status_code = params[:code]&.to_i || 500
    @title = error_content[:title]
    @message = error_content[:message]

    render :show, status: @status_code
  end

  private
    def error_content
      case @status_code
      when 404
        {
          title: "Page not found",
          message: "The page you were looking for could not be found."
        }
      when 422
        {
          title: "Unprocessable entity",
          message: "The page you were looking for could not be processed."
        }
      when 500
        {
          title: "Internal server error",
          message: "Something went wrong."
        }
      when 503
        {
          title: "Service unavailable",
          message: "The service you were looking for is unavailable."
        }
      else
        {
          title: "Error",
          message: "Something went wrong."
        }
      end
    end
end
