class Api::ApplicationController < ActionController::API
  include CanCan::ControllerAdditions
  include ActionController::Serialization
  include ActionView::Helpers::DateHelper

  before_action :session_token_authenticate!, :set_crucial_variables_to_thread
  before_action :set_paper_trail_whodunnit

  check_authorization
  skip_authorization_check only: :welcome

  rescue_from AuthenticationService::NotAuthorized, with: :_not_authorized

  def welcome
    render json: { hi: current_user.email }
  end

  if Rails.env != 'development'
    rescue_from Exception do |exception|
      exception_logger = Logger.new('log/exceptions.log')
      logger.error("#{Time.zone.now.strftime('%H:%M %Y-%m-%d') }: ERROR - Exception - #{exception.message} (see details in exceptions.log)")
      exception_logger.error("#{Time.zone.now.strftime('%H:%M %Y-%m-%d') }: ERROR - Exception - #{exception.message}")
      exception_logger.error("     #{params.inspect}") if params
      if exception.backtrace.is_a?(String)
        exception_logger.error("#{exception.backtrace}")
      else
        exception_logger.error("\n\r     #{exception.backtrace.join("\n\r     ")}")
      end
      render json: {errors: ['Error']}, status: 500
    end


    rescue_from ActiveRecord::RecordNotFound do |exception|
      exception_logger = Logger.new('log/exceptions.log')
      logger.error("#{Time.zone.now.strftime('%H:%M %Y-%m-%d') }: ERROR - ActiveRecord::RecordNotFound - #{exception} (see details in exceptions.log)")
      exception_logger.error("#{Time.zone.now.strftime('%H:%M %Y-%m-%d') }: ERROR - ActiveRecord::RecordNotFound - #{exception.message}")
      exception_logger.error("     #{params.inspect}") if params
      if exception.backtrace.is_a?(String)
        exception_logger.error("#{exception.backtrace}")
      else
        exception_logger.error("\n\r     #{exception.backtrace.join("\n\r     ")}")
      end
      _not_found
    end

    rescue_from ActionController::RoutingError do |exception|
      exception_logger = Logger.new('log/exceptions.log')
      logger.error("#{Time.zone.now.strftime('%H:%M %Y-%m-%d') }: ERROR - ActionController::RoutingError - #{exception} (see details in exceptions.log)")
      exception_logger.error("#{Time.zone.now.strftime('%H:%M %Y-%m-%d') }: ERROR - ActionController::RoutingError - #{exception.message}")
      exception_logger.error("     #{params.inspect}") if params
      if exception.backtrace.is_a?(String)
        exception_logger.error("#{exception.backtrace}")
      else
        exception_logger.error("\n\r     #{exception.backtrace.join("\n\r     ")}")
      end
      render json: {errors: ['Invalid route']}, status: 500
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    exception_logger = Logger.new('log/exceptions.log')
    logger.error("ERROR: CanCan::AccessDenied - #{exception} (see details in exceptions.log), user: #{current_user.present? ? current_user.inspect : 'THERE IS NO LOGGED USER'}")
    exception_logger.error("ERROR: CanCan::AccessDenied - #{exception.message}, user: #{current_user.present? ? current_user.inspect : 'THERE IS NO LOGGED USER'}")
    exception_logger.error("\t#{params.inspect}") if params
    if exception.backtrace.is_a?(String)
      exception_logger.error("#{exception.backtrace}")
    else
      exception_logger.error("\n\r\t#{exception.backtrace.join("\n\r\t")}")
    end
    _access_denied
  end
  rescue_from AuthenticationService::NotAuthorized, with: :_not_authorized

  protected

    def user_for_paper_trail
      current_user.try(:id)
    end

  private

    def signed_in?
      !!current_api_session_token.user
    end

    def current_user
      current_api_session_token.user if signed_in?
    end

    def current_ability
      @current_ability = if current_user
        UserAbility.new current_user
      else
        Ability.new
      end
    end

    def set_crucial_variables_to_thread
      if current_user
        Thread.current[:current_user_id]      = current_user.id
      else
        Thread.current[:current_user_id]      = nil
      end
    end

    def session_token_authenticate!
      return _not_authorized unless _authorization_header && current_api_session_token.valid?
    end


    def current_api_session_token
      @current_api_session_token ||= ApiSessionToken.new(_authorization_header)
    end

    def _authorization_header
      if request.headers['Authorization'] && request.headers['Authorization'].split(' ').last.length == ENV['API_SECRET_LENGTH'].to_i
        logger.debug { "\n======= Authorization =======" }
        logger.debug { request.headers['Authorization'].split(' ').last }
        request.headers['Authorization'].split(' ').last
      else
        logger.warn { "\n======= NO Authorization token =======\n" }
        nil
      end
    end

    def _locale_header
      if request.headers['Locale']
        logger.debug { "\n======= LOCALE =======" }
        logger.debug { "---> #{request.headers['Locale']} <---" }
        request.headers['LOCALE']
      elsif current_user.present? && current_user.current_locale.present?
        logger.warn { "\n======= NO LOCALE SET - DEFAULTING TO CURRENT RESOURCE's LOCALE =======\n" }
        logger.debug { "---> #{current_user.current_locale} <---" }
        current_user.current_locale
      else
        logger.warn { "\n======= NO LOCALE SET AND NO CURRENT RESOURCE PRESENT - DEFAULTING TO EN =======\n" }
        'en'
      end
    end

    def _access_denied(error="Access denied")
      _error error, 451
    end

    def _not_authorized message = "Not Authorized"
      _error message, 401
    end

    def _not_found message = "Not Found"
      _error message, 404
    end

    def _error message, status
      render json: { error: message }, status: status
    end

    def current_scope
      {
        fields: (params[:fields] || {}),
        current_user: current_user
      }
    end

    def require_params *key_sets
      error = true
      key_sets.each do |keys|
        vals = keys.map { |key|
          params.keys.map { |pkey|
            pkey.to_s.starts_with?(key.to_s) && params[pkey].present?
          }.include?(true)
        }

        error = !vals.all?(&:present?)
        break unless error
      end
      raise RequiredParamsNotPresent, "Required parameters: #{key_sets.map {|ks| ks.join(', ')}.join(' or ')}" if error
    end

end
