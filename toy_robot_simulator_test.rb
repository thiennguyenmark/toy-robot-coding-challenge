require 'minitest/autorun'
require 'stringio'
require_relative 'toy_robot_simulator'

class ToyRobotSimulatorTest < Minitest::Test
  def test_move
    robot = ToyRobotSimulator::Robot.new(0, 0, 'NORTH')
    robot.move
    assert_equal '0,1,NORTH', robot.report
  end

  def test_left
    robot = ToyRobotSimulator::Robot.new(0, 0, 'NORTH')
    robot.left
    robot.left
    assert_equal '0,0,SOUTH', robot.report
  end

  def test_right
    robot = ToyRobotSimulator::Robot.new(0, 0, 'WEST')
    robot.right
    robot.right
    assert_equal '0,0,EAST', robot.report
  end

  def test_west_edge
    robot = ToyRobotSimulator::Robot.new(1, 0, 'WEST')
    robot.move
    robot.move
    assert_equal '0,0,WEST', robot.report
  end

  def test_east_edge
    robot = ToyRobotSimulator::Robot.new(3, 0, 'EAST')
    robot.move
    robot.move
    assert_equal '4,0,EAST', robot.report
  end

  def test_stdin
    $stdin = StringIO.open do |s|
      s.puts 'MOVE'
      s.puts 'PLACE 0,0,NORTH'
      s.puts 'REPORT'
      s.string
    end
    assert_output("0,0,NORTH\n") do
      ToyRobotSimulator.run
    end
    $stdin = STDIN
  end
end
