module NavBarActiveable
  macro included
    class_getter nav_bar_item : String?

    extend NavBarActiveable::ClassMethods

    before_render :add_nav_bar_item_to_context
  end

  module ClassMethods
    def nav_bar_item(item : String | Symbol)
      @@nav_bar_item = item.to_s
    end
  end

  private def add_nav_bar_item_to_context
    context[:nav_bar_item] = self.class.nav_bar_item
  end
end
