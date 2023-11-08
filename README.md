# SlackMessenger

To start your Phoenix server:

  * you need a `.env` file based on the specification laid out in `.env.example` (I sent you my file with the credentials)
  * `docker compose run --name slack_messenger_web_dev --rm --service-ports web` - this will pull the images for you and let you in the container
  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

  * test can be run by `MIX_ENV=test mix test`

  * Here is your invite to the Slack workspace: `https://join.slack.com/t/slack-ubv9217/shared_invite/zt-26mlgeeib-4xVycmKAFuzbbPDWcAb~~w`
  * I used the `#sending-messages` channel.

  * the api is accessible on `/api` routes with the `x-api-key` header value set to `test_api_key`
