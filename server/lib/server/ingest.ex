defmodule Server.Ingest do
  use GenServer
  @registry Server.Registry
  @interval 1_000

  def start_link(opts \\ []) do
	GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
	send(self(), {:make_request})
	{:ok, %{}}
  end

  def handle_info({:make_request}, state) do

	Registry.dispatch(@registry, :all_connections, fn entries ->
	  for {pid, _} <- entries, do: send(pid, {:send, "PLACEHOLDER"})
	end)

	schedule_request()
	{:noreply, state}
  end

  defp schedule_request() do
	Process.send_after(self(), {:make_request}, @interval)
  end
end
