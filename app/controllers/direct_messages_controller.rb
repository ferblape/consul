class DirectMessagesController < ApplicationController
  skip_authorization_check

  def new
    @receiver = User.find(params[:user_id])
    @direct_message = DirectMessage.new(receiver: @receiver)
  end

  def create
    @sender = current_user
    @receiver = User.find(params[:user_id])

    @direct_message = DirectMessage.new(parsed_params)
    if @direct_message.save
      Mailer.direct_message(@direct_message).deliver_later
      redirect_to [@receiver, @direct_message], notice: I18n.t("flash.actions.create.direct_message")
    else
      render :new
    end
  end

  def show
    @direct_message = DirectMessage.find(params[:id])
  end

  private

    def direct_message_params
      params.require(:direct_message).permit(:title, :body)
    end

    def parsed_params
      direct_message_params.merge(sender: @sender, receiver: @receiver)
    end
end