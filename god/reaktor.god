rack_root          = ENV['RACK_ROOT'] || File.dirname(__FILE__)
reaktor_logdir     = ENV['REAKTOR_LOG'] || "#{rack_root}/log/"
hipchat_token      = ENV['REAKTOR_HIPCHAT_TOKEN']
hipchat_room       = ENV['REAKTOR_HIPCHAT_ROOM']
worker_user        = ENV['REAKTOR_USER'] || ENV['USER']
worker_group       = ENV['REAKTOR_GROUP'] || ENV['GROUP']

queues = {
  resque_create: ENV['RESQUE_CREATE_WORKERS'] || 1,
  resque_modify: ENV['RESQUE_MODIFY_WORKERS'] || 1,
  resque_delete: ENV['RESQUE_DELETE_WORKERS'] || 1
}


queues.each do |queue, num_workers|
  num_workers.times do |num|
    God.watch do |w|
      w.name     = "#{queue}-#{num}"
      w.dir      = "#{rack_root}"
      w.group    = 'resque'
      w.uid      = "#{worker_user}"
      w.gid      = "#{worker_group}"
      w.interval = 30.seconds
      w.env      = {'QUEUE' => queue}
      w.start    = "reaktor_worker"
      w.log      = "#{reaktor_logdir}/#{queue}-#{num}.log"
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
end


God.watch do |w|
  w.name     = "reaktor-0"
  w.dir      = "#{rack_root}"
  w.group    = 'reaktor-web'
  w.uid      = "#{worker_user}"
  w.gid      = "#{worker_group}"
  w.interval = 30.seconds
  w.start    = "reaktor"
  w.log      = "#{reaktor_logdir}/reaktor-stdout.log"
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




God::Contacts::Hipchat.defaults do |d|
  d.token = "#{hipchat_token}"
  d.room  = "#{hipchat_room}"
  d.from  = 'Hubot'
end

God::Contacts::Email.defaults do |d|
  d.from_email = 'god@example.com'
  d.from_name = 'God'
  d.delivery_method = :sendmail
end

God.contact(:email) do |c|
  c.name = 'hip_notify'
  c.group = 'devnull'
  c.to_email = 'root@localhost'
end

#God.contact(:hipchat) do |d|
#  d.name = 'hip_notify'
#end

#  vim: set ft=ruby ts=4 sw=2 tw=80 et :
