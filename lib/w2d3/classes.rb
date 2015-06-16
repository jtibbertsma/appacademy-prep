class Student
  attr_reader :name, :courses

  def initialize(first_name, last_name)
    @name = "#{last_name}, #{first_name}"
    @courses = []
  end

  def enroll(course)
    