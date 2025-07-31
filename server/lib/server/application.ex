defmodule Server.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Server.Worker.start_link(arg)
      # {Server.Worker, arg}
	  {Registry, keys: :duplicate, name: Server.Registry, partitions: System.schedulers_online()},
	  {Registry, keys: :duplicate, name: Server.IngestRegistry, partitions: System.schedulers_online()},
	  Server.Ingest,
	  {Bandit, plug: Server.PlugSocket, port: 4000, scheme: :http, }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Server.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
