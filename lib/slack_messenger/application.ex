defmodule SlackMessenger.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SlackMessengerWeb.Telemetry,
      SlackMessenger.Repo,
      {DNSCluster, query: Application.get_env(:slack_messenger, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SlackMessenger.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SlackMessenger.Finch},
      # Start a worker by calling: SlackMessenger.Worker.start_link(arg)
      # {SlackMessenger.Worker, arg},
      # Start to serve requests, typically the last entry
      SlackMessengerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SlackMessenger.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SlackMessengerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
