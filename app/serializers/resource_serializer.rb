class ResourceSerializer < ActiveModel::Serializer

  def resource_name
    object.class.name
  end

  def routes
    Rails.application.routes.url_helpers
  end

  def filter(keys)
    keys = add_lazy_loaded_keys(keys)
    # keys = remove_unauthorized_keys(keys)
    keys
  end

  class << self

    def inherited(base)
      super(base)
      base._lazy_loaded_attributes = []
    end

    attr_accessor :_lazy_loaded_attributes

    def lazy_loaded_attributes(*fields)
      @_lazy_loaded_attributes.concat fields
    end

  end

  def filter(keys)
    keys = add_lazy_loaded_keys(keys)
    # keys = remove_unauthorized_keys(keys)
    keys
  end

  private

    def add_lazy_loaded_keys keys
      self.class._lazy_loaded_attributes.each do |key|
        keys.delete(key) unless fields.include?(key)
      end
      keys
    end

    def fields
      @fields ||= if scope && scope[:fields] && scope[:fields][self.class.root_name.pluralize]
        scope[:fields][self.class.root_name.pluralize].dup.map(&:to_sym)
      else
        {}
      end
    end

    def current_user
      scope[:current_user] if scope
    end

end