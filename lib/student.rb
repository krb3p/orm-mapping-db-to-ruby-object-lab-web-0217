require 'pry'

class Student
  attr_accessor :id, :name, :grade
  #
  # def initialize (id=nil, name, grade)
  #   @name = name
  #   @grade = grade
  #   @id = id
  # end
  #why is this needed?

  def self.new_from_db(row)
    student = self.new
    student.id = row[0]
    student.name =  row[1]
    student.grade = row[2]
    student
  end

  def self.all
    sql = <<-SQL
    SELECT * FROM students
    SQL
    x = DB[:conn].execute(sql)

    x.map do |row|
      self.new_from_db(row)
      # confirming that this self refers to an instance
     end
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students
    WHERE name = ?
    LIMIT 1
    SQL
    name_data = DB[:conn].execute(sql, name)

    name_data.map do |row|
      # why is this needed when we've only returned one row?
      self.new_from_db(row)
    end.first
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def self.count_all_students_in_grade_9
    sql = <<-SQL
    SELECT COUNT(name)
    FROM students
    WHERE grade = 9
    SQL
    DB[:conn].execute(sql)
  end

  def self.students_below_12th_grade
    sql = <<-SQL
    SELECT COUNT(name)
    FROM students
    WHERE grade <= 11
    SQL
    DB[:conn].execute(sql)
  end

  def self.first_x_students_in_grade_10 (num)
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE grade = 10
    LIMIT ?
    SQL
    DB[:conn].execute(sql, num)
  end

  def self.first_student_in_grade_10
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE grade = ?
    ORDER BY students.id ASC
    LIMIT 1
    SQL
    first_student_10_row = DB[:conn].execute(sql, 10)

    student = Student.new
    student.id = first_student_10_row[0][0]
    student.name = first_student_10_row[0][1]
    student.grade = first_student_10_row[0][2]
    student
  end

  def self.all_students_in_grade_x(x)
    sql = <<-SQL
    SELECT *
    FROM students
    GROUP BY grade
    HAVING grade = ?
    SQL
    student_array = (DB[:conn].execute(sql, x))[0]
  end

end
