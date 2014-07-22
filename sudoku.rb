class Sudoku
  def initialize(board_string)
    @board = board_string.split("").map { |n| n.to_i }.each_slice(9).to_a
    row_col_each_with_index(@board) do |row_i, col_i, cell|
      @board[row_i][col_i] = (1..9).to_a if cell == 0
    end
  end

  def solve!(board = @board)
    start_length = board.flatten.length
    check_board = remove_impossibles(dup_board(board))
    return false if (board = check_board) == false     # Impossible state

    if start_length == board.flatten.length            # Stuck, start guessing
      next_board = try_guesses(board)
    else                                               # Not stuck, keep solving
      next_board = solve!(dup_board(board))
    end

    return board if board.flatten.length == 81         # Solved state
    @board = next_board
  end

  def row_col_each_with_index(board)
    board.each_with_index do |row, row_i|
      row.each_with_index { |cell, col_i| yield(row_i, col_i, cell) }
    end
  end

  def guess_list(board)
    guesses = {}
    row_col_each_with_index(board) do |row_i, col_i, cell|
      guesses[[row_i, col_i]] = cell if cell.is_a?(Array)
    end
    guesses
  end

  def try_guesses(board)
    guesses = guess_list(board)
    until guesses.empty?
      next_board = solve!(make_guess_board(board, guesses))
      unless next_board == false
        return next_board
      end
      guesses.delete_if { |key, value| value.empty? }
    end
    false
  end

  def make_guess_board(board, guesses)
    next_guess = guesses.first
    guess_board = dup_board(board)
    guess_board[next_guess[0][0]][next_guess[0][1]] = next_guess[1].pop
    guess_board
  end

  def impossible?(row_i, col_i, num, board)
    row_include?(row_i, col_i, num, board) ||
    col_include?(row_i, col_i, num, board) ||
    box_include?(row_i, col_i, num, board)
  end

  def col_include?(row_i, col_i, num, board)
    board.each_with_index do |row, test_row_i|
      next if row_i == test_row_i
      return true if row[col_i] == num
    end
    false
  end

  def row_include?(row_i, col_i, num, board)
    board[row_i].each_with_index do |cell, test_col_i|
      next if col_i == test_col_i
      return true if cell == num
    end
    false
  end

  def box_include?(row_i, col_i, num, board)
    box_range = box_range(row_i, col_i)
    box = board[box_range[0]].transpose[box_range[1]].transpose
    row_col_each_with_index(box) do |test_row_i, test_col_i, cell|
      next if row_i == (test_row_i + box_range[0].first) &&
              col_i == (test_col_i + box_range[1].first)
      return true if cell == num
    end
    false
  end

  def box_range(row_i, col_i)
    row_start = (row_i / 3) * 3
    col_start = (col_i / 3) * 3
    [(row_start..row_start + 2), (col_start..col_start + 2)]
  end

  def remove_impossibles(board)
    row_col_each_with_index(board) do |row_i, col_i, cell|
      if cell.is_a?(Array)
        cell.delete_if { |num| impossible?(row_i, col_i, num, board) }
        board[row_i][col_i] = cell.first if cell.length == 1
        return false if cell.empty?
      end
      return false if cell.is_a?(Integer) && impossible?(row_i, col_i, cell, board)
    end
    board
  end

  def dup_board(board)
    Marshal.load(Marshal.dump(board)) # Duplicates array and all sub-arrays
  end

  def print_board
    row_divider = "-------------------------\n"
    answer = ""
    return "Impossible board" unless @board.flatten.length == 81
    @board.each_with_index do |row, row_i|
      answer << "#{row_divider if row_i % 3 == 0}| "
      row.each_with_index do |cell, col_i|
        answer << "#{cell} #{'| ' if (col_i + 1) % 3 == 0}"
      end
      answer << "\n"
    end
    answer << "#{row_divider}\n"
  end
end
#------Driver Code-------
boards = File.readlines('sample.unsolved.txt')

boards.each_with_index do |board_string, board_num|
  game = Sudoku.new(board_string.chomp)
  game.solve!
  puts "#{board_num + 1}"
  puts game.print_board
end
