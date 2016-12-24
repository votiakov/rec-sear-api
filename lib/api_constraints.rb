class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || req.headers.fetch(:accept).include?("version=#{version}")
  end

  # https://www.bignerdranch.com/blog/adding-versions-rails-api/
end
