module Jennifer
  module SQLite3
    # :nodoc:
    module Pragma
      abstract def adapter

      def pragma_collection(name, arg, klass : T.class) : Array(T) forall T
        buf = [] of T
        adapter.query("pragma #{name}(#{arg})") do |rs|
          rs.each do
            buf << T.new(rs)
          end
        end
        buf
      end
    end
  end
end