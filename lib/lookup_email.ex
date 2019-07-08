defmodule LookupEmail do
  use GenServer
  @name LE
  require Logger

  ## Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: LE])
  end

  def check_email(email) do
    GenServer.call(@name, {:email, email})
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
      |> get_mx_server
      |> look_up_into_mx

    case email_status do
      {:ok, status_valid} ->
        ## "Email #{email}, is VALID => #{status_valid}"
        Logger.info("Email does exist")
        {:reply, "Email #{email} does exist", _stats}

      {:nok, status_invalid} ->
        ## "Email #{email} is NOT valid => #{status_invalid}"
        Logger.info("Email #{email} doesn't exist -->  #{status_invalid}")
        {:reply, "Email #{email} doesn't exist", _stats}
    end
  end

  def handle_info(msg, _stats) do
    Logger.info("received #{inspect(msg)}")
    {:noreply, _stats}
  end

  def terminate(reason, _stats) do
    Logger.info("Terminate GenServer : #{reason}")
    :ok
  end

  ## Helper Functions
  defp get_mx_server(email) do
    # fetch domain part of the email
    mx = String.split(email, "@") |> Enum.at(1)
    # extract MX server part, from nslookup response (eg : nslook -q=mx gmail.com)
    try do
      mx_server =
        System.cmd("nslookup", ["-q=mx", "#{mx}"])
        |> Tuple.to_list()
        |> Enum.at(0)
        |> String.split("\n")
        |> Enum.at(4)
        |> String.split(" ")
        |> Enum.at(4)
        |> String.replace_trailing(".", "")

      {:ok, mx_server, email}
    rescue
      _ ->
        Logger.info("Invalid domain or MX (SMTP server) does not exist")
        {:nok, :invalid_domain, email}
    end
  end

  @doc """
     @doc attribute is always discarded for private functions/macros/types
     ...if you need to look at the code to read it (the doc), then it is not documentation.{JoseValim} -> funny :D

    *look_up_into_mx* will communicate with smtp server to verify the email
  """

  defp look_up_into_mx(status_mx_server) do
    case status_mx_server do
      {:ok, mx_server, email} ->
        Logger.info("Checking email #{email}...")

        opts = [:binary, active: false]
        telnet_port = 25

        case :gen_tcp.connect('#{mx_server}', telnet_port, opts) do
          {:ok, socket} ->
            Logger.info("Connected to SMTP (#{mx_server}) at port #{telnet_port}...")
            # fetch 1st response (telnet), ignore
            {:ok, _msg} = :gen_tcp.recv(socket, 0)

            # Start SMTP Protocol Sequence :
            # - HELO HI
            # - MAIL FROM:<sender@sender.com>
            # - RCPT TO:<receiver@receiver.com>

            Logger.info("Send SMTP command : helo hi")
            :ok = :gen_tcp.send(socket, "HELO HI \r \n")
            # fetch 2nd response (HELO HI), ignore
            {:ok, _msg} = :gen_tcp.recv(socket, 0)

            Logger.info("Send SMTP command : mail from")
            :ok = :gen_tcp.send(socket, "MAIL FROM:<dewa19@gmail.com> \r \n")
            # fetch 3rd response (MAIL FROM), ignore
            {:ok, _msg} = :gen_tcp.recv(socket, 0)

            Logger.info("Send SMTP command : rcpt to")
            :ok = :gen_tcp.send(socket, "RCPT TO:<#{email}> \r \n")
            # fetch 4th response (RCPT TO), & will use it to verify the email
            {:ok, msg} = :gen_tcp.recv(socket, 0)

            rest_mesg_length = byte_size(msg) - 3
            <<response_code::binary-size(3), _rest::binary-size(rest_mesg_length)>> = msg

            case response_code do
              "250" ->
                Logger.info("Responses :\r\n#{msg} Response code = #{response_code}")
                {:ok, "Response code : exist (#{response_code})"}

              _ ->
                Logger.info("Responses :\r\n#{msg} Response code = #{response_code}")
                {:nok, "Response code : not exist (#{response_code})"}
            end

          {:error, reason} ->
            Logger.info("Can not connect to MX, reason *#{reason}*")
            {:nok, "Can't connect to MX-Server"}
        end

      {:nok, :invalid_domain, email} ->
        {:nok, "Invalid MX-Server domain"}
    end
  end

  # end_defmodule
end
