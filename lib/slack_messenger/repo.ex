defmodule SlackMessenger.Repo do
  use Ecto.Repo,
    otp_app: :slack_messenger,
    adapter: Ecto.Adapters.Postgres
end
