defmodule LookupEmail.Worker do
  @moduledoc """
    LookupEmail.Worker
    This module contain function that do the real work, ie: LookupEmail.Worker.check_email
  """

  use GenServer
  @name __MODULE__

  alias LookupEmail.Helper, as: Helper
  require Logger

  ## Client API (start_link, check_email, stop)
  def start_link(opts \\ []) do
    Logger.info("#{__MODULE__}: Worker start_link()")

    GenServer.start_link(__MODULE__, :ok, opts ++ [name: @name])
  end

  def check_email(email) do
    GenServer.call(@name, {:email, email}, :infinity)
  end

  def stop do
    GenServer.cast(@name, :stop)
  end

  ## Server API/Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast(:stop, _stats) do
    {:stop, :normal, _stats}
  end

  def handle_call({:email, email}, _from, _stats) do
    email_status =
        email
        |> Helper.get_mx_server_of_this_email()
        |> Helper.open_connection_to_mx_server()
        |> Helper.send_smtp_command_HELO_HI_to_mx_server()
        |> Helper.send_smtp_command_MAIL_FROM_to_mx_server(email)
        |> Helper.send_smtp_command_RCPT_TO_to_mx_server(email)

    Helper.write_result_log("#{email} | #{email_status}")

    {:reply, {email, email_status}, _stats}
  end

  def handle_info(msg, state) do
    IO.puts("[handle_info] Worker Terminate GenServer signal : #{msg}")

    {:noreply, state}
  end

  def terminate(reason, _stats) do
    IO.puts("Terminate GenServer : #{inspect(reason)}")
    :ok
  end

end
