# Third party requirements.
require "marten"
require "marten_auth"
require "sqlite3"

# Project requirements.
require "./handlers/**"
require "./apps/auth/app"
require "./apps/blogging/app"
require "./apps/profiles/app"

# Configuration requirements.
require "../config/routes"
require "../config/settings/base"
require "../config/settings/**"
require "../config/initializers/**"
