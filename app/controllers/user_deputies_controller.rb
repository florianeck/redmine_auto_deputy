class UserDeputiesController < ApplicationController

  before_filter :get_entry, except: [:index]

  def index
    @users = User.where(type: 'User').where.not(id: User.current.id)
    @projects = Project.visible
    @user_deputies = User.current.user_deputies
  end

  def create
    d = UserDeputy.new(deputy_attributes)
    if d.save
      flash[:notice] = t('.notice.saved')
    else
      flash[:error] = t('.error.not_saved', errors: d.errors.full_messages.to_sentence)
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
      flash[:notice] = t('.error.not_deleted', errors: d.errors.full_messages.to_sentence )
    end
    redirect_to action: :index
  end

  private

  def get_entry
    @user_deputy = UserDeputy.where(id: params[:id], user_id: User.current.id).first
  end

  def deputy_attributes
    params.require(:user_deputy).permit(:deputy_id, :project_id).merge(user_id: User.current.id)
  end

end