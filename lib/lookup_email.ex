defmodule LookupEmail do
  use GenServer
  @name LE
  require Logger

  alias LookupEmail.Helper

  ## Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: LE])
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
        |> Helper.send_smtp_command_MAIL_FROM_to_mx_server()
        |> Helper.send_smtp_command_RCPT_TO_to_mx_server(email)

        {:reply, {email, email_status}, _stats}
  end  

  def handle_info(msg, _stats) do
    IO.puts("received #{inspect(msg)}")
    {:noreply, _stats}
  end

  def terminate(reason, _stats) do
    IO.puts("Terminate GenServer : #{reason}")
    :ok
  end

  # end_defmodule
end
