rack_root          = ENV['RACK_ROOT'] || "/data/apps/sinatra/reaktor"
reaktor_log        = ENV['REAKTOR_LOG'] || "#{rack_root}/reaktor.log"
hipchat_token      = ENV['REAKTOR_HIPCHAT_TOKEN']
hipchat_room       = ENV['REAKTOR_HIPCHAT_ROOM']
worker_user        = ENV['RESQUE_WORKER_USER'] || "jenkins"
worker_group       = ENV['RESQUE_WORKER_GROUP'] || "jenkins"
num_create_workers = ENV['RESQUE_CREATE_WORKERS'] || 3
num_modify_workers = ENV['RESQUE_MODIFY_WORKERS'] || 2
num_delete_workers = ENV['RESQUE_DELETE_WORKERS'] || 2

num_create_workers.times do |num|
  God.watch do |w|
    w.name     = "resque_create-#{num}"
    w.dir      = "#{rack_root}"
    w.group    = 'resque'
    w.uid      = "#{worker_user}"
    w.gid      = "#{worker_group}"
    w.interval = 30.seconds
    w.start    = "rake -f #{rack_root}/Rakefile TERM_CHILD=1 QUEUE=resque_create resque:work"
    w.log      = "#{reaktor_log}" 
    # clean pid files before start if necessary
    w.behavior(:clean_pid_file)

    # restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
        c.times = 2
        c.notify = 'hip_notify'
      end
    end

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.notify = 'hip_notify'
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
        c.notify = 'hip_notify'
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_exits) do |c|
        c.notify = 'hip_notify'
      end
    end
  end
end

num_delete_workers.times do |num|
  God.watch do |w|
    w.name     = "resque_delete-#{num}"
    w.dir      = "#{rack_root}"
    w.group    = 'resque'
    w.uid      = "#{worker_user}"
    w.gid      = "#{worker_group}"
    w.interval = 30.seconds
    w.start    = "rake -f #{rack_root}/Rakefile TERM_CHILD=1 QUEUE=resque_delete resque:work"
    w.log      = "#{reaktor_log}" 
    # clean pid files before start if necessary
    w.behavior(:clean_pid_file)

    # restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
        c.times = 2
        c.notify = 'hip_notify'
      end
    end

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.notify = 'hip_notify'
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
        c.notify = 'hip_notify'
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_exits) do |c|
        c.notify = 'hip_notify'
      end
    end
  end
end
num_modify_workers.times do |num|
  God.watch do |w|
    w.name     = "resque_modify-#{num}"
    w.dir      = "#{rack_root}"
    w.group    = 'resque'
    w.uid      = "#{worker_user}"
    w.gid      = "#{worker_group}"
    w.interval = 30.seconds
    w.start    = "rake -f #{rack_root}/Rakefile TERM_CHILD=1 QUEUE=resque_modify resque:work"
    w.log      = "#{reaktor_log}" 
    # clean pid files before start if necessary
    w.behavior(:clean_pid_file)

    # restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
        c.times = 2
        c.notify = 'hip_notify'
      end
    end

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.notify = 'hip_notify'
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
        c.notify = 'hip_notify'
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_exits) do |c|
        c.notify = 'hip_notify'
      end
    end
  end
end

  God::Contacts::Hipchat.defaults do |d|
    d.token = "#{hipchat_token}"
    d.room  = "#{hipchat_room}"
    d.from  = 'Hubot'
  end

  God.contact(:hipchat) do |d|
    d.name = 'hip_notify'
  end

