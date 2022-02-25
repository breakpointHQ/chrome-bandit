def rprint(rows, space = 10)
    str = ""
    maxCellSize = 0

    for row in rows
        for cell in row
            cell = cell.to_s
            maxCellSize = [maxCellSize, cell.length].max
        end
    end
    
    maxCellSize = maxCellSize + space

    for row in rows
        str = ""
        for cell in row
            cell = cell.to_s
            n = maxCellSize-cell.length
            suffix = " " * n
            str += cell + suffix
        end
        puts str
    end
end