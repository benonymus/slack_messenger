defmodule SlackMessenger.Workers.PostTest do
  use SlackMessenger.DataCase
  use Oban.Testing, repo: SlackMessenger.Repo
  use Mimic

  import SlackMessenger.MessagesFixtures

  test "happy path works" do
    slack_ts = "50000"

    expect(Req, :post!, 1, fn _, _ ->
      %Req.Response{status: 200, body: %{"ok" => true, "ts" => slack_ts}}
    end)

    Oban.Testing.with_testing_mode(:inline, fn ->
      message = message_fixture()

      updated_message = SlackMessenger.Messages.get_message!(message.id)

      assert updated_message.slack_ts == slack_ts
    end)
  end

  # add some failing tests too
end
