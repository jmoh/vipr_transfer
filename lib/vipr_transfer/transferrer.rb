module ViprTransfer

class Transferrer
  def initialize(options={})
    default_options={:dry_run => true, :host => "cn0", :user => "sterling", :password => "password"}
    @config = default_options.merge(options)
    
    
    @config[:vipr_dir_base]       = "#{@config[:date].strftime("%y%m%d")}_E#{@config[:exam_number]}"
    @config[:vipr_dir_with_subj]  = "#{@config[:vipr_dir_base]}_#{@config[:subj_id]}"
    @config[:subj_raw_dir]        = "/Data/vtrak1/raw/#{@config[:study_protocol]}/#{@config[:subj_id]}_#{@config[:exam_number]}_#{@config[:date].strftime("%d%m%Y")}"
  end
  
  def transfer
    puts run_remote_commands
    puts run_local_commands
  end
  
  def run_remote_commands
    if @config[:dry_run]
      remote_commands
    else
      puts remote_commands
      Net::SSH.start(@config[:host], @config[:user], :password => @config[:password]) do |ssh|
        # capture all stderr and stdout output from a remote process
        return output = ssh.exec!(remote_commands.join("; "))
      end
    end
  end
  
  # This runs a queue of local commands
  def run_local_commands
    if @config[:dry_run]
      local_commands
    else 
      local_commands.flatten.each do |cmd|
        puts cmd;
        puts `#{cmd}`
        puts
      end
      
      #"scp -r sterling@cn0:/data/sterling/#{@config[:vipr_dir_with_subj]} #{@config[:subj_raw_dir]}/vipr/"]
      Net::SCP.start(@config[:host], @config[:user], :password => @config[:password]) do |scp|
        scp.download! "/data/sterling/#{@config[:vipr_dir_with_subj]}", "#{@config[:subj_raw_dir]}/vipr", :recursive => true do |ch, name, sent, total|
          pbar ||= ProgressBar.new(File.basename(name), total)
          pbar.set(sent)
          pbar.finish if sent == total
        end

      end
      
      return true
    end
  end
  

  def remote_commands
    # Note the name of the VIPR directory to be transferred. Typically, the files are named with the format: <YYMMDD>_E<exam#>_S####
    # Copy the directory to /data/sterling with the following naming convention: <YYMMDD>_E<exam#>_<subjID>
    [ 
      "cd /data/sterling",

      "mv #{@config[:vipr_dir_base]}_S* #{@config[:vipr_dir_with_subj]}",
      "bzip2 #{@config[:vipr_dir_with_subj]}/P*.7"]
  end
  
  def local_commands
    ["mkdir -p #{@config[:subj_raw_dir]}/vipr"]
  end

end

end