class Api::V1::HelpController < Api::V1::BaseController
  skip_before_action :authenticate

  def answers
    list Answer,
         AnswersQueries,
         :answers_list,
         current_user: current_user
  end

  def contact
    save_record Question.new(question_params)
  end

  private

  def question_params
    allowed_params = params.permit :full_name, :email, :body
    allowed_params[:email] = current_user.email if allowed_params[:email].blank? && current_user&.email.present?
    allowed_params
  end
end
