#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__),'..', 'lib')
require 'vipr_transfer'
require 'pp'
require 'optparse'

def run!
  include ViprTransfer
  
  
  # Parse CLI Options and Spec File
  options = parse_options
  # options = {:date => Date.parse("110708"), :exam_number => 4065, 
  # :subj_id => "vipr_test", :study_protocol => "9000", :dry_run => false}
  
  # config = load_spec(options[:spec_file])
  # config.merge!(options)
  
  begin
    # Run the Transfer
    t = Transferrer.new options
    t.transfer
  rescue IOError => e
    puts e
  end
end

def parse_options
  options = {:dry_run => false}
  parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

    opts.on('-d', '--date YYMMDD', "Scan date, format YYMMDD") do |date|
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

  missing_options = check_missing options
  unless missing_options.empty?
    puts "\nMissing required options: #{missing_options.join(",")}"; puts
    puts(parser); exit
  end
  
  return options
end

def check_missing options
  missing_options = []
  required_options = [:date, :exam_number, :study_protocol, :subj_id]
  required_options.each do |key|
    if !options.has_key?(key) || options[key] == ''
      missing_options << key
    end
  end
  return missing_options
  
end

if File.basename(__FILE__) == File.basename($0)
  run!
end