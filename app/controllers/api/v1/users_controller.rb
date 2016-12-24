class Api::V1::UsersController < Api::ApplicationController

  load_resource only: [:show, :update, :destroy, :reify]
  authorize_resource except: :index

  skip_before_action :session_token_authenticate!, only: :index
  skip_authorization_check only: :index
  skip_authorize_resource only: :index

  def index
    render json: User.filter(params).accessible_by(current_ability), serializer: CustomArraySerializer
  end

  def show
    render json: @user
  end

  def create
    # TODO: user create action
  end

  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: ErrorsJSON.serialize(@user), status: 422
    end
  end

  def destroy
    if @user.update_attribute(:is_active, false)
      render json: @user
    else
      render json: ErrorsJSON.serialize(@user), status: 422
    end
  end

  def reify
    if @user.update_attribute(:is_active, true)
      render json: @user
    else
      render json: ErrorsJSON.serialize(@user), status: 422
    end
  end

  private

    def user_params
      params.require(:user).permit(
        :id,
        :email,
        :name,
        :surname,
        :password,
        :avatar,
        :avatar_uri,
        :phone_number,
        :login,
        :kind,
        :is_active,
        roles: [],
      )
    end
end
