worker_processes 1
working_directory "/var/rails/qrhunt/production/current"
stderr_path "/var/log/rails/qrhunt/production/unicorn.stderr.log"
stdout_path "/var/log/rails/qrhunt/production/unicorn.stdout.log"
preload_app true
timeout 30
pid "/var/rails/qrhunt/production/current/unicorn.pid"
GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true
listen "/tmp/qrhunt_production.socket", :backlog => 64

