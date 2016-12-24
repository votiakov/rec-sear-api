class Api::V1::AppExceptionsController < Api::ApplicationController

  skip_authorization_check
  skip_before_action :session_token_authenticate!

  def manager
    manager_logger = Logger.new('log/manager_exceptions.log')
    manager_logger.error( "#{params[:type]} - #{params[:name]} (#{params[:message]})\nURL: #{params[:url]}\nCAUSE: #{params[:cause]}\n#{params[:stack]}\n" )
    render plain: 'OK'
  end
end