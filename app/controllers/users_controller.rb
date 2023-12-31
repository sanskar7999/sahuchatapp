class UsersController < ApplicationController
    def show
      @user = User.find(params[:id])
      @users = User.all_except(current_user)
  
      @room = Room.new
      @rooms = Room.public_rooms
      @room_name = get_name(@user, current_user)
      @single_room = Room.where(name: @room_name).first || Room.create_private_room([@user, current_user], @room_name)
  
      @message = Message.new
      pagy_messages = @single_room.messages.order(created_at: :desc)
      @pagy, messages = pagy(pagy_messages, items: 10)
      @messages = messages.reverse
      render 'rooms/index'
    end

    def edit
      @article = User.find(params[:id])
    end
  
    def update
      @article = User.find(params[:id])
      if @article.update(users_params)
        redirect_to root_path,allow_other_host: true , notice: 'User updated successfully'
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    private
  
    def get_name(user1, user2)
      user = [user1, user2].sort
      "private_#{user[0].id}_#{user[1].id}"
    end

    def users_params
      params.require(:user).permit(:name, :avatar)
    end
  end