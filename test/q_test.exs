defmodule Q.Test do
  use ExUnit.Case, async: true
  use PropCheck

  property "q is a FIFO structure" do
    forall terms <- non_empty(list(integer())) do
      with_queued_items(terms, fn queued ->
        {result, _sub} =
          Enum.reduce(terms, {true, queued}, fn term, {result, sub} ->
            {:ok, head} = Q.head(sub)
            {:ok, tail} = Q.tail(sub)
            {result && head == term, tail}
          end)

        result
      end)
    end
  end

  property "q is empty only when there are no elements" do
    forall terms <- list(term()) do
      with_queued_items(terms, fn queued ->
        Q.empty?(queued) == Enum.empty?(terms)
      end)
    end
  end

  property "the tail of a non-empty q always has one less element than q" do
    forall terms <- non_empty(list(term())) do
      with_queued_items(terms, fn queued ->
        {:ok, tail} = Q.tail(queued)
        Q.length(tail) == length(terms) - 1
      end)
    end
  end

  property "the length of a q is the same as the number of terms in the queue" do
    forall terms <- non_empty(list(term())) do
      with_queued_items(terms, fn queued ->
        Q.length(queued) == length(terms)
      end)
    end
  end

  def with_queued_items(items, process) do
    subject = Q.empty()

    queued =
      Enum.reduce(items, subject, fn term, sub ->
        Q.snoc(sub, term)
      end)

    process.(queued)
  end
end
