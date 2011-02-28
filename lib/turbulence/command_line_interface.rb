require 'fileutils'
require 'launchy'

class Turbulence
  class CommandLineInterface
    TURBULENCE_PATH = File.join(File.absolute_path(File.dirname(__FILE__)), "..", "..")

    attr_reader :directory
    def initialize(directory)
      @directory = directory
    end

    def path_to_template(filename)
      File.join(TURBULENCE_PATH, "template", filename)
    end

    def copy_templates_into(directory)
      FileUtils.cp path_to_template('turbulence.html'), directory
      FileUtils.cp path_to_template('highcharts.js'), directory
      FileUtils.cp path_to_template('jquery.min.js'), directory
    end

    def generate_bundle
      FileUtils.mkdir_p("turbulence")
      Dir.chdir("turbulence") do
        copy_templates_into(Dir.pwd)  
        File.open("cc.js", "w") do |f| 
          f.write Turbulence::ScatterPlotGenerator.from(Turbulence.new(directory).metrics)
        end
      end
    end

    def open_bundle
      Launchy.open("file://#{directory}/turbulence/turbulence.html")
    end
  end
end
