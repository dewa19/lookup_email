defmodule LookupEmailTest do
  use ExUnit.Case
  doctest LookupEmail

  describe "test of emails verification" do
    test "a valid email" do
      LookupEmail.start_link()
      actual = LookupEmail.check_email("inquiry@sky-energy.co.id")
      expected = {"inquiry@sky-energy.co.id", :exist}
      assert actual == expected
    end

    test "an invalid email" do
      LookupEmail.start_link()

      actual = LookupEmail.check_email("qwqwqw213@gmail.com")
      expected = {"qwqwqw213@gmail.com", :not_exist}
      assert actual == expected
    end
  end
end
