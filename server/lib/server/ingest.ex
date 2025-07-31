defmodule Server.Ingest do
  use GenServer
  @registry Server.Registry
  @ingest_registry Server.IngestRegistry
  @interval 60_000
  @service_root "https://services9.arcgis.com/RHVPKKiFTONKtxq3/arcgis/rest/services/USA_Wildfires_v1/FeatureServer/"

  @get_all_incidents_and_perimeters @service_root <> ~s(query?layerDefs={"0": "1 = 1", "1": "1 = 1"}&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&outSR=&datumTransformation=&applyVCSProjection=false&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&returnIdsOnly=false&returnCountOnly=false&returnDistinctValues=false&returnZ=false&returnM=false&sqlFormat=none&f=pjson&token=)

  def start_link(opts) do
	GenServer.start_link(__MODULE__, %{}, opts)
  end

  def init(opts	\\ %{}) do
	Registry.register(@ingest_registry, :ingest, self())
	send(self(), {:make_request})
	{:ok, opts}
  end

  def handle_info({:new_connection, target_pid}, state) do
	if Map.has_key?(state, :output) do
	  send(target_pid, {:send, Map.fetch!(state, :output)})
	else
	  send(self(), {:make_request})
	end

	{:noreply, state}
  end

  def handle_info({:make_request}, state) do
	schedule_request()

	%HTTPoison.Response{body: body} = HTTPoison.get!(@get_all_incidents_and_perimeters)
	{:ok, json} = Poison.decode(body)

	[incidentsList, perimeterList] = json["layers"]

	incidents = for n <- incidentsList["features"] do
	  Map.new([
		{ :type, "Feature" },
		{ :geometry, Map.new([
			{:type, "Point"},
			{:coordinates, [n["geometry"]["x"], n["geometry"]["y"]]}
		  ])
		},
		{ :properties, Map.new([
			{:name, n["attributes"]["IncidentName"]}
		  ])
		}
	  ])
	end

	perimeters = for n <- perimeterList["features"] do
	  Map.new([
		{:type, "Feature"},
		{ :properties, Map.new([
			{:name, n["attributes"]["IncidentName"]}
		  ])
		},
		{:geometry, Map.new([
			{:type, "Polygon"},
			{:coordinates, Enum.at(n["geometry"]["rings"], 0)}
		  ])
		}
	  ])
	end

	output = Map.new([
	  {:incidents, incidents},
	  {:perimeters, perimeters}
	])

	Registry.dispatch(@registry, :websockets, fn entries ->
	  for {pid, _} <- entries, do: send(pid, {:send, output})
	end)

	{:noreply, Map.put(state, :output, output)}
  end

  defp schedule_request() do
	Process.send_after(self(), {:make_request}, @interval)
  end
end
