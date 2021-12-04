class UsersController < ApplicationController

  def index
    @users = User.all.order({ :username => :asc })

    render({ :template => "users/index.html.erb" })
  end

  def show
    the_username = params.fetch("the_username")
    @users = User.where({ :username => the_username }).at(0)

    if session.fetch(:user_id) == nil
      redirect_to("/", { :alert => "You have to sign in first." })
    else
      current_follow_status = FollowRequest.where({ :recipient_id => @users.id, :sender_id => session.fetch( :user_id), :status => "accepted" })
      follow_status = current_follow_status.at(0) 

      if follow_status == nil && @users.private == true
        redirect_to("/", { :alert => "You're not authorized for that." })
      else
        render({ :template => "users/show.html.erb" })
      end 
    end
  end

  def feed
    the_username = params.fetch("the_username")
    @users = User.where({ :username => the_username }).at(0)

    render({ :template => "users/feed.html.erb" })
  end

  def discover
    the_username = params.fetch("the_username")
    @users = User.where({ :username => the_username }).at(0)

    render({ :template => "users/discover.html.erb" })
  end

  def liked
    the_username = params.fetch("the_username")
    @users = User.where({ :username => the_username }).at(0)

    render({ :template => "users/liked_photos.html.erb" })
  end
end

