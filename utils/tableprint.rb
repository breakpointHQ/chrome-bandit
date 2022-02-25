def tableprint(col_labels, data)
    columns = col_labels.each_with_object({}) { |(col,label),h|
        h[col] = {
            label: label,
            width: [data.map { |g| g[col].size }.max, label.size].max
        }
    }
    write_divider columns
    write_header columns
    write_divider columns
    data.each { |h| write_line(h, columns) }
    write_divider columns
end

private

def write_header(columns)
    puts "| #{ columns.map { |_,g| g[:label].ljust(g[:width]) }.join(' | ') } |"
end
  
def write_divider(columns)
    puts "+-#{ columns.map { |_,g| "-"*g[:width] }.join("-+-") }-+"
end

def write_line(h, columns)
    str = h.keys.map { |k| h[k].to_s.ljust(columns[k][:width]) }.join(" | ")
    puts "| #{str} |"
end