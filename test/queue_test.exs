defmodule QueueTest do
  use ExUnit.Case
  doctest Queue
  use PropCheck
  use PropCheck.StateM.DSL

  property "Queue", [:verbose] do
    forall cmds <- commands(__MODULE__) do
      execution = run_commands(cmds)

      (execution.result == :ok)
      |> when_fail(
        IO.puts("""
        History: #{inspect(execution.history, pretty: true)}
        State: #{inspect(execution.state, pretty: true)}
        Result: #{inspect(execution.result, pretty: true)}
        Commands Run: #{length(execution.history)}
        """)
      )
      |> aggregate(command_names(cmds))
    end
  end

  def initial_state, do: {Queue.empty(), []}

  def weight(_), do: %{empty?: 1, snoc: 5, head: 3, tail: 2}

  defcommand :empty? do
    def impl(queue), do: Queue.empty?(queue)
    def args({queue, _}), do: [queue]
    def post({_, test_state}, _, result), do: Enum.empty?(test_state) == result
  end

  defcommand :snoc do
    def impl(queue, x), do: Queue.snoc(queue, x)
    def args({queue, _}), do: [queue, any()]
    def next({queue, test_state}, [queue, x], new_queue) do
      {new_queue, [x | test_state]}
    end
  end

  defcommand :head do
    def impl(queue), do: Queue.head(queue)
    def args({queue, _}), do: [queue]
    def post({_, []}, _, {:error, :empty}), do: true
    def post({_, test_state}, _, {:ok, head}), do: head == (test_state |> Enum.reverse() |> hd())
  end

  defcommand :tail do
    def impl(queue), do: Queue.tail(queue)
    def args({queue, _}), do: [queue]
    def post({_, []}, _, {:error, :empty}), do: true
    def post({_, test_state}, _, {:ok, {f, r}}), do: f ++ Enum.reverse(r) == (test_state |> Enum.reverse() |> tl())
  end
end
