class Relationship < ActiveRecord::Base
	attr_accessible :followed
	
	belongs_to :follower, class_name: 'User'
	belongs_to :followed, class_name: 'User' 

	validates :follower, presence: true
	validates :followed, presence: true

end
