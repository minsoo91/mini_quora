class Reply
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    Reply.new(results.first)
  end
  
  def self.find_by_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end
  
  def self.find_by_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end
  
  attr_reader :id, :question_id, :parent_id, :user_id
  attr_accessor :body
  
  def initialize(options = {})
    @id, @body, @question_id, @parent_id, @user_id =
      options.values_at('id', 'body', 'question_id', 'parent_id', 'user_id')
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
  
  def question
    results = QuestionsDatabase.instance.execute(<<-SQL, self.question_id)
      SELECT
        *
      FROM
      questions
      WHERE
        id = ?
    SQL

    Question.new(results.first)
  end
  
  def parent_reply
    results = QuestionsDatabase.instance.execute(<<-SQL, self.parent_id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    raise 'NULL parent reply' if @parent_id.nil?
    Reply.new(results.first)
  end
  
  def child_replies
    results = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end
  
  def save
    if self.id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, body, question_id, parent_id, user_id)
        INSERT INTO
          replies (body, question_id, parent_id, user_id)
        VALUES
          (?, ?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, body)
        UPDATE
          replies
        SET
          body = ?
      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
    end
  end
end