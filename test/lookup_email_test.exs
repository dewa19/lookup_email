defmodule LookupEmailTest do
  use ExUnit.Case
  doctest LookupEmail

  describe "test of emails verification" do
    # run specific test
    #mix test test/lookup_email_test.exs --only line:10 (by line number)
    #mix test test/lookup_email_test.exs --only valid_email (by tag name)

    @tag :valid_email
    test "a valid email" do
      LookupEmail.Worker.start_link()
      actual = LookupEmail.Worker.check_email("inquiry@sky-energy.co.id")
      expected = {"inquiry@sky-energy.co.id", :exist}
      assert actual == expected
    end

    @tag :invalid_email
    test "an invalid email" do
      LookupEmail.Worker.start_link()

      actual = LookupEmail.Worker.check_email("qwqwqw213@gmail.com")
      expected = {"qwqwqw213@gmail.com", :not_exist}
      assert actual == expected
    end
  end
end
