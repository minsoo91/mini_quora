class User
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    User.new(results.first)
  end
  
  def self.find_by_name(fname, lname)
    results = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL

    User.new(results.first)
  end
  
  attr_accessor :fname, :lname
  attr_reader :id
  
  def initialize(options = {})
    @id, @fname, @lname =
      options.values_at('id', 'fname', 'lname')
  end
  
  def authored_questions
    Question.find_by_author_id(@id)
  end
  
  def average_karma
    results = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT
        CAST(COUNT(question_likes.id) AS FLOAT) / COUNT(DISTINCT(questions.id))
      FROM
        questions
      JOIN
        question_likes
      ON
        questions.id = question_likes.question_id
      WHERE
        questions.user_id = ?
    SQL

    results.first.values.first
  end
  def authored_replies
    results = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end
  
  def followed_questions
    QuestionFollower.followed_questions_for_user_id(@id)
  end
  
  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end
  
  def save 
    if self.id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
        INSERT INTO
          users (fname, lname)
        VALUES
          (?, ?)
      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
        UPDATE
          users
        SET
          fname = ?,
          lname = ?
      SQL
    end
  end
end