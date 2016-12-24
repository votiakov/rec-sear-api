module Features
  module GestureHelpers

    def custom_drag_to(page, element, target, xoffset=0, yoffset=0)
      webdriver = page.driver.browser
      webdriver.mouse.down(element.native)
      webdriver.mouse.move_to(target.native, xoffset, yoffset)
      # webdriver.mouse.move_by(100, 100)
      webdriver.mouse.up
    end

  end
end