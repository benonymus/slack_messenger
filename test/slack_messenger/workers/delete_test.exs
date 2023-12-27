defmodule SlackMessenger.Workers.DeleteTest do
  use SlackMessenger.DataCase
  use Oban.Testing, repo: SlackMessenger.Repo
  use Mimic

  test "happy path works" do
    expect(Req, :post!, 1, fn _, _ ->
      %Req.Response{status: 200, body: %{"ok" => true}}
    end)

    assert :ok = perform_job(SlackMessenger.Workers.Delete, %{"slack_ts" => 500})
  end

  # add some failing tests too
end
