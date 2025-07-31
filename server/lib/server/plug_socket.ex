defmodule Server.PlugSocket do
  use Plug.Router

  plug Plug.Static, at: "/", from: :server, gzip: false

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/" do
	send_file(conn, 200, "priv/static/index.html")
  end


  get "/websocket" do
    conn
    |> WebSockAdapter.upgrade(SocketServer, [], timeout: 60_000)
    |> halt()
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end

defmodule SocketServer do
  @behaviour WebSock
  @registry Server.Registry
  @ingest_registry Server.IngestRegistry

  def init(options) do
	Registry.register(@registry, :websockets, self())

	Registry.dispatch(@ingest_registry, :ingest, fn entries ->
	  for {pid, _} <- entries do
		send(pid, {:new_connection, self()})
	  end
	end)
    {:ok, options}
  end

  def handle_in({message, [opcode: :text]}, state) do
    {:ok, state}
  end


  def handle_info({:send, message}, state) do
	{:push, {:text, Poison.encode!(message)}, state}
  end

  def terminate(_, state) do
    Registry.unregister(@registry, self())
    {:ok, state}
  end
end
