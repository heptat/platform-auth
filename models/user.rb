require 'mongoid'

class User
  include Mongoid::Document

  field :username, type: String
  field :password, type: String
  field :uid, type: String

  validates_presence_of       :username
  validates_length_of         :username, :within => 3..20
  validates_presence_of       :password
  validates_length_of         :password, :within => 3..20
  validates_presence_of       :uid

  def to_param
    self.uid
  end

end

