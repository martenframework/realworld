module NavBarActiveable
  macro included
    class_getter nav_bar_item : String?

    extend NavBarActiveable::ClassMethods
  end

  module ClassMethods
    def nav_bar_item(item : String | Symbol)
      @@nav_bar_item = item.to_s
    end
  end

  def context
    ctx = super
    ctx ||= Marten::Template::Context.new

    ctx["nav_bar_item"] = self.class.nav_bar_item

    ctx
  end
end
