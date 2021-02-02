# frozen_string_literal: true
class Footer < ActiveAdmin::Component
  def build(_namespace)
    super id: "footer"

    div id: "footer_content" do
      render 'admin/parts/footer'
    end
  end
end
