# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  comments_count  :integer
#  email           :string
#  likes_count     :integer
#  password_digest :string
#  private         :boolean
#  username        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord
  validates :email, :uniqueness => { :case_sensitive => false }
  validates :email, :presence => true
  has_secure_password

  has_many(:comments, {
    :class_name => "Comment",
    :foreign_key => "author_id"
  })

  has_many(:own_photos, {
    :class_name => "Photo",
    :foreign_key => "owner_id"
  })

  has_many(:likes, {
    :class_name => "Like",
    :foreign_key => "fan_id"
  })

  has_many(:liked_photos, {
    :through => :likes,
    :source => :photo
  })

  has_many(:commented_photos, {
    :through => :comments,
    :source => :photo
  })

  has_many(:sent_follow_requests, {
    :class_name => "FollowRequest",
    :foreign_key => "sender_id"
  })

  has_many(:received_follow_requests, {
    :class_name => "FollowRequest",
    :foreign_key => "recipient_id"
  })

  def accepted_sent_follow_requests
    return self.sent_follow_requests.where({ :status => "accepted" })
  end

  def accepted_received_follow_requests
    return self.received_follow_requests.where({ :status => "accepted" })
  end

  def followers
    array_of_follower_ids = self.accepted_received_follow_requests.pluck(:sender_id)

    return User.where({ :id => array_of_follower_ids })
  end

  def following
    array_of_leader_ids = self.accepted_sent_follow_requests.pluck(:recipient_id)

    return User.where({ :id => array_of_leader_ids })
  end

  def feed
    array_of_leader_ids = self.accepted_sent_follow_requests.pluck(:recipient_id)

    return Photo.where({ :owner_id => array_of_leader_ids })
  end

  def discover
    array_of_leader_ids = self.accepted_sent_follow_requests.pluck(:recipient_id)

    all_leader_likes = Like.where({ :fan_id => array_of_leader_ids })

    array_of_discover_photo_ids = all_leader_likes.pluck(:photo_id)

    return Photo.where({ :id => array_of_discover_photo_ids })
  end
end
