module ToyRobotSimulator
  TABLE_EDGE = 4
  ROBOT_MOVE_COMMANDS = %w[MOVE LEFT RIGHT].freeze
  ROBOT_INFO_COMMANDS = %w[REPORT].freeze
  DIRECTIONS = %w[NORTH EAST SOUTH WEST].freeze
  VALIDATION_COMMAND = /
    ^(?:PLACE\s[0-#{TABLE_EDGE}],[0-#{TABLE_EDGE}],(?:#{DIRECTIONS.join('|')}))
    |#{ROBOT_MOVE_COMMANDS.join('|')}|#{ROBOT_INFO_COMMANDS.join('|')}$
  /x.freeze

  class Commander
    attr_reader :robot, :commands

    def initialize
      @robot = nil
      @commands = filtered_input
    end

    def filtered_input
      Enumerator.new do |yielder|
        ARGF.each_line do |line|
          yielder << line.chomp if VALIDATION_COMMAND.match?(line)
        end
      end
    end

    def place_robot
      commands.next until commands.peek[0..4] == "PLACE"
      (x_pos, y_pos, facing) = commands.next[6..-1].split(',')
      @robot = Robot.new(x_pos, y_pos, facing)
    end

    def command_robot
      loop do
        command = commands.next
        command_sym = command.downcase.to_sym
        if ROBOT_MOVE_COMMANDS.include?(command)
          robot.public_send command_sym
        elsif ROBOT_INFO_COMMANDS.include?(command)
          puts robot.public_send command_sym
        end
      end
    end
  end

  class Robot
    attr_reader :x_pos, :y_pos, :facing

    def initialize(x_pos, y_pos, facing)
      @x_pos = x_pos.to_i
      @y_pos = y_pos.to_i
      @facing = DIRECTIONS.index(facing)
    end

    def x_pos=(pos)
      @x_pos = pos.clamp(0, TABLE_EDGE)
    end

    def y_pos=(pos)
      @y_pos = pos.clamp(0, TABLE_EDGE)
    end

    def facing=(index)
      @facing = (index + DIRECTIONS.size).modulo(DIRECTIONS.size)
    end

    def move
      public_send DIRECTIONS[facing].downcase.to_sym
    end

    def north
      self.y_pos = y_pos.succ
    end

    def east
      self.x_pos = x_pos.succ
    end

    def south
      self.y_pos = y_pos.pred
    end

    def west
      self.x_pos = x_pos.pred
    end

    def left
      self.facing = facing.pred
    end

    def right
      self.facing = facing.succ
    end

    def report
      "#{x_pos},#{y_pos},#{DIRECTIONS[facing]}"
    end
  end

  module_function

  def run
    commander = Commander.new
    commander.place_robot
    commander.command_robot
  end
end

ToyRobotSimulator.run if $PROGRAM_NAME == __FILE__
