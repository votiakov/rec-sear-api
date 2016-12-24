Normalizr.configure do
  default :squish, :blank

  add :digits do |value|
    value.is_a?(String) ? value.gsub(/[^0-9]/, '') : value
  end
end