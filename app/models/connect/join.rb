module Connect
  module Join
    extend ActiveSupport::Concern

    module ClassMethods
      def orphan
        joins do
          my{reflect_on_all_associations}.map { |assoc| __send__(assoc.name).outer }
        end.where do
          my{reflect_on_all_associations}.map{ |assoc| __send__(assoc.name).id == nil}.reduce(&:&)
        end
      end
    end
  end
end