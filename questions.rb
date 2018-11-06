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
end

class Replies
  
end