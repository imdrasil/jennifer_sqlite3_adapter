module FeatureHelper
  macro with_json_support
    {% if (env("SQLITE_VERSION") || "0000000") > "3379999" %}
      {{ yield }}
    {% end %}
  end
end
