create table task (
    task_id BIGINT NOT NULL,
    name TEXT NOT NULL,
    cost BIGINT NOT NULL,
    priority BIGINT NOT NULL,
    description TEXT NOT NULL,
    time_posted BIGINT NOT NULL,
    status BIGINT NOT NULL,

    deadline BIGINT,

    CONSTRAINT pk_task PRIMARY KEY (task_id)
);

create index task_status_index on task(status);

create sequence task_id start 1;