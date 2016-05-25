class UserDeputiesController < ApplicationController

  before_filter :check_permission, :get_user
  before_filter :get_entry, except: [:index, :set_availabilities]

  def index
    @users = User.where(type: 'User').where.not(id: User.current.id).where(can_be_deputy: true)
    @projects = Project.visible
    @user_deputies_with_projects    = UserDeputy.with_projects.where(:user_id => User.current.id)
    @user_deputies_without_projects = UserDeputy.without_projects.where(:user_id => User.current.id)
  end

  def create
    @deputy = UserDeputy.new(deputy_attributes)
    if @deputy.save
      flash[:notice] = t('.notice.saved')
    else
      flash[:error] = t('.error.not_saved', errors: @deputy.errors.full_messages.to_sentence)
    end
    redirect_to action: :index
  end

  def move_up
    @user_deputy.move_higher
    redirect_to action: :index
  end

  def move_down
    @user_deputy.move_lower
    redirect_to action: :index
  end

  def delete
    if @user_deputy.destroy
      flash[:notice] = t('.notice.deleted')
    else
      flash[:error] = t('.error.not_deleted', errors: @user_deputy.errors.full_messages.to_sentence )
    end
    redirect_to action: :index
  end

  def set_availabilities
    if availability_attributes.delete(:delete_availabilities) == "1"
      @user.update_attributes(unavailable_from: nil, unavailable_to: nil)
      flash[:notice] = t('.notice.availabilities_cleared')
    elsif @user.update_attributes(availability_attributes)
      flash[:notice] = t('.notice.saved')
    else
      flash[:error] = t('.error.not_saved', errors: @user.errors.full_messages.to_sentence )
    end

    redirect_to action: :index
  end

  def set_permissions
    @user.update_columns(availability_attributes)
    redirect_to action: :index
  end

  private

  def get_entry
    @user_deputy = UserDeputy.where(id: params[:id], user_id: User.current.id).first
  end

  def deputy_attributes
    params.require(:user_deputy).permit(:deputy_id, :project_id).merge(user_id: User.current.id)
  end

  def availability_attributes
    permitted = [:unavailable_from, :unavailable_to, :delete_availabilities]
    permitted += [:can_have_deputies, :can_be_deputy] if User.current.admin?
    @availability_attributes ||= params.require(:user_availability).permit(*permitted)
  end

  def check_permission
    if User.current.admin? || User.current.can_have_deputies?
      return true
    else
      flash[:error] = t('user_deputies.permission_denied')
      redirect_to :back
    end
  end

  def get_user
    if User.current.admin? && params[:user_id]
      @user = User.find(params[:user_id])
    else
      @user = User.current
    end
  end

end