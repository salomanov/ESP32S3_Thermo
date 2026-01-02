def tele_sensor(BME280_data)
    var temp = BME280_data["Temperature"]
    var hum = BME280_data["Humidity"]
    var pre = BME280_data["Pressure"]
    var dew = BME280_data["DewPoint"]
    if persist.temp != temp
    persist.temp = temp
    p1b8.text = temp
    print(temp)
    end
    
end

tasmota.add_rule("Tele#BME280", tele_sensor, "tele_sensor")