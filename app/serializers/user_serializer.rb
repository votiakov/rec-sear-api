# == Schema Information
#
# Table name: users
#
#  id                       :uuid             not null, primary key
#  roles                    :string
#  name                     :string
#  surname                  :string
#  avatar                   :string
#  login                    :string
#  email                    :string           default(""), not null
#  password_digest          :string           default(""), not null
#  restore_password_token   :string
#  restore_password_sent_at :datetime
#  is_active                :boolean
#  confirmed_at             :datetime
#  created_at               :datetime
#  updated_at               :datetime
#

class UserSerializer < ResourceSerializer

  attributes  :id, :email, :name, :surname, :username, :is_active,
              :roles, :created_at, :updated_at
end
