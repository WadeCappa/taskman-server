defmodule Taskman.Test.Comments do
  use ExUnit.Case

  @user_id 100
  @test_task %Taskman.Tasks{
    name: "test task",
    cost: 10,
    priority: 10,
    description: "test description",
    time_posted: 10,
    status: 0,
    deadline: 100,
    user_id: @user_id
  }

  test "add comment to task" do
    {:ok, task} = Taskman.Stores.Tasks.insert_task(@test_task, [])

    comment_text = "test comment"
    {:ok, new_comment} = Taskman.Stores.Comments.new_comment(comment_text, task.id, @user_id)

    {:ok, task} = Taskman.Stores.Tasks.get_task_by_id(task.id, @user_id)
    assert task.comments == [new_comment]
  end
end
