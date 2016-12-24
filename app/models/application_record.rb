class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  extend ActiveSupport::Concern


  def self.filter(params = {}, options = {})
    params = {} if params.nil?
    options = {} if options.nil?

    limit = params[:limit].present? ? (params[:limit].to_i < 0 ? 0 : params[:limit].to_i > 1000 ? 1000 : params[:limit]) : ENV['DEFAULT_LIMIT'].to_i
    filter_base(params, options).limit(limit)
  end

  def self.filter_unsafe(params = {}, options = {})
    params = {} if params.nil?
    options = {} if options.nil?

    result = filter_base(params, options)
    result = result.limit(params[:limit] || ENV['DEFAULT_LIMIT'].to_i) unless params[:limit] && params[:limit] == 'all'
    result
  end

  private

    def self.filter_base(params = {}, options = {})
      base = ransack(prepare_params(params)).result(distinct: params[:distinct])
      base = base.preload(CustomIncludes.new(self.name.underscore.pluralize.to_sym, params[:fields]).execute)
      base = base.offset(params[:offset]) if params[:offset]
      base
    end

    def self.prepare_params(params)
      params = params.except(:controller, :action, :format)
      params["sorts"] = Array.wrap(params["sorts"]).map(&:underscore) if params["sorts"]
      params
    end

end
