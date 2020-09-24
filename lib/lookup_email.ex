defmodule LookupEmail do
  use Application
  require Logger

  def start(_type, _arg) do
    Logger.info("#{__MODULE__}: Application start...")
    LookupEmail.Supervisor.start_link([])
  end

end
