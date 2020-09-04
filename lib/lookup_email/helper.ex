defmodule LookupEmail.Helper do

  def get_mx_server_of_this_email(email) do
    # fetch domain part of the email
    mx = String.split(email, "@") |> Enum.at(1)
    # extract MX server part, from nslookup response (eg : nslook -q=mx gmail.com)
    {response, code} = System.cmd("nslookup", ["-q=mx", "#{mx}"])

    # 0 = mx exist, 1 = mx not exist
    case {response, code} do
      {response, 0} ->
        [response]
        |> Enum.at(0)
        |> String.split("\n")
        |> Enum.at(4)
        |> String.split(" ")
        |> Enum.at(4)
        |> String.replace_trailing(".", "")
        |> URI.parse
        |> Map.fetch!(:path)

      {response, 1} ->
        exit "Error nslookup: #{response}"
    end

  end

  def open_connection_to_mx_server(email_mx_server) do

    opts = [:binary, active: false]
    telnet_port = 25

    case :gen_tcp.connect('#{email_mx_server}', telnet_port, opts) do
      {:ok, socket} ->
          {:ok, msg} = :gen_tcp.recv(socket, 0)
          IO.puts "open_connection_to_mx_server: #{msg}"
          socket
      {:error, reason} ->
          exit "Can not connect to MX-Server: #{reason}"
      end

  end

  def send_smtp_command_HELO_HI_to_mx_server(socket) do

    :ok = :gen_tcp.send(socket, "HELO HI \r \n")
    tcp_recv_respons = :gen_tcp.recv(socket, 0)

    case  tcp_recv_respons do
        {:ok, msg} ->
          IO.puts "send_smtp_command_HELO_HI_to_mx_server : #{inspect (msg)}"
          socket
        other_msg ->
          exit "send_smtp_command_HELO_HI_to_mx_server: #{inspect (other_msg)}"
    end

  end

  def send_smtp_command_MAIL_FROM_to_mx_server(socket,email) do

    :ok = :gen_tcp.send(socket, "MAIL FROM:<#{email}> \r \n")
    tcp_recv_respons = :gen_tcp.recv(socket, 0)

    case  tcp_recv_respons do
        {:ok, msg} ->
          IO.puts "send_smtp_command_MAIL_FROM_to_mx_server : #{inspect (msg)}"
          socket
        other_msg ->
          exit "send_smtp_command_MAIL_FROM_to_mx_server: #{inspect (other_msg)}"
    end

  end

  def send_smtp_command_RCPT_TO_to_mx_server(socket, email) do

    :ok = :gen_tcp.send(socket, "RCPT TO:<#{email}> \r \n")

    # fetch 4th response (RCPT TO), & will use it to verify the email
    {:ok, msg} = :gen_tcp.recv(socket, 0)

    rest_mesg_length = byte_size(msg) - 3
    <<response_code::binary-size(3), _rest::binary-size(rest_mesg_length)>> = msg

    case response_code do
      "250" ->
        IO.puts("send_smtp_command_RCPT_TO_to_mx_server : #{msg}")
        :exist

      _other_code ->
        IO.puts("send_smtp_command_RCPT_TO_to_mx_server : #{msg}")
        :not_exist
    end

  end

end
