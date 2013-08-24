class Micropost < ActiveRecord::Base
  	belongs_to :user
  	attr_accessible :content
	validates :user, presence: true
	validates :content, presence: true, length: { maximum: 140 }

	default_scope -> { order('created_at DESC') }

	def self.from_users_followed_by(user)
		followed_user_ids = "select followed_id from Relationships where follower_id=#{user.id}"
		Micropost.where("user_id in (#{followed_user_ids}) or user_id = ?", user)
	end

end
