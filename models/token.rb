require 'mongoid'

class Token
  include Mongoid::Document

  field :value, type: String
  field :uid, type: String
  field :app, type: String
  field :created_at, type: DateTime

  validates_presence_of       :value
  validates_presence_of       :uid
  validates_presence_of       :app
  validates_presence_of       :created_at

  def to_param
    self.value
  end

end

