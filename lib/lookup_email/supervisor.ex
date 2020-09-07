defmodule LookupEmail.Supervisor do
  @moduledoc """
    LookupEmail.Supervisor supervise LookupEmail.Worker,
    ONE Supervisor *ONLY* supervise ONE Worker.
  """
  use Supervisor
  require Logger

  ## Client API (start_link, stop)

  @doc """
    Start the Supervisor
  """
  def start_link() do
    Logger.info("#{__MODULE__}: Supervisor start_link()")
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def stop do
    GenServer.cast(__MODULE__, :stop)
  end

  ## Server API/Callbacks
  def init(_initial_data) do
    children = [
      worker(LookupEmail.Worker, [], restart: :transient)
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

  def handle_cast(:stop, _stats) do
    {:stop, :normal, _stats}
  end

end
