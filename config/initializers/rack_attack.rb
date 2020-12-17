# Rack::Attack.throttle('limit logins per email', limit: 1, period: 60) do |req|
#   if req.path == '/user_token' && req.post?
#     # Normalize the email, using the same logic as your authentication process, to
#     # protect against rate limit bypasses.
#     req.ip
#   end
# end