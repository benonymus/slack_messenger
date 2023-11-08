defmodule SlackMessenger.MessagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SlackMessenger.Messages` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        body: "some body",
        subject: "some subject"
      })
      |> SlackMessenger.Messages.create_message()

    message
  end
end
