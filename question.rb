class Question
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL

    Question.new(results.first)
  end
  
  def self.find_by_author_id(author_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL

    results.map { |result| Question.new(result) }
  end
  
  def self.most_followed(n)
    QuestionFollower.most_followed_questions(n)
  end
  
  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  attr_reader :id, :user_id
  attr_accessor :title, :body
  
  def initialize(options = {})
    @id, @title, @body, @user_id =
      options.values_at('id', 'title', 'body', 'user_id')
  end
  
  def author
    results = QuestionsDatabase.instance.execute(<<-SQL, self.user_id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    User.new(results.first)
  end
  
  def replies
    Reply.find_by_question_id(@id)
  end
  
  def followers
    QuestionFollower.followers_for_question_id(@id)
  end
  
  def likers
    QuestionLike.likers_for_question_id(@id)
  end
  
  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end
  
  def save
    
    if self.id.nil?

    QuestionsDatabase.instance.execute(<<-SQL, title, body, user_id)
      INSERT INTO
        questions (title, body, user_id)
      VALUES
        (?, ?, ?)
    SQL
    
    @id = QuestionsDatabase.instance.last_insert_row_id
    
    else
    
    QuestionsDatabase.instance.execute(<<-SQL, title, body)
      UPDATE
        questions
      SET
        title = ?,
        body = ?
    SQL
    end
  end
end





