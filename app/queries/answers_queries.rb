class AnswersQueries < BaseQueries
  class << self
    def answers_list(params, current_user:, count: false)
      answers = Answer.arel_table

      query = answers
                  .group(answers[:id])

      self.datetime_filters params, query, answers, %i(created_at updated_at)
      self.text_filters params, query, %i(title body)

      unless count
        query.project(Arel.star)

        sort_column = params[:sort_column]&.to_sym
        sort_column = :title unless %i(title created_at updated_at).include?(sort_column)

        query.order(
          answers[sort_column].try self.sort_type(params[:sort_type]) || :asc
        )
      end

      query
    end
  end
end
