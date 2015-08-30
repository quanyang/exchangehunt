class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:update, :edit]
  before_action :ensure_complete_registration, only: [:show]

  before_action :set_user_by_username, only: [:show, :username, :edit]
  before_action :set_user_by_id, only: :update

  skip_before_filter :verify_authenticity_token, only: [:confirm]

  # check existence for username
  def username
    respond_to do |format|
      format.json { render :ok, json: @user.username.to_json }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: restrict_user_info(@user).to_json.html_safe }
    end
  end

  def update
    raise_400 and return unless authorized?(@user)
    unless InstitutionEmail.valid_domain?(user_params[:home_email])
      raise_400("Sorry, your institution is not one of the participating institutions.")
      return
    end

    if @user.update_attributes(user_params)
      render status: 200, json: @user.username.to_json.html_safe
    end
  end

  def confirm
    token = params[:t]
    user = User.find_by_home_institution_confirmation_token(token)
    if user
      user.confirm_home_email!
      respond_to do |format|
        format.html
      end
    else
      raise_404
    end
  end

  def edit
  end

  private

  def set_user_by_username
    @user = User.find_by_username(params[:id].downcase)
    raise_404 unless @user
  end

  def set_user_by_id
    @user = User.find(params[:id])
    raise_404 unless @user
  end

  def user_params
    params.require(:user).permit(:username, :home_email, :exchange_email)
  end

  def restrict_user_info(user_hash)
    restricted_hash = {}
    restricted_hash[:first_name] = user_hash[:first_name]
    restricted_hash[:last_name] = user_hash[:last_name]
    restricted_hash[:image_url] = user_hash[:image_url]
    restricted_hash[:home_institution] = user_hash[:home_institution]
    restricted_hash
  end

end
