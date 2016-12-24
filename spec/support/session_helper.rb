module Features
  module SessionHelpers

    def sign_in some_user
      session_token       = ApiSessionToken.new
      session_token.user  = some_user
      Thread.current[:current_event_id] = some_user.current_event_id

      visit '/'
      page.execute_script "localStorage.setItem('token', '#{session_token.token}')"
    end

  end
end