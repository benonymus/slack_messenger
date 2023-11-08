defmodule SlackMessenger.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias SlackMessenger.Repo

  alias SlackMessenger.Messages.Message

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:message, Message.changeset(%Message{}, attrs))
    |> Oban.insert(:post_job, fn %{message: message} ->
      SlackMessenger.Workers.Post.new(%{id: message.id})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{message: message}} ->
        {:ok, message}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message_slack_ts(message, "1699417072.250789")
      {:ok, %Message{}}

      iex> update_message_slack_ts(message, 11)
      {:error, %Ecto.Changeset{}}

  """
  def update_message_slack_ts(%Message{} = message, slack_ts) do
    message
    |> Message.changeset_slack_ts(%{slack_ts: slack_ts})
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Multi.new()
    |> Multi.delete(:message, message)
    |> Oban.insert(:delete_job, SlackMessenger.Workers.Delete.new(%{slack_ts: message.slack_ts}))
    |> Repo.transaction()
    |> case do
      {:ok, %{message: message}} ->
        {:ok, message}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end
end
