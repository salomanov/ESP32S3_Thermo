def tele_sensor(BME280_data)
    var temp = BME280_data["Temperature"]
    var hum = math.round(BME280_data["Humidity"])
    var pre = BME280_data["Pressure"]
    var dew = BME280_data["DewPoint"]
    if persist.temp != temp
    persist.temp = temp
    p1b8.text = str(temp) + "°"
    end
    if persist.hum != hum
    persist.hum = hum
    p1b21.text = str(hum) + "%"
    end
    if persist.pre != pre
    persist.pre = pre
    p1b25.text = str(pre) + "ммР"
    end
    if persist.dew != dew
    persist.dew = dew
    p1b23.text = str(dew) + "°C"
    end
end


tasmota.add_rule("Tele#BME280", tele_sensor, "tele_sensor")

def tm(data)
    if data < 10
        data = "0" + str(data)
    else  data = str(data)
    end
    return data
end
def get_time(data)
    var hours   = data / 60
    var  minutes = data % 60
    var time = tm(hours) + ":"+ tm( minutes)
    p1b5.text = time 
end

def  get_date()
    var now = tasmota.rtc("local")
    var time_map = tasmota.time_dump(now)
    var year = str(time_map["year"])
    var month = str(tm(time_map["month"]))
    var day = str(tm(time_map["day"]))
    var weekday = time_map["weekday"]
    var hour = str(tm( time_map["hour"]))
    var min =str(tm( time_map["min"]))
    var weekdays = ["ВС", "ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ"]
    p1b5.text = hour + ":" + min
    p1b3.text = weekdays[weekday] +day + "." + month + "." + year
     
end
   


tasmota.add_rule("Time#Initialized", get_date, "get_date1")

tasmota.add_rule("Time#Minute=0", get_date, "get_date2")

tasmota.add_rule("Time#Minute", get_time, "get_time")




def get_btn_thermo(btn)
    if btn 
    tasmota.cmd("Backlog  SensorInputSet 1; THERMOSTATMODESET 1")
    tasmota.cmd("TempTargetSet " + str(persist.target_temp))
    p1b3.h = 80
    p1b9.color = "#00ccff"
    p1b40.hidden = false
    p1b41.hidden = false
    p1b10.toggle = true
    else  
    tasmota.cmd("THERMOSTATMODESET 0")
    p1b3.h = 100
    p1b9.color = "#636363"
    p1b40.hidden = true
    p1b41.hidden = true
     p1b10.toggle = false
    end
    persist.thermostat = btn
    persist.save()
end
tasmota.add_rule("hasp#p1b10#val", get_btn_thermo,  "get_btn_thermo")

def get_temp()
    p1b8.text = str(persist.temp) + "°"
    p1b21.text = str(persist.hum) + "%"
    p1b25.text = str(persist.pre) + "ммР"
    p1b23.text = str(persist.dew) + "°C"
    p1b41.text = str(persist.target_temp) + "°C"
    get_btn_thermo(persist.thermostat)
end


def get_btn_fan(btn)
tasmota.set_power(1, btn)
end
tasmota.add_rule("hasp#p1b12#val", get_btn_fan,  "get_btn")

def power2_state(sts)
if sts 
    p1b12.toggle = true
    p1b11.color = "#00ccff"
    p1b40.text_color = "#ff0000"
    p1b40.text = "\ue040"
else  
    p1b12.toggle = false
    p1b11.color = "#636363"
    p1b40.text_color = "#00ccff"
    p1b40.text = "\ue03f"
end
end
tasmota.add_rule("Power2#State", power2_state,  "power2_state")



def ark_state(sts)
  persist.target_temp = sts/10.0
  p1b14.text = str(persist.target_temp)
end
tasmota.add_rule("hasp#p1b13#val", ark_state,  "ark_state")


def minus_state()
  persist.target_temp -= 0.1
  p1b14.text = str(persist.target_temp)
end

def plus_state()
  persist.target_temp += 0.1
  p1b14.text = str(persist.target_temp)
end

tasmota.add_rule("hasp#p1b16#event=up", minus_state,  "minus_state")
tasmota.add_rule("hasp#p1b18#event=up", plus_state,  "plus_state")

tasmota.add_rule("System#Boot", get_temp, "get_temp")




def open_state()
    p1b13.hidden = false
    p1b14.hidden = false
    p1b15.hidden = false
    p1b16.hidden = false
    p1b17.hidden = false
    p1b18.hidden = false
    p1b19.hidden = false
    p1b26.hidden = false
    p1b13.val = persist.target_temp*10.0
    p1b14.text = str(persist.target_temp)
    p1b3.hidden = true
    p1b4.hidden = true
    p1b40.hidden = true
    p1b41.hidden = true
    p1b5.hidden = true
    p1b6.hidden = true
    p1b7.hidden = true
    p1b8.hidden = true
    p1b9.hidden = true
    p1b10.hidden = true
    p1b11.hidden = true
    p1b12.hidden = true
  end
tasmota.add_rule("hasp#p1b7",open_state,  "open_state")


def close_state()
    p1b13.hidden = true
    p1b14.hidden = true
    p1b15.hidden = true
    p1b16.hidden = true
    p1b17.hidden = true
    p1b18.hidden = true
    p1b19.hidden = true
    p1b26.hidden = true
    p1b41.text = str(persist.target_temp)  + "°C"
    tasmota.cmd("TempTargetSet " + str(persist.target_temp))
    p1b3.hidden = false
    p1b4.hidden = false
    p1b40.hidden = false
    p1b41.hidden = false
    p1b5.hidden = false
    p1b6.hidden = false
    p1b7.hidden = false
    p1b8.hidden = false
    p1b9.hidden = false
    p1b10.hidden = false
    p1b11.hidden = false
    p1b12.hidden = false
  end

tasmota.add_rule("hasp#p1b26#event=up", close_state,  "close_state")