class CustomIncludes
  attr_accessor :resource_key, :params, :result

  def initialize resource_key, associations
    @result       = []
    @resource_key = resource_key
    @params       = associations.dup.with_indifferent_access if associations
  end

  def execute
    @result = expand_node(resource_key) if params

    result
  end

  private

    def expand_node resource_key
      node = []

      resource = resource_key.to_s.classify.try(:constantize)

      if params.has_key?(resource_key) && resource

        array_of_associations = ( params[resource_key].is_a?(String) ? [params[resource_key]] : params[resource_key] )

        array_of_associations.each do |association|

          association = association.to_s.underscore.to_sym

          if resource_name = resource.reflect_on_association(association).try(:class_name)

            resource_key = resource_name.pluralize.underscore.to_sym

            if params.has_key?(resource_key)

              node.push({ association => expand_node(resource_key) })

            else

              node.push association

            end

          end

        end

      end

      node
    end

end