class QuestionLike
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL

    results.map { |result| QuestionLike.new(result) }
  end
  
  def self.likers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
       * 
      FROM
        users
      JOIN
        question_likes ON  question_likes.user_id = users.id
      WHERE
        question_likes.question_id = ?
    SQL

    results.map { |result| User.new(result) }
  end
  
  def self.num_likes_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*) AS num
      FROM
        question_likes
      WHERE
        question_id = ?
    SQL

    results.first['num']
  end
  
  def self.liked_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
       *
      FROM
        questions
      JOIN
        question_likes ON  question_likes.question_id = questions.id
      WHERE
        question_likes.user_id = ?
    SQL

    results.map { |result| Question.new(result) }
  end
  
  def self.most_liked_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        questions
      JOIN
        question_likes ON  question_likes.question_id = questions.id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT
        (?)
    SQL

    results.map { |result| Question.new(result) }
  end
  
  attr_reader :id, :user_id, :question_id
  
  def initialize(options = {})
    @id, @user_id, @question_id =
      options.values_at('id', 'user_id', 'question_id')
  end
end