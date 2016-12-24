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

class User < ApplicationRecord
  extend Enumerize
  include JsonSerializingModel
  include ActiveModel::Dirty

  ROLES = [:admin, :manager, :client]

  attr_accessor :anything_changed, :omit_admin_validation


  validates :email, presence: true, email: true
  validates :username, presence: true, uniqueness: true
  validates :name, :surname, presence: true

  serialize :roles, Array
  enumerize :roles, in: ROLES, i18n: false, multiple: true


  before_save :_set_anything_changed
  after_save :_expire_cache, if: :anything_changed
  before_destroy :_remove_cache_and_session_from_redis


  ransacker :unaccent_full_name, formatter: proc { |v| v.to_s.parameterize(' ') } do
    Arel.sql("unaccent(users.name || ' ' || users.surname)")
  end

  ransacker :is_manager, formatter: proc { |v| v.to_s.parameterize } do
    Arel.sql("users.roles like '%manager%'")
  end

  ransacker :is_admin, formatter: proc { |v| v.to_s.parameterize } do
    Arel.sql("users.roles like '%admin%'")
  end

  def full_name
    [name, surname].compact.join(' ')
  end

  def valid_for_authentication?
    roles.any?
  end
  private

    def _expire_cache
      $redis.expire "user_object/#{id}", 0
    end

    def _set_anything_changed
      self.anything_changed = changed? if changed? == true
      true
    end


    def _remove_cache_and_session_from_redis
      $redis.expire("user_object/#{id}", 0)
      true
    end

end
