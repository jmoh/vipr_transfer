#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__),'..', 'lib')
require 'vipr_transfer'
require 'pp'
require 'optparse'

def run!
  include ViprTransfer
  
  
  # Parse CLI Options and Spec File
  # options = parse_options
  options = {:date => Date.parse("110708"), :exam_number => 4065, 
  :subj_id => "vipr_test", :study_protocol => "9000", :dry_run => false}
  
  # config = load_spec(options[:spec_file])
  # config.merge!(options)
  
  # Run the Transfer
  t = Transferrer.new options
  t.transfer
end

def parse_options
  options = {:dry_run => false}
  parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

    opts.on('-d', '--date DATE', "Scan date") do |date|
      options[:date] = Date.parse(date)
    end
    
    opts.on('-e', '--exam EXAM', "Exam Number") do |exam_number|
      options[:exam_number] = exam_number
    end

    opts.on('-p', '--protocol PROTOCOL', "Study Protocol")  do |study_protocol|
      options[:study_protocol] = study_protocol
    end
    
    opts.on('-s', '--subject SUBJECT', "Subject ID")  do |subj_id|
      options[:subj_id] = subj_id
    end
    
    opts.on('-r', '--dry-run', "Display Script without executing it.") do
      options[:dry_run] = true
    end

    opts.on('-f', '--force', "Overwrite output directory if it exists.") do
      options[:force_overwrite] = true
    end
    
    opts.on_tail('-h', '--help',          "Show this message")          { puts(parser); exit }
    opts.on_tail("Example: #{File.basename(__FILE__)} -d 110708 -e 4065 -p 9000 -s vipr_test")
  end
  parser.parse!(ARGV)

  if ARGV.size == 0
    # puts "Problem with arguments: #{ARGV}"
    puts(parser); exit
  end
  
  return options
end

if File.basename(__FILE__) == File.basename($0)
  run!
end