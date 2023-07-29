Marten.configure :development do |config|
  config.debug = true
  config.host = "127.0.0.1"
  config.port = 8000

  # Print sent emails to the standard output in development.
  # https://martenframework.com/docs/development/reference/settings#emailing-settings
  config.emailing.backend = Marten::Emailing::Backend::Development.new(print_emails: true)

  config.assets.dirs = [
    Path["src/assets/build_dev"].expand,
    Path["src/assets"].expand,
  ]

  webpack_sock = Socket.tcp(Socket::Family::INET)
  begin
    webpack_sock.bind("localhost", 8080)
  rescue Socket::BindError
    config.assets.url = "http://localhost:8080/assets/"
  end
  webpack_sock.close
end
