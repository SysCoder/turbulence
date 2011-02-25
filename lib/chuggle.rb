require 'flog'
require 'stringio'

class Chuggle
  class Reporter < StringIO
    def average
      Float(string.scan(/^\s+([^:]+).*average$/).flatten.first)
    end
  end
  
  attr_reader :dir
  attr_reader :metrics
  def initialize(dir)
    @dir = dir
    @metrics = {}
    Dir.chdir(dir) do
      @ruby_files = Dir["**/*\.rb"]
      churn
      flog
    end
  end

  def churn
    changes_by_ruby_file.each do |count, filename|
      metrics_for(filename)[:churn] = Integer(count)
    end
  end

  def flog
    flogger = Flog.new
    @ruby_files.each do |filename|
      flogger.flog filename
      reporter = Reporter.new
      flogger.report(reporter)
      metrics_for(filename)[:flog] = reporter.average
    end 
  end
  
  def metrics_for(filename)
    @metrics[filename] ||= {}
  end
  
  private
    def changes_by_ruby_file
      changes_by_file.select do |count, filename|
        filename =~ /\.rb$/
      end
    end
    
    def changes_by_file
      # borrowed from @coreyhaines
      `git log --all -M -C --name-only| sort | uniq -c | sort`.split(/\n/).map(&:split)
    end
end
