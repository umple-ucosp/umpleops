
def set_output(level)
  set :log_level, level
  configure_backend
end

class CapbashFormatter < SSHKit::Formatter::Abstract
  def write(obj)
    case
    when obj.is_a?(SSHKit::Command)
      puts("OBJ: #{obj}")
    end
  end
end

if ENV['TARGET'].nil? || ENV['OWNER'].nil? || ENV['NODE'].nil? || ENV['GROUP'].nil? || ENV['REMOTE_DIR'].nil?
  puts "Please specify target 'TARGET=<remote_host>', e.g. 'TARGET=10.0.0.3'\n" if ENV['TARGET'].nil?
  puts "Please specify user 'OWNER=<user>', e.g. 'OWNER=root'\n" if ENV['OWNER'].nil?
  puts "Please specify user 'GROUP=<user>', e.g. 'GROUP=www-data'\n" if ENV['GROUP'].nil?
  puts "Please specify node 'NODE=<node>', e.g. 'NODE=default'\n" if ENV['NODE'].nil?
  puts "Please specify remote deploy dir 'REMOTE_DIR=<remote_dir>', e.g. 'REMOTE_DIR=/var/capbash'\n" if ENV['REMOTE_DIR'].nil?
  puts ""
  exit
end

role :target, "#{ENV['OWNER']}@#{ENV['TARGET']}"
set :stage, :production
set :format, :pretty

# AVAILABLE DEBUG(0), INFO(1), WARN(2), ERROR(3), FATAL(4)
set_output (ENV['SSH_LOGLEVEL'] || Logger::INFO).to_i

cwd = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

capbash_dir = ENV['REMOTE_DIR']

namespace :capbash do

  desc "Deploy to your server"
  task :deploy do
    invoke 'capbash:install_rsync'
    invoke 'capbash:push'
    invoke 'capbash:install_node'
  end

  desc "Deploy to your server, but using nohup to detach"
  task :nohup do
    invoke 'capbash:install_rsync'
    invoke 'capbash:push'
    invoke 'capbash:install_nohup_node'
  end

  desc "Deploy twice to your server (e.g. setup groups, then do the full deploy), but using nohup to detach"
  task :nnohup do
    invoke 'capbash:install_rsync'
    invoke 'capbash:push'
    invoke 'capbash:install_nnohup_node'
  end

  desc "Install Cookbook Repository from cwd"
  task :install_rsync do
    on roles(:target), in: :sequence, wait: 1 do
      execute 'aptitude install -y rsync' unless test("which rsync")
      execute "mkdir -m 0775 -p #{capbash_dir}" if test("[ ! -e #{capbash_dir} ]")
    end
  end

  desc "Re-install Cookbook Repository from cwd"
  task :push do
    run_locally do
      execute "rsync -avz --delete -e \"ssh -p22\" \"#{cwd}/\" \"#{ENV['OWNER']}@#{ENV["TARGET"]}:#{capbash_dir}\" --exclude \".svn\" --exclude \".git\""
    end
    on roles(:target) do
      execute "chown -R #{ENV['OWNER']}:#{ENV['GROUP']} #{capbash_dir}"
    end
  end

  desc "Grab latest Cookbook Repository from remote for cwd"
  task :pull do
    run_locally do
      execute "rsync -avz --delete -e \"ssh -p22\" \"#{ENV['OWNER']}@#{ENV["TARGET"]}:#{capbash_dir}/\" \"#{cwd}\" --exclude \".svn\" --exclude \".git\""
    end
  end

  task :install_node do
    on roles(:target), in: :sequence, wait: 1 do
      old_log_level = fetch(:log_level)

      # Default capbash log level to INFO
      # But set SSH to debug so that the remote server will be logged locally
      capbash_log_level = ENV['LOGLEVEL'] || Logger::INFO
      set_output Logger::DEBUG
      SSHKit.config.output = SSHKit::Formatter::SimpleText.new($stdout)

      begin
        execute "cd #{capbash_dir} && LOGLEVEL=#{capbash_log_level} ./nodes/#{ENV['NODE']}"
      rescue Exception => e
        # eat the exception
      end

      # Now reset the SSH formatter
      SSHKit.config.format = :pretty
      set_output old_log_level
    end
  end

  # TODO, consolidat install_node and install_nohup_node and install_nnohup_node
  task :install_nohup_node do
    on roles(:target), in: :sequence, wait: 1 do
      old_log_level = fetch(:log_level)

      # Default capbash log level to INFO
      # But set SSH to debug so that the remote server will be logged locally
      capbash_log_level = ENV['LOGLEVEL'] || Logger::INFO
      set_output Logger::DEBUG
      SSHKit.config.output = SSHKit::Formatter::SimpleText.new($stdout)

      begin
        execute "cd #{capbash_dir} && LOGLEVEL=#{capbash_log_level} nohup ./nodes/#{ENV['NODE']} > nohup.out 2>&1 & sleep 2"
      rescue Exception => e
        # eat the exception
      end

      # Now reset the SSH formatter
      SSHKit.config.format = :pretty
      set_output old_log_level
    end
  end

  # TODO, consolidat install_node and install_nohup_node and install_nnohup_node
  task :install_nnohup_node do
    on roles(:target), in: :sequence, wait: 1 do
      old_log_level = fetch(:log_level)

      # Default capbash log level to INFO
      # But set SSH to debug so that the remote server will be logged locally
      capbash_log_level = ENV['LOGLEVEL'] || Logger::INFO
      set_output Logger::DEBUG
      SSHKit.config.output = SSHKit::Formatter::SimpleText.new($stdout)

      begin
        nnohup_call = "sh -c \"echo 'FIRST deploy...' ; ./nodes/#{ENV['NODE']} ; echo 'DONE, FIRST deploy.' ; echo 'SECOND deploy...' ; ./nodes/#{ENV['NODE']} ; echo 'DONE, second deploy.'\""
        execute "cd #{capbash_dir} && LOGLEVEL=#{capbash_log_level} nohup #{nnohup_call} > nohup.out 2>&1 & sleep 2"
      rescue Exception => e
        # eat the exception
      end

      # Now reset the SSH formatter
      SSHKit.config.format = :pretty
      set_output old_log_level
    end
  end

  desc "Remove all traces of capbash"
  task :cleanup do
    on roles(:target), in: :sequence, wait: 1 do
      execute "rm -rf #{capbash_dir}"
    end
  end

end
