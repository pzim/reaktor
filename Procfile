web: shotgun
worker_create: rake TERM_CHILD=1 QUEUE=resque_create resque:work
worker_update: rake TERM_CHILD=1 QUEUE=resque_update resque:work
worker_delete: rake TERM_CHILD=1 QUEUE=resque_delete resque:work
