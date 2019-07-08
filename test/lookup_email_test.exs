defmodule LookupEmailTest do
  use ExUnit.Case
  doctest LookupEmail

  describe "test of emails verification" do
    test "a valid email" do
      LookupEmail.start_link()
      assert LookupEmail.check_email("dewa19@gmail.com") == "Email dewa19@gmail.com does exist"
    end

    test "an invalid email" do
      LookupEmail.start_link()

      assert LookupEmail.check_email("dewwwaaaaaaa@yahoo.com") ==
               "Email dewwwaaaaaaa@yahoo.com doesn't exist"
    end
  end
end
