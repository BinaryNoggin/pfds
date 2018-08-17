defmodule Q.Test do
  use ExUnit.Case, async: true
  use PropCheck

  property "q is a FIFO structure" do
    forall terms <- non_empty(list(integer())) do
      subject = Q.empty()
      queued = Enum.reduce terms, subject, fn term, sub ->
        Q.snoc(sub, term)
      end
      {result, _sub} = Enum.reduce terms, {true, queued}, fn term, {result, sub} ->
        cond do
          Q.empty?(sub) ->
            {result, sub}

          true ->
            {:ok, head} = Q.head(sub)
            {:ok, tail} = Q.tail(sub)
            {result && head == term, tail}
        end
      end
      result
    end
  end

  property "q is empty only when there are no elements" do
    forall terms <- list(term()) do
      subject = Q.empty()
      queued = Enum.reduce terms, subject, fn term, sub ->
        Q.snoc(sub, term)
      end

      Q.empty?(queued) == Enum.empty?(terms)
    end
  end

  property "the tail of a non-empty q always has one less element than q" do
    forall terms <- non_empty(list(term())) do
      subject = Q.empty()
      queued = Enum.reduce terms, subject, fn term, sub ->
        Q.snoc(sub, term)
      end

      {:ok, tail} = Q.tail(queued)
      Q.length(tail) == length(terms) - 1
    end
  end
end
