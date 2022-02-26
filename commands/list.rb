require 'sqlite3'
require 'optparse'
require 'tempfile'
require 'fileutils'

class ListCommand

    def initialize
        @options = {
            format: 'text',
            login_data: nil
        }

        parser = OptionParser.new do |opts|
            opts.banner = 'Usage: chrome-bandit list [options]'
            opts.on('-u', '--url <url>', String, 'only show credentials where the origin url match <url>')
            opts.on('-f', '--format <format>', String, 'set the output format: text, json')
            opts.on('-l', '--login_data <path>', String, 'set the "Login Data" file path')

            for browser in BROWSERS.keys
                opts.on('--' + browser.to_s)
            end

            opts.on('-v', '--verbose')
        end

        parser.parse!(into: @options)

        set_browser_defaults()

        if !@options[:login_data]
            @options[:chrome] = true
            set_browser_defaults()
        end

        if VERBOSE
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

        file = Tempfile.new('ld')
        FileUtils.cp(@options[:login_data], file.path)
        db = SQLite3::Database.new file.path

        sql = <<-SQL
            SELECT id, origin_url, username_value FROM logins
            WHERE username_value != '' and password_value != ''
            AND origin_url like ?
            order by times_used desc;
        SQL

        rows = db.execute sql, "%#{@options[:url]}%"
        
        db.close
        file.unlink

        if rows.length == 0
            raise 'no records'
        end
    
        case @options[:format]
            when "text"
                tableprint({id: "ID", url: "URL", username: "Username"}, rows.map { |(id,url,username)|
                    if url.length > 50
                        url = url[0...47] + "..."
                    end
                    {id: id, url: url, username: username}    
                })
            when "json"
                puts JSON.generate(rows.map { |(id,url,username)| {id: id, url: url, username: username} })
            end
    end

    private
    def set_browser_defaults
        for browser in BROWSERS.keys
            if !@options[browser]
                next
            end

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
    
end
