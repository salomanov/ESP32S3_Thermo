def tele_sensor(BME280_data)
    var temp = BME280_data["Temperature"]
    var hum = math.round(BME280_data["Humidity"])
    var pre = BME280_data["Pressure"]
    var dew = BME280_data["DewPoint"]
    if persist.temp != temp
    persist.temp = temp
    p1b8.text = str(temp) + "°"
    print(temp)
    end
    if persist.hum != hum
    persist.hum = hum
    p1b21.text = str(hum) + "%"
    print(hum)
    end
    if persist.pre != pre
    persist.pre = pre
    p1b25.text = str(pre) + "ммР"
    print(pre)
    end
    if persist.dew != dew
    persist.dew = dew
    p1b23.text = str(dew) + "°C"
    print(dew)
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
    print(tm(hours) + ":"+ tm( minutes) )
end


tasmota.add_rule("Time#Minute", get_time, "get_time")
