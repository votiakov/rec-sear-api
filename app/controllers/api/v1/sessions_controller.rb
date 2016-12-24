class Api::V1::SessionsController < Api::ApplicationController
  skip_authorization_check
  skip_authorize_resource
  skip_before_action :session_token_authenticate!, only: [:create, :show, :create_from_provider, :create_from_twitter, :twitter_step_2, :finish_create_from_provider]


  def create
    if params[:username].present? && params[:password].present?
      @user = nil

      begin
        @user = User.where(email: login, is_active: true).first
      rescue ActiveRecord::StatementInvalid
        @user = nil
      end

      if @user.present? && @user.valid_for_authentication? && _provided_valid_password?

        current_api_session_token.user = @user
        render json: current_user_response(current_api_session_token)
    elsif @user.present? && !@user.is_active
        _error I18n.t('session.errors.account_blocked'), 422
      else
        _error I18n.t('session.errors.bad_credentials'), 422
      end
    else
      _error I18n.t('session.errors.no_credentials'), 422
    end
  end

  def show
    if current_api_session_token.present?
      user = current_api_session_token.user
      if user.present? && user.is_active
        render json: user
      else
        render json: nil
      end
    else
      render json: nil
    end
  end

  def destroy
    current_api_session_token.delete!
    render nothing: true, status: 204
  end

  private

    def _provided_valid_password?
      !!(params[:password] && AuthenticationService.authenticate_with_password(@user, params[:password]))
    end

    def current_user_response ast, temp_user = nil
      response = { token: ast.token }
      response[:user] = if temp_user
        UserSerializer.new(temp_user).serializable_hash
      elsif ast.user.class == User
        UserSerializer.new(ast.user).serializable_hash
      end
      response
    end

end
