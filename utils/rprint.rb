def rprint(rows, space = 10)
    str = ""
    max_cell_size = 0

    for row in rows
        for cell in row
            cell = cell.to_s
            max_cell_size = [max_cell_size, cell.length].max
        end
    end
    
    max_cell_size = max_cell_size + space

    for row in rows
        str = ""
        for cell in row
            cell = cell.to_s
            n = max_cell_size-cell.length
            suffix = " " * n
            str += cell + suffix
        end
        puts str
    end
end