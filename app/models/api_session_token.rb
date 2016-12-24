class ApiSessionToken
  extend  ActiveModel::Naming
  include ActiveModel::Serialization
  include JsonSerializingModel

  TTL = ENV['SESSION_TTL'].to_i.minutes

  def initialize(existing_token=nil)
    @token = existing_token if existing_token.present?

    unless expired?
      self.last_seen = Time.now
    end
  end

  def token
    @token ||= MicroToken.generate ENV['API_SECRET_LENGTH'].to_i
  end

  def ttl
    return 0 if deleted?
    return TTL unless last_seen
    elapsed   = Time.now - last_seen
    remaining = (TTL - elapsed).floor
    remaining > 0 ? remaining : 0
  end

  def bump_ttl
    self.last_seen = Time.now
  end

  def last_seen
    @last_seen ||= _retrieve_last_seen
  end

  def last_seen=(as_at)
    _set_with_expire(_last_seen_key, as_at.iso8601)
    @last_seen = as_at
  end

  def user
    return if !valid?
    @user ||= _retrieve_user
  end

  def user=(user)
    _set_with_expire(_user_id_key, "#{user.class.name}:#{user.id}")
    @deleted = nil
    deleted?
    @user = user
  end

  def expired?
    ttl < 1
  end

  def valid?
    # validity = !expired? && !deleted?
    validity = !deleted?
    bump_ttl if validity
    validity
  end

  def deleted?
    return @deleted unless @deleted.nil?

    id_key_presence = $redis[_user_id_key].present?
    model_presence = false
    if id_key_presence
      user_name, user_id = $redis[_user_id_key].split(':')
      model_presence = user_name.constantize.where(id: user_id).any?
    end

    @deleted = !id_key_presence || !model_presence
  end

  def delete!
    $redis.del(_last_seen_key, _user_id_key)
  end

  private

  def _set_with_expire(key,val)
    $redis.set(key, val)
    # $redis.expire(key, TTL)
  end

  def _retrieve_last_seen
    ls = $redis[_last_seen_key]
    ls && Time.parse(ls)
  end

  def _retrieve_user
    user_name, user_id = $redis[_user_id_key].split(':')

    if user_id && user_name
      user_name.constantize.where(id: user_id).first
    end
  end

  def _last_seen_key
    "session_token/#{token}/last_seen"
  end

  def _user_id_key
    "session_token/#{token}/user_id"
  end

end