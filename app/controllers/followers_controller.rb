class FollowersController < ApplicationController
  before_action :authenticate_user
  #  following a user
  def follow
    # checking if the user is requesting to follow himself

    if current_user.id == (params[:follower]).to_i
      bad_request
    else
      #  checking if the user has already followed the user
      check = Follower.where(user_id: current_user.id, following: params[:follower]).exists?
      # if exists then remove the follower
      if check
        # getting record id in the table
        follower = Follower.where(user_id: current_user.id, following: params[:follower]).first!
        # deleting the record
        Follower.destroy(follower.id)
        success('Follower Removed')
      else
        #  check if the user to be followed exists
        begin
          user_check = User.where(id: params[:follower]).first!
          #  user validity is not false then add the user
          if user_check.validity
            #  no errors are generated then create a new follower
            new_follower = Follower.create(:user_id => current_user.id, :following => params[:follower])
            if new_follower.nil?
              error_msg('Opps! Something Went Wrong')
            else
              success('You followed a new  user')
            end
          else
            error_msg('User You Are Trying To Follow Has Been Banned From The Site')
          end

        rescue ActiveRecord::RecordNotFound => e
          bad_request
        end

      end
    end
  end

  # returns bad request error
  def bad_request
    render json: { "status": 400, "message": 'Bad Request Please Check The Request Again!' }
  end

  def success(msg)
    render json: { "status": 'Success!', "message": msg }
  end

  def error_msg(msg)
    render json: { "message": msg }
  end

end
