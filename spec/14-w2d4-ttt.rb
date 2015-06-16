require 'w2d4/ttt-second-attempt'

describe ComputerPlayer do
  attr_reader :board, :computer

  before(:each) do
    @board = Board.new
    @computer = ComputerPlayer.new(1, :X, board)
  end

  describe '#get_vital_move' do
    it 'always returns the priority cell' do
      board[0, 1] = :O
      board[1, 1] = :O
      board[0, 2] = :X
      board[1, 2] = :X

      20.times do
        expect(computer.send(:get_vital_cell, :X)).to eq([2, 2])
      end
    end
  end
end


