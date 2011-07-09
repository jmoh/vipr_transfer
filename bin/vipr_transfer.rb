#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__),'..', 'lib')
require 'vipr_transfer'
require 'pp'

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
  options = {:rotate => true}
  parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename(__FILE__)} [options] input_directory output_directory"

    opts.on('-s', '--spec SPEC', "Spec File for script parameters")     do |spec_file| 
      options[:spec_file] = spec_file
    end
    
    opts.on('-p', '--prefix PREFIX', "Filename Prefix")     do |prefix| 
      options[:file_prefix] = prefix
    end

    opts.on('-d', '--dry-run', "Display Script without executing it.") do
      options[:dry_run] = true
    end

    opts.on('-f', '--force', "Overwrite output directory if it exists.") do
      options[:force_overwrite] = true
    end
    
    opts.on('-m', '--mask MASK', "Add an arbitrary mask to apply to data.") do |mask|
      options[:mask] = File.expand_path(mask)
      abort "Cannot find mask #{mask}." unless (File.exist?(options[:mask]) || options[:dry_run])
    end
    
    opts.on('-t', '--tmp', "Sandbox the input directory in the case of zipped dicoms.") do
      options[:force_sandbox] = true
    end
    
    opts.on('--values VALUES_FILE', "Specify a b-values file.") do |bvalues_file|
      options[:bvalues_file] = bvalues_file
    end
        
    opts.on('--vectors VECTORS_FILE', "Specify a b-vectors file.") do |bvectors_file|
      options[:bvectors_file] = bvectors_file
    end
    
    opts.on('--no-rotate', "Don't rotate vectors prior to processing") do
      options[:rotate] = false
    end
    

    opts.on_tail('-h', '--help',          "Show this message")          { puts(parser); exit }
    opts.on_tail("Example: #{File.basename(__FILE__)} -s configuration/dti_spec.yaml -p pd006 raw/pd006 orig/pd006")
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