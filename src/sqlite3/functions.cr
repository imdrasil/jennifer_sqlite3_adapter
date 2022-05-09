module Jennifer::QueryBuilder
  Function.define(:json_extract, arity: -1, comment: <<-TEXT
    Extracts and returns one or more values from the well-formed JSON

    ```
    Jennifer::Query["users"].where { json_extract(_interests, "$.likes[1]") == "reading" }
    ```
    TEXT
  ) do
    def as_sql(generator)
      "json_extract(#{operands_to_sql(generator)})"
    end
  end

  Function.define(:json_array_length, arity: -1, comment: <<-TEXT
    Returns the number of elements in the JSON array

    ```
    Jennifer::Query["users"].where { json_array_length(_interests, "$.likes") == 3 }
    Jennifer::Query["users"].where { json_array_length(_addresses_array) > 1 }
    ```
    TEXT
  ) do
    def as_sql(generator)
      "json_array_length(#{operands_to_sql(generator)})"
    end
  end
end
