require 'singleton'
require 'sqlite3'

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
  
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['associated_author']
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
  
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
    @body = options['body']
  end
  
end
