class ErrorsJSON

  def self.serialize object

    json = {}

    if object && object.errors && (messages = object.errors.messages.select { |key, val| !key.to_s.match(/\./) }).any?
      json[:errors] = messages
    end

    if object.class.respond_to?(:nested_attributes_options)
      json.merge!(object.class.reflect_on_all_associations.inject({}) { |mem, assoc|
        # next mem unless object.class.nested_attributes_options.has_key?(assoc.name) && assoc.validate? && object.send(assoc.name).loaded?
        next mem unless object.class.nested_attributes_options.has_key?(assoc.name) && assoc.validate?
        target = object.send(assoc.name)

        if assoc.collection?
          mem[assoc.name] = []

          target.each do |child|
            mem[assoc.name] << serialize(child)
          end
        else
          mem[assoc.name] = serialize(target)
        end

        mem
      })
    end

    json
  end

end
