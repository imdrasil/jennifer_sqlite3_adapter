module Jennifer
  module SQLite3
    # :nodoc:
    class Index
      include Pragma

      # :nodoc:
      class Meta
        getter column : String?

        @desc_order : Bool

        def initialize(rs)
          column_rank = rs.read(Int32)
          column_index = rs.read(Int32)
          @column = rs.read(String?)
          @desc_order = rs.read(Bool)
          collating_seq_name = rs.read(String)
          key_column = rs.read(Bool)
        end

        def column!
          column.not_nil!
        end

        def desc?
          @desc_order
        end

        def asc?
          !desc?
        end

        def default?
          column.nil?
        end
      end

      getter type : Symbol?, name : String, source : String, partial : Bool

      @meta : Array(Meta)?

      def initialize(rs)
        id = rs.read(Int32)
        @name = rs.read(String)
        @type = :unique if rs.read(Bool)
        @source = rs.read(String)
        @partial = rs.read(Bool)
      end

      def meta
        @meta ||= pragma_collection("index_xinfo", name, Meta)
      end

      def columns
        meta.reject(&.default?)
      end

      def primary?
        @source == "pk"
      end

      def secondary?
        !primary?
      end

      private def adapter
        Jennifer::Adapter.default_adapter
      end
    end
  end
end
