require 'json'
require 'sinatra/json'


# Server API
class API
  def initialize
    @DB = Sequel.connect('sqlite://hashpass.db')
    @DB[:active].delete
    @notifications = Notifications.new
    @process = nil
  end

  def login_page
    File.read(File.join('public', 'index.html'))
  end

  def main_page
    File.read(File.join('public', 'app.html'))
  end

  def start(active)
    return if @DB[:active].first.nil? || @DB[:active].first.empty?

    time_now = Time.now.iso8601
    
    @DB[:history].insert(
      hashid: active[:hashid], dictionary: active[:dictionary],
      dictionary2: active[:dictionary2], rules: active[:rules],
      mask: active[:mask], started_on: time_now
    ) unless active[:hashmode].empty?


    if active[:hashmode] == '2500'
      cap2hccapx =
        if RUBY_PLATFORM =~ /linux/
          './tools/cap2hccapx.bin'
        elsif RUBY_PLATFORM =~ /darwin/
          './tools/cap2hccapx-mac.bin'
        elsif RUBY_PLATFORM =~ /windows/
          'Critial Exception: User error :('
        else
          "Fuuuk"
        end
      cap_location = "hashes/#{active[:hash]}"
      hcap = "hashes/#{active[:hash]}"
      convert_cmd = "#{cap2hccapx} #{cap_location} #{hcap}"
      system(convert_cmd)
      sleep 3
    end

    hashname = 
      if active[:hashstring].empty? 
        "--#{ active[:hash] }"
      else
        "--#{ active[:hashstring] }"
      end

    options = {
      flags: active[:dictionary2].empty? && active[:rules].empty? && active[:mask].empty? ? '-a 0' : active[:rules].empty? && active[:mask].empty? ? '-a 1' : active[:rules].empty? ? '-a 3' : '-a 0',
      flags2: "-w 3 --status --status-timer=1 --session #{ time_now } --potfile-disable",
      rules: active[:rules].empty? ? '' : "-r #{active[:rules]}",
      hash:  !active[:hashstring].empty? ? "#{active[:hashstring]}" : "hashes/#{active[:hash]}",
      dics: active[:dictionary].empty? && active[:dictionary2].empty? ? "" : active[:dictionary2].empty? ? "#{active[:dictionary]}" : "#{active[:dictionary]} #{active[:dictionary2]}",
      cracked: "cracked/#{active[:hash]}#{active[:hashstring]}.crack",
      logs: !active[:hashstring].empty? ? "logs/#{active[:hashstring]}" : "logs/#{active[:hash]}"
    }

    unless active[:hashmode].empty?
      p @cmd = "hashcat -m #{active[:hashmode]} "\
        "#{options[:flags]} #{options[:flags2]} "\
        "#{options[:hash]} #{options[:dics]} "\
        "#{active[:mask]} #{options[:rules]} -o #{options[:cracked]} "\
        "> #{options[:logs]}"
    else 
      p @cmd = "hashcat --session #{ active[:hash] } --restore "\
        "-o #{options[:cracked]} "\
        "> #{options[:logs]}"
    end

    @process = IO.popen(@cmd, 'w')
    0
  end

  def clean
    `rm logs/*.*`
    `rm cracked/*.*`
  end

  def stop
    @process.puts("q") if @process
    DB[:active].delete
  end

  def upload(files)
    puts "files... #{files}"
    return if files.nil? || files.empty?
    files.each do |f|
      @filename = f[1][:filename]
      file = f[1][:tempfile]
      File.open("./hashes/#{@filename}", 'wb') do |ff|
        ff.write(file.read)
      end
    end
  end

  def pid_active?(pid)
    Process.getpgid(pid)
    true
  rescue Errno::ESRCH
    false
  end

  def status
    active = @DB[:active].first
    return '' if active.nil? || active.empty?
    active[:hash] = active[:hashstring] unless active[:hashstring].nil? || active[:hashstring].empty?
    type = read_log('Hash.Type', 1, active[:hash]) || ''
    recovered = read_log('Recovered', 1, active[:hash]) || '' #.delete(' ') || ''
    target = read_log('Hash.Target', 1, active[:hash]) || ''
    speed_dev_1 = read_log('Speed.Dev.#1', 1, active[:hash]).to_s.delete(' ') || ''
    speed_dev_2 = read_log('Speed.Dev.#2', 1, active[:hash]).to_s.delete(' ') || ''
    time_started = read_log('Time.Started', 4, active[:hash]) || ''
    time_estimated = read_log('Time.Estimated', 4, active[:hash]) || ''
    rejected = read_log('Rejected.', 1, active[:hash]).to_s.delete(' ') || ''
    restore_point = read_log('Restore.Point', 1, active[:hash]) || ''
    candidates_1 = read_log('Candidates.#1', 1, active[:hash]) || ''
    candidates_2 = read_log('Candidates.#2', 1, active[:hash]) || ''
    hw_monitor_1 = read_log('HWMon.Dev.#1', 2, active[:hash]).to_s.delete(' ') || ''
    hw_monitor_2 = read_log('HWMon.Dev.#2', 2, active[:hash]).to_s.delete(' ') || ''
    progress_cur = read_log('Progress.', 1, active[:hash]).to_s.split('/')[0] || ''
    progress_end = read_log('Progress.', 1, active[:hash]).to_s.split('/')[1].to_s.split(' ')[0]
    status = read_log('Status', 1, active[:hash]) || '...'

    if restore_point.split('/')[0].to_i > 0
      latest = Date.today - 10000
      @DB[:history].where(hashid: active[:hashid]).each do |hash|
        date = DateTime.iso8601(hash[:started_on])
        if date > latest
          latest = date
        end
      end
      result = @DB[:history].where(started_on: latest.to_s).update(restore: true) 
    end

    tail = `tail -n 24 logs/#{active[:hash]}`
    found = tail.split("\n").grep(/Stopped/)[0] unless tail.empty?
    if found
      @DB[:history].where(hashid: active[:hashid]).update(restore: false) 
      @DB[:active].delete
    end

    if status == 'Cracked' && @DB[:pending].count == 0
      @DB[:history].where(hashid: active[:hashid]).update(restore: false) 
      new_cracked
    elsif status == 'Cracked'
      @DB[:history].where(hashid: active[:hashid]).update(restore: false) 
      new_cracked
      promote
      active = DB[:active].first
      sleep 3
      start(active)
    elsif status == 'Exhausted' && @DB[:pending].count >= 1
      @DB[:history].where(hashid: active[:hashid]).update(restore: false) 
      @DB[:active].delete
      promote
      active = DB[:active].first
      sleep 3
      start(active)
    elsif status == 'Exhausted' && @DB[:pending].count == 0
      @DB[:history].where(hashid: active[:hashid]).update(restore: false) 
      @DB[:active].delete
    end

    {
      type: type,
      recovered: recovered,
      target: target,
      speed_dev_1: speed_dev_1,
      speed_dev_2: speed_dev_2,
      time_started: time_started,
      time_estimated: time_estimated,
      rejected: rejected,
      restore_point: restore_point,
      candidates_1: candidates_1,
      candidates_2: candidates_2,
      hw_monitor_1: hw_monitor_1,
      hw_monitor_2: hw_monitor_2,
      progress_cur: progress_cur,
      progress_end: progress_end,
      status: status,
      found: found,
      stdout: `tail -n 22 logs/#{active[:hash]}`
    }
  end

  def promote
    pending = @DB[:pending].first
    hashed = pending;
    return if hashed.nil?
    @DB[:active].delete
    @DB[:pending].filter(id: hashed[:id]).delete if @DB[:pending].count > 0
    @DB[:active].insert(
      name: hashed[:name], dictionary: hashed[:dictionary],
      dictionary2: hashed[:dictionary2], rules: hashed[:rules],
      mask: hashed[:mask], hash: hashed[:hash], hashid: hashed[:hashid],
      hashstring: hashed[:hashstring], hashmode: hashed[:hashmode]
    )
  end

  def new(param)
    name =        param['name'] || ''
    dictionary =  param['dictionary'] || ''
    dictionary2 = param['dictionary2'] || ''
    rules =       param['rules'] || ''
    mask =        param['mask'] || ''
    hashfile =    param['hash'] || ''
    hashmode =    param['hashmode'] || '2500'
    hashstring =  param['hashstring'] || ''
    hashid =      param['hashid'] || ''
    notify =      param['notify'] || false

    params = {
      name: name, dictionary: dictionary, dictionary2: dictionary2,
      rules: rules, mask: mask, hash: hashfile, hashmode: hashmode,
      hashstring: hashstring
    }

    if notify
      @notifications.mail("New Hash #{ param['hash'] } #{ param['hashmode'] }", params)
    end

    @DB[:pending].insert(
      name: name, dictionary: dictionary, dictionary2: dictionary2,
      rules: rules, mask: mask, hash: hashfile, hashmode: hashmode,
      hashstring: hashstring, hashid: hashid
    )
  end

  def insert_hash(param)
    name =        param['name'] || ''
    hashfile =    param['hash'] || ''
    hashmode =    param['hashmode'] || '2500'
    hashstring =  param['hashstring'] || ''
    latitude =    param['latitude'] || ''
    longitude =   param['longitude'] || ''

    params = {
      name: name, hash: hashfile, hashmode: hashmode, hashstring: hashstring
    }

    hash = Hashes.new(name: name, file: hashfile, string: hashstring, mode: hashmode, 
      latitude: latitude, longitude: longitude, added: Time.now.iso8601)
    hash.save
    p hash
  end

  def insert_dic(param)
    name =        param['name'] || ''
    location =    param['location'] || ''
    size =        '%.2f' % (File.size(param['location']).to_f / 2**20)

    dic = Dics.new(name: name, location: location, size: size)
    dic.save
  end

  def insert_rule(param)
    name =        param['name'] || ''
    location =    param['location'] || ''

    rule = Rules.new(name: name, location: location)
    rule.save
  end

  def new_cracked
    active = @DB[:active].first
    return if active.nil? || active.empty?
    out = []
    hash = !active[:hashstring].empty? ? "#{active[:hashstring]}" : "#{active[:hash]}"
    File.readlines('cracked/' + "#{hash}" + '.crack').each do |line|
      out << line
    end
    password = out[0].split(':').last
    DB[:cracked].insert(hash: hash, password: password)
    @notifications.mail("0wn3d!", out[0])
    @DB[:hashes].where(id: active[:hashid]).update(loot: password)
    @DB[:active].delete if @DB[:pending].count == 0
  end
end
