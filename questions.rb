require 'singleton'
require 'sqlite3'
require 'byebug'

class QuestionsDatabase < SQLite3::Database
  include Singleton
  
  def initialize
    super('questions.db')
    self.results_as_hash = true
    self.type_translation = true
  end
end


class User
  attr_accessor :f_name, :l_name
  attr_reader :id
  
  def self.find_by_id(id)
    arr = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      users
    WHERE
      id = ?;
    SQL
    new(arr[0])
  end
  
  def self.find_by_name(fname, lname)
    arr = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT
      *
    FROM
      users
    WHERE
      f_name = ? AND l_name = ?
    SQL
    
    new(arr[0])
  end
  
  def initialize(options)
    @f_name = options['f_name']
    @l_name = options['l_name']
    @id = options['id']
  end
  
  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end
  
  def authored_questions  
    Question.find_by_author_id(@id)
  end
  
  def authored_replies
    Reply.find_by_user_id(@id)
  end
end

class Question
  attr_accessor :title, :body
  attr_reader :id, :user_id
  
  def self.find_by_id(id)
    arr = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM 
      questions
    WHERE
      id = ?
    SQL
    
    new(arr[0])
  end
  
  def self.find_by_title(title)
    arr = QuestionsDatabase.instance.execute(<<-SQL, title)
    SELECT
      *
    FROM 
      questions
    WHERE
      title = ?
    SQL
    
    new(arr[0])
  end
  
  def self.find_by_author_id(author_id)
    arr = QuestionsDatabase.instance.execute(<<-SQL, author_id)
    SELECT
      *
    FROM 
      questions
    WHERE
      associated_author = ?
    SQL
    
    result = []
    arr.each do |question|
      result << new(question)
    end
    result
  end
  
  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end
  
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['associated_author']
  end
  
  def likers 
    QuestionLike.likers_for_question_id(@id)
  end
  
  # def num_likers
  #   QuestionLike.num_likes
  # end
  
  def followers
    QuestionFollow.followers_for_question_id(@id)
  end
  
  def author
    arr = QuestionsDatabase.instance.execute(<<-SQL, @user_id)
    SELECT
      *
    FROM
      users
    WHERE
      id = ?
    SQL
    
    User.new(arr[0])
  end
  
  def replies
    Reply.find_by_question_id(@id)
  end

end

class Reply
  attr_accessor :body
  attr_reader :id, :question_id, :parent_id, :user_id
  def self.find_by_id(id)
    arr = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM 
      replies
    WHERE
      id = ?
    SQL
    
    new(arr[0])
  end
  
  def self.find_by_question_id(question_id)
    arr = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM 
      replies
    WHERE
      question_id = ?
    SQL
    
    result = []
    arr.each do |reply|
      result << Reply.new(reply)
    end
    
    result
  end
  
  def self.find_by_user_id(user_id)
    arr = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM 
      replies
    WHERE
      user_id = ?
    SQL
    
    result = []
    arr.each do |reply|
      result << Reply.new(reply)
    end
    
    result
  end
  
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
    @body = options['body']
  end
  
  def author
    User.find_by_id(@user_id)
  end
  
  def question
    Question.find_by_id(@question_id)
  end
  
  def parent_reply
    raise 'No parent reply' unless @parent_id
    Reply.find_by_id(@parent_id)
  end
  
  def child_replies
    arr = QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT
      *
    FROM
      replies
    WHERE
      parent_id = ?
    SQL
    
    
    result = []
    arr.each do |reply|
      result << Reply.new(reply)
    end
    result
  end
end

class QuestionFollow
  def self.followers_for_question_id(question_id)
    arr = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.*
    FROM
      users
    JOIN
      question_follows
    ON
      users.id = question_follows.user_id
    JOIN
      questions
    ON
      questions.id = question_follows.question_id
    WHERE
      questions.id = ?
    SQL
    
    result = []
    arr.each do |user|
      result << User.new(user)
    end
    result
  end
  
  def self.followed_questions_for_user_id(user_id)
    arr = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      questions.*
    FROM 
      questions 
    JOIN
      question_follows
    ON
      questions.id = question_follows.question_id
    JOIN
      users
    ON
      question_follows.user_id = users.id
    WHERE
      users.id = ?
    SQL
    
    result = []
    arr.each do |question|
      result << Question.new(question)
    end
    result 
  end
  
  def self.most_followed_questions(n)
    arr = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      questions.id, COUNT(question_follows.user_id) AS num_followers
    FROM
      questions
    JOIN
      question_follows
    ON
      question_follows.question_id = questions.id
    JOIN
      users
    ON
      users.id = question_follows.user_id
    GROUP BY
      questions.id
    ORDER BY 
      num_followers DESC
    LIMIT
      ?
    SQL
    
    result = []
    arr.each do |hash|
      q = Question.find_by_id(hash['id'])
      result << q
    end
    result
  end
  
  
  
end

class QuestionLike
  
  def self.likers_for_question_id(id)
    arr = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      users.*
    FROM
      users
    JOIN
      question_likes
    ON
      users.id = question_likes.user_id
    JOIN
      questions
    ON
      question_likes.question_id = questions.id
    WHERE
      questions.id = ?
    SQL
    
    result = []
    arr.each do |user|
      result << User.new(user)
    end
    result
  end
  
  def self.liked_questions_for_user_id(user_id)
    arr = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      questions.*
    FROM
      questions
    JOIN
      question_likes
    ON
      questions.id = question_likes.question_id
    JOIN
      users
    ON
      question_likes.user_id = users.id
    WHERE
      users.id = ?
    SQL
    
    result = []
    arr.each do |question|
      result << Question.new(question)
    end
    result
  end
  
  # def self.num_likes_for_question(question_id)
  #   QuestionLike.likers_for_question_id(question_id).count
  # end
end  

if __FILE__ == $PROGRAM_NAME
  reply = Reply.find_by_id(1)
  reply.child_replies
end 
