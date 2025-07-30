defmodule Server.PlugSocket do
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "This is a websocket server, please use the /websocket route to connect")
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

  def init(options) do
	Registry.register(@registry, :all_connections, self())
    {:ok, options}
  end

  def handle_in({message, [opcode: :text]}, state) do
	broadcast_message(message)
	{:reply, :ok, {:text, message}, state}
  end

  def handle_info({:broadcast, message}, state) do
	{:reply, :ok, {:text, message}, state} = handle_in({message, [opcode: :text]}, state)
	{:push, {:text, message}, state}
  end

  def terminate(:timeout, state) do
    Registry.unregister(@registry, :all_connections, self())
    {:ok, state}
  end

  defp broadcast_message(message) do
	IO.puts("IN BROADCAST")
	dbg(Registry.lookup(@registry, :all_connections))
	current_pid = self()
    for {pid, _} <- Registry.lookup(@registry, :all_connections) do
	  case pid do
		^current_pid -> IO.puts("Saw Current PID")
		_ -> send(pid, {:broadcast, message})
	  end
    end
  end
end
