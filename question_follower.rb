class QuestionFollower
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_followers
      WHERE
        id = ?
    SQL

    results.map { |result| QuestionFollower.new(result) }
  end
  
  def self.followers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
       * 
      FROM
        users
      JOIN
        question_followers ON  question_followers.user_id = users.id
      WHERE
        question_followers.question_id = ?
    SQL

    results.map { |result| User.new(result) }
  end
  
  def self.most_followed_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        questions
      JOIN
        question_followers ON  question_followers.question_id = questions.id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT
        (?)
    SQL

    results.map { |result| Question.new(result) }
  end

  
  def self.followed_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
       * 
      FROM
        questions
      JOIN
        question_followers ON  question_followers.question_id = questions.id
      WHERE
        question_followers.user_id = ?
    SQL

    results.map { |result| Question.new(result) }
  end
  
  attr_reader :id, :user_id, :question_id
  
  def initialize(options = {})
    @id, @user_id, @question_id =
      options.values_at('id', 'user_id', 'question_id')
  end
end