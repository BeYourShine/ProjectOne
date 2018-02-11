class Relationship < ApplicationRecord
  belongs_to :followed, inverse_of: :active_relationships, class_name: "User"
  belongs_to :follower, inverse_of: :passive_relationships, class_name: "User"
end
