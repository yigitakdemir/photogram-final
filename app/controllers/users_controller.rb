class UsersController < ApplicationController
  skip_before_action(:authenticate_user!, { :only => [:index] })
  def index
    @list_of_users = User.all.order(username: :asc)
    render(template: "users_html/index")
  end

  def show
    @username = params.fetch("username")
    @the_user = User.where(username: @username).first

    if @the_user == nil
      redirect_to("/404")
    else
      render(template: "users_html/show")
    end
  end

  def create
    my_input_username = params.fetch("input_username")
    new_user = User.new
    new_user.username = my_input_username
    new_user.save
    redirect_to("/users/" + my_input_username)
  end

  def update
    user_id = params.fetch("user_id")
    my_input_username = params.fetch("input_username")
    the_user = User.where(id: user_id).first
    the_user.username = my_input_username
    the_user.save
    redirect_to("/users/" + my_input_username)
  end

  def follow
    recp_id = params.fetch("recipient_id")
    my_id = current_user.id

    f_req = FollowRequest.new
    f_req.recipient_id = recp_id
    f_req.sender_id = my_id
    
    recp_user = User.where(id: recp_id).at(0)
    recp_priv = recp_user.private
    recp_name = recp_user.username

    if recp_priv
      f_req.status = "pending"
      f_req.save
      redirect_to("/users/")
    else
      f_req.status = "accepted"
      f_req.save
      redirect_to("/users/" + recp_name)
    end
  end

  def unfollow
    @f_req_id = params.fetch("f_req_id")
    matching_f_req = FollowRequest.where(id: @f_req_id.to_i).first
    recp_id = matching_f_req.recipient_id
    recp_name = User.where(id: recp_id).first.username
    matching_f_req.destroy
    redirect_to("/users/" + recp_name)
  end
end
