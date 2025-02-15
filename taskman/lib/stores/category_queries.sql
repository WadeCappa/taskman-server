-- this file exists for testing purposes and is not used programatically. Just scratch paper for queries

select categories.category_id, categories.category_name, count(distinct relationship_id) as count 
from categories left join (
    select tasks_to_categories.relationship_id, tasks_to_categories.category_id
    from tasks_to_categories join tasks on tasks.id = tasks_to_categories.task_id
    where tasks.status = '0'
) as sub_q on sub_q.category_id = categories.category_id 
group by categories.category_id;