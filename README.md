# LookupEmail

**LookEmail** is a GenServer-based SMTP email look-up application. The GenServer process run on its own without Supervisor.

The objective of this project is to validate an email address from the side of SMTP server, without really sending a message to given email. If -by sending a series of SMTP commands- an email is acknowledged by its SMTP server, then it is an "valid" email.

In SMTP protocol, there is a special command to establish a recipient of the message, ie: RCPT TO:\<email@example.com\>. If the response code of that command is like "250 OK" then the specified email is a valid one. Otherwise, it might be an invalid email (for any reason).

With that mechanism, we wan make an "educated guess" about the status of an email (exist or not exist).

## Installing

After clone this application, you can start right away. Don't forget to start GenServer first by calling ```LookupEmail.start_link()```.

```
  <your_machine/lookup_email>$ iex -S mix
  Erlang/OTP 23 [erts-11.0.2] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

  Compiling 1 file (.ex)
  Interactive Elixir (1.10.3) - press Ctrl+C to exit (type h() ENTER for help)

  iex(1)> LookupEmail.start_link()
  {:ok, #PID<0.143.0>}
  iex(2)> LookupEmail.check_email("inquiry@sky-energy.co.id")
  open_connection_to_mx_server: 220-mail.sky-energy.co.id ESMTP Postfix

  send_smtp_command_HELO_HI_to_mx_server : "220 mail.sky-energy.co.id ESMTP Postfix\r\n"
  send_smtp_command_MAIL_FROM_to_mx_server : "250 mail.sky-energy.co.id\r\n"
  send_smtp_command_RCPT_TO_to_mx_server : 250 2.1.0 Ok

  {"inquiry@sky-energy.co.id", :exist}
  iex(3)> LookupEmail.stop()
  Terminate GenServer : normal
  :ok
  iex(4)>
  ```
That's it! The final result would be tuple of a pair of email and its status.

**Note :**

When application can't verify the domain name of an email, it just throws an "exit" signal, quit the application, and appear as an error. This should be a task for Supervisor to trap this kind of termination signal (for any kind reason).
