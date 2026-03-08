def tele_sensor(BME280_data)
    var temp = BME280_data["Temperature"]
    var hum = math.round(BME280_data["Humidity"])
    var pre = BME280_data["Pressure"]
    var dew = BME280_data["DewPoint"]
    publish_calibrate(temp)
    if persist.temp != temp
    persist.temp = temp
    p1b19.text = str(temp) + "°"
    end
    if persist.hum != hum
    persist.hum = hum
    p1b3.text = str(hum) + "%"
    end
    if persist.pre != pre
    persist.pre = pre
    p1b7.text = str(pre) + "ммР"
    end
    if persist.dew != dew
    persist.dew = dew
    p1b5.text = str(dew) + "°C"
    end
end

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
    p1b8.text = time
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
    p1b8.text = hour + ":" + min
    p1b9.text = day + "." + month + "." + year + " " + weekdays[weekday]
end

def  print_data(data)
    print(data)
end

def publish_calibrate(temp)
    tasmota.cmd("Publish tuya/calibrate/set " + str(temp))
end

def publish_calibrate_on_change(temp, trigger, msg)
    if persist.calibrate_temp != temp
        persist.calibrate_temp = temp
        publish_calibrate(temp)
    end
end

def render_weather()
    if persist.weather_now_icon != nil
        p1b11.text = persist.weather_now_icon
    end
    if persist.weather_now_temp != nil
        p1b12.text = persist.weather_now_temp
    end
    if persist.weather_day_icon != nil
        p1b13.text = persist.weather_day_icon
    end
    if persist.weather_day_temp != nil
        p1b14.text = persist.weather_day_temp
    end
    if persist.weather_desc != nil
        p1b15.text = persist.weather_desc
    end
end

def get_weather_payload()
  var wc = webclient()
  wc.set_timeouts(1500, 1000)
  wc.begin("https://api.open-meteo.com/v1/forecast?latitude=57.257538&longitude=65.136679&daily=temperature_2m_max,weather_code,temperature_2m_min&current=temperature_2m,apparent_temperature,is_day,weather_code&timezone=Asia/Yekaterinburg&forecast_days=1")
  var temp
  if wc.GET() == 200
    var body = wc.get_string()
    var d = json.load(body)
    if d != nil && d["current"] != nil
    var t = (d["current"]["temperature_2m"])
    var ta = (d["current"]["apparent_temperature"])
    var dn = (d["current"]["is_day"])
    var w1 = (d["current"]["weather_code"])
    var tmin = (d["daily"]["temperature_2m_min"][0])
    var tmax = (d["daily"]["temperature_2m_max"][0])
    var w2 = (d["daily"]["weather_code"][0])
    temp = [t, ta, dn, w1, tmin, tmax, w2]
    end
  end
  wc.close()
  return temp
end

def apply_weather(w)
    var w1
    var w2
    var weather_codes_map = {
        0: ["Ясно / Солнечно", "\uf00d"],
        1: ["В основном ясно", "\uf00c"],
        2: ["Частичная облачность", "\uf002"],
        3: ["Пасмурно", "\uf013"],
        45: ["Туман", "\uf021"],
        48: ["Отложение изморози", "\uf014"],
        51: ["Морось: слабая", "\uf01a"],
        53: ["Морось: умеренная", "\uf0b5"],
        55: ["Морось: сильная", "\uf017"],
        56: ["Ледяная морось: слабая", "\uf01a"],
        57: ["Ледяная морось: сильная", "\uf0b5"],
        61: ["Дождь: слабый", "\uf015"],
        63: ["Дождь: умеренный", "\uf019"],
        65: ["Дождь: сильный", "\uf019"],
        66: ["Ледяной дождь: слабый", "\uf019"],
        67: ["Ледяной дождь: сильный", "\uf019"],
        71: ["Снег: слабый", "\uf01b"],
        73: ["Снег: умеренный", "\uf01b"],
        75: ["Снег: сильный", "\uf064"],
        77: ["Мокрый снег", "\uf0b5"],
        80: ["Ливень: слабый", "\uf018"],
        81: ["Ливень: умеренный", "\uf018"],
        82: ["Ливень: сильный", "\uf018"],
        85: ["Снегопад: слабый", "\uf0b5"],
        86: ["Снегопад: сильный", "\uf0b5"],
        95: ["Гроза", "\uf01e"],
        96: ["Гроза с градом: слабая", "\uf01d"],
        99: ["Гроза с градом: сильная", "\uf01d"]
        }
    var weather_codes_map2 = {
        0: ["Ясно / Солнечно", "\uf02e"],
        1: ["В основном ясно", "\uf083"],
        2: ["Частичная облачность", "\uf086"]
        }
    if w
        if w[3] < 3 && !w[2]
            w1 = weather_codes_map2[w[3]][1]
        else
            w1 = weather_codes_map[w[3]][1]
        end
        if w[6] < 3 && !w[2]
            w2 = weather_codes_map2[w[6]][1]
        else
            w2 = weather_codes_map[w[6]][1]
        end

        persist.weather_now_icon = w1
        persist.weather_now_temp = str(w[0])  + "°"
        persist.weather_day_icon = w2
        persist.weather_day_temp =  str(w[4]) + "°/" + str(w[5])  + "°"
        persist.weather_desc =  weather_codes_map[w[3]][0] + ", ощущается как " + str(w[1])  + "°"
        persist.weather_updated = tasmota.rtc("local")
        render_weather()
        tasmota.cmd("Backlog Publish tele/weather/temp " + str(w[0]) + "; Publish tele/weather/icon " + str(w[3]) + "; Publish tele/weather/day " + str(w[2]))
     end
end

def set_weather()
    if persist.weather_busy
        return nil
    end
    persist.weather_busy = true
    var w = get_weather_payload()
    persist.weather_busy = false
    if w
        apply_weather(w)
    else
        render_weather()
    end
end

def init_weather()
    persist.weather_busy = false
    render_weather()
    tasmota.remove_timer("weather_boot")
    tasmota.set_timer(15000, set_weather, "weather_boot")
end

def thermo(data)
    if data
    tasmota.cmd("Backlog  SensorInputSet 1; THERMOSTATMODESET 1")
    tasmota.cmd("TempTargetSet " + str(persist.target_temp))
    else
        tasmota.cmd("THERMOSTATMODESET 0")
    end
end

def get_temp()
    var result_str = tasmota.read_sensors()
    var result_obj = json.load(result_str)
    if result_obj != nil
        var bme_data = result_obj["BME280"]
        if bme_data != nil
            var temp = bme_data["Temperature"]
            var hum = bme_data["Humidity"]
            var dp = bme_data["DewPoint"]
            var pre = bme_data["Pressure"]
            p1b19.text = str(temp) + "°"
            p1b3.text = str(math.round(hum)) + "%"
            p1b7.text = str(pre) + "ммР"
            p1b5.text = str(dp) + "°C"
        end
    end
    render_weather()
    thermo(persist.thermostat)
end

#tasmota.add_rule("hasp#p0b0#idle=off", / args -> p1.show())
#tasmota.add_rule("hasp#p0b0#idle=short", / args -> p2.show())

tasmota.add_rule("hasp", print_data, "print_data")

tasmota.add_rule("Time#Initialized", get_date, "get_date1")
tasmota.add_rule("Time#Minute=0", get_date, "get_date2")
tasmota.add_rule("Time#Minute", get_time, "get_time")
tasmota.add_rule("System#Boot", get_temp, "get_temp")
tasmota.add_rule("System#Boot", init_weather, "init_weather")
tasmota.add_rule("BME280#Temperature", publish_calibrate_on_change, "publish_calibrate_on_change")
tasmota.add_rule("Tele#BME280", tele_sensor, "tele_sensor")
tasmota.add_rule("Time#Minute|15", set_weather, "set_weather")
