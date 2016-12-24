class CustomArraySerializer < ActiveModel::Serializer::CollectionSerializer
  # self.root = 'contents'

  def convert_keys(hash)
    hash.inject({}) { |h, (k, v)| h[apply_conversion(k)] = v; h }
  end

  def apply_conversion(key)
    if key
      return key.to_s.camelize(:lower)
    end
    key
  end

  def as_json(*args)
    hash = super(*args)
    hash["total_elements"] = if @object.is_a? (ActiveRecord::Relation)
      @object = @object.limit(nil).offset(nil)

      if @object.group_values.any?
        # cannot use query.distict.count() because of a bug that duplicates DISTINCTS and resolves to DISTINCT COUNT(DISTINCT ...) we do:
        @object.except(:select, :group, :distinct).count("#{@object.group_values.join(', ')}")
      else
        @object.count
      end

    else
      @object.count
    end
    convert_keys(hash)
  end

end