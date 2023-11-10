defmodule Prokeep.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ProkeepWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:prokeep, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Prokeep.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Prokeep.Finch},
      # Start a worker by calling: Prokeep.Worker.start_link(arg)
      # {Prokeep.Worker, arg},
      # Start to serve requests, typically the last entry
      ProkeepWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Prokeep.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ProkeepWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
