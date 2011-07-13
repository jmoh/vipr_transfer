module ViprTransfer

class Transferrer
  REMOTE_FLOW_DIR = "/data/data_flow/CLINICAL_IN"
  REMOTE_DATA_DIR = "/data/sterling"
  
  def initialize(options={})
    default_options={:host => "cn0", :user => "sterling", :password => "password"}
    @config = default_options.merge(options)
    
    
    @config[:vipr_dir_base]       = "#{@config[:date].strftime("%y%m%d")}_E#{@config[:exam_number]}"
    @config[:vipr_dir_with_subj]  = "#{@config[:vipr_dir_base]}_#{@config[:subj_id]}"
    @config[:subj_raw_dir]        = "/Data/vtrak1/raw/#{@config[:study_protocol]}/#{@config[:subj_id]}_#{@config[:exam_number]}_#{@config[:date].strftime("%d%m%Y")}"
  end
  
  def transfer
    run_remote_commands
    puts run_local_commands
  end
  
  def run_remote_commands
    if @config[:dry_run]
      remote_commands
    else
      Net::SSH.start(@config[:host], @config[:user], :password => @config[:password]) do |ssh|
        # capture all stderr and stdout output from a remote process
        glob = "#{File.join(REMOTE_FLOW_DIR, @config[:vipr_dir_base] + '_S*' )}"
        raw_dirs = ssh.exec!("ls -d #{glob}").split("\n")
        unless raw_dirs.select {|d| d =~ /No match/}.empty?
          puts_exec ssh, "ls /data/data_flow/CLINICAL_IN/"
          raise IOError, "Can't find VIPR Exam matching #{glob}"
        else
          puts_exec ssh, "mkdir #{File.join(REMOTE_DATA_DIR, @config[:vipr_dir_with_subj])}"
          raw_dirs.each do |dir|
            puts_exec ssh, "cp -r #{dir}/* #{File.join(REMOTE_DATA_DIR, @config[:vipr_dir_with_subj])}"
            # puts_exec ssh, "bzip2 -vv #{File.join(REMOTE_DATA_DIR, @config[:vipr_dir_with_subj], 'P*.7' )}"
          end
          
          pfiles = ssh.exec!("ls -l #{File.join(REMOTE_DATA_DIR, @config[:vipr_dir_with_subj], 'P*.7')}").split("\n")
          pfiles.map(&:split).collect {|ls_pfile| [ls_pfile[4].to_i, ls_pfile[8]]}.each do |total_size, pfile|
            remote_zip_with_log(ssh, pfile, total_size)
          end
          
        end
        
        # puts ssh.exec!("cd /data/sterling")
        # puts vipr_series_dir = ssh.exec!("ls #{@config[:vipr_dir_base]}_S*}")
        # if vipr_series_dir =~ /No match/
        #   raise IOError, "Can't find remote vipr series dir matching #{File.join('/data/sterling/', @config[:vipr_dir_base] + '_S*')}"
        # else
        #   puts ssh.exec!("mv #{@config[:vipr_dir_base]}_S*} #{@config[:vipr_dir_with_subj]}")
        # end
      end
    end
  end
  
  def puts_exec(ssh, cmd)
    puts cmd
    ssh.exec!(cmd)
  end
  
  def remote_zip_with_log(ssh, pfile, total_size)
    ssh.open_channel do |ch|
      ch.exec "bzip2 -vv #{pfile}"
      zipped = 0
      pbar ||= ProgressBar.new(File.basename(pfile), total_size)

      ch.on_extended_data do |ch, type, data|
        match = size = /size = (\d+)/.match(data)
        size = match[1].to_i if match
        sent ||= 0
        zipped += size if size
        # print '.'
        # STDOUT.flush

        pbar.set(zipped)
        pbar.finish if zipped == total_size
      
      end
      ch.wait
    end
  end
  
  # This runs a queue of local commands
  def run_local_commands
    if @config[:dry_run]
      # local_commands
    else 
      puts remote_dir = "/data/sterling/#{@config[:vipr_dir_with_subj]}"
      puts local_dir = "#{@config[:subj_raw_dir]}/vipr"      
      begin
        FileUtils.mkdir_p local_dir
      rescue SystemCallError => e
        raise e, "Can't write to #{local_dir}"; exit
      end

      
      #"scp -r sterling@cn0:/data/sterling/#{@config[:vipr_dir_with_subj]} #{@config[:subj_raw_dir]}/vipr/"]
      Net::SCP.start(@config[:host], @config[:user], :password => @config[:password]) do |scp|
        scp.download! remote_dir, local_dir, :recursive => true, :verbose => true do |ch, name, sent, total|
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
  end
  
end

end