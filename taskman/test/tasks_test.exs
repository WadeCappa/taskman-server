
defmodule Taskman.Test.Tasks do
  @test_task %Taskman.Tasks{
    name: "test task",
    cost: 10,
    priority: 10,
    description: "test description",
    time_posted: 10,
    status: 0,
    deadline: 100,
    user_id: 100
  }
  @test_category_name_1 "test_category_1"
  @test_category_name_2 "test_category_2"

  use ExUnit.Case

  setup do
    Taskman.Repo.delete_all(Taskman.Tasks)
    Taskman.Repo.delete_all(Taskman.Comments)
    Taskman.Repo.delete_all(Taskman.Categories)
    Taskman.Repo.delete_all(Taskman.TasksToCategories)
    :ok
  end

  defp verify_task_matches(a, b) do
    assert a.name == b.name
    assert a.cost == b.cost
    assert a.priority == b.priority
    assert a.description == b.description
    assert a.time_posted == b.time_posted
    assert a.status == b.status
    assert a.deadline == b.deadline
    assert a.user_id == b.user_id
  end

  test "store task without categories" do
    {:ok, task} = Taskman.Stores.Tasks.insert_task(@test_task, [])
    verify_task_matches(task, @test_task)
  end

  test "store task with categories" do
    {:ok, category_1} = Taskman.Stores.Categories.try_create_category(@test_category_name_1, @test_task.user_id)
    {:ok, category_2} = Taskman.Stores.Categories.try_create_category(@test_category_name_2, @test_task.user_id)
    {:ok, task} = Taskman.Stores.Tasks.insert_task(@test_task, [category_1.category_id, category_2.category_id])

    verify_task_matches(task, @test_task)
    assert task.categories == [category_1, category_2]

    {:ok, task} = Taskman.Stores.Tasks.get_task_by_id(task.id, task.user_id)
    verify_task_matches(task, @test_task)
    assert task.categories == [category_1, category_2]
  end

end
