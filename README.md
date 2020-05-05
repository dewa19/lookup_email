# LookupEmail

This is GenServer version of *EmailLookUp* application that previously uploaded.

Also, this project is part of my journey to understanding Elixir.
The objective of this mini project is to validate an email address from the side of SMTP server (without actually sending an email). If an email is acknowledged by its SMTP server, then it is an "valid" email.

In SMTP protocol, there is a special command/syntax as a part of sending an email, ie: RCPT TO:\<email@example.com\>.
If a response code of that command is like "250 OK" then the specified email is a valid one. Otherwise, it might be an invalid email (for any reason).

With that mechanism, we wan make an "educated guest" about the status of an email (exist or not). 
