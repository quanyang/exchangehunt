# config/unicorn.rb
if Rails.env.development?
    worker_processes 1
else
    worker_processes 3
end

timeout 30
listen "0.0.0.0:3000"
